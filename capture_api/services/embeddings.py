from fastembed import TextEmbedding

# Initialize the embedding model lazily
_embedding_model = None

def get_embedding_model():
    global _embedding_model
    if _embedding_model is None:
        # User requested sentence-transformers/all-MiniLM-L6-v2 (384 dimensions)
        _embedding_model = TextEmbedding(model_name="sentence-transformers/all-MiniLM-L6-v2")
    return _embedding_model

def generate_embedding(text: str) -> list[float]:
    """
    Generate a 384-dimensional embedding for the given text using fastembed.
    """
    if not text.strip():
        return [0.0] * 384
        
    model = get_embedding_model()
    # embed() returns a generator of numpy arrays, we want the first one
    embeddings = list(model.embed([text]))
    return embeddings[0].tolist()
