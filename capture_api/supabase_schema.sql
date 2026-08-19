-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Captures Table
CREATE TABLE captures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('text', 'link', 'voice', 'image', 'file')),
  content TEXT NOT NULL,
  title TEXT,
  preview TEXT,
  embedding vector(384), -- 384 dimensions for fastembed BAAI/bge-small-en-v1.5
  metadata JSONB DEFAULT '{}'::jsonb,
  space_ids UUID[] DEFAULT '{}'::uuid[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast pgvector search
CREATE INDEX IF NOT EXISTS captures_embedding_idx ON captures USING hnsw (embedding vector_cosine_ops);

-- RLS Policies for captures
ALTER TABLE captures ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own captures" ON captures FOR ALL USING (auth.uid() = user_id);

-- Create a function to search for captures via pgvector
CREATE OR REPLACE FUNCTION match_captures(
  query_embedding vector(384),
  match_threshold float,
  match_count int,
  filter_space_id uuid DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  user_id uuid,
  type text,
  content text,
  title text,
  preview text,
  metadata jsonb,
  space_ids uuid[],
  created_at timestamptz,
  updated_at timestamptz,
  relevance_score float
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    captures.id,
    captures.user_id,
    captures.type,
    captures.content,
    captures.title,
    captures.preview,
    captures.metadata,
    captures.space_ids,
    captures.created_at,
    captures.updated_at,
    1 - (captures.embedding <=> query_embedding) AS relevance_score
  FROM captures
  WHERE auth.uid() = captures.user_id 
    AND (filter_space_id IS NULL OR filter_space_id = ANY(captures.space_ids))
    AND 1 - (captures.embedding <=> query_embedding) > match_threshold
  ORDER BY relevance_score DESC
  LIMIT match_count;
END;
$$;

-- Storage Bucket for Captures
INSERT INTO storage.buckets (id, name, public) VALUES ('captures', 'captures', true)
ON CONFLICT (id) DO NOTHING;

-- Storage Policies
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'captures');
CREATE POLICY "Auth Upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'captures' AND auth.role() = 'authenticated');
CREATE POLICY "Auth Delete" ON storage.objects FOR DELETE USING (bucket_id = 'captures' AND auth.role() = 'authenticated');

-- Spaces Table (Canvas State)
-- Run this to add canvas support to your existing spaces table:
-- ALTER TABLE spaces ADD COLUMN canvas_state JSONB DEFAULT '{}'::jsonb;
