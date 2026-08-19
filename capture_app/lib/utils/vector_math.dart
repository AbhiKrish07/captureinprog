import 'dart:math';

class VectorMath {
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    if (a.isEmpty) return 0.0;
    
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  static List<double> generateMockEmbedding(String text) {
    // Generate a deterministically random 1536d vector based on the string hash
    final random = Random(text.hashCode);
    return List.generate(1536, (_) => random.nextDouble() * 2 - 1.0);
  }
}
