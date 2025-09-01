class SentimentStatistics {
  final int totalDocuments;
  final Map<String, dynamic> sentimentDistribution;
  final Map<String, dynamic> percentages;
  final double averageConfidence;

  SentimentStatistics({
    required this.totalDocuments,
    required this.sentimentDistribution,
    required this.percentages,
    required this.averageConfidence,
  });

  factory SentimentStatistics.fromJson(Map<String, dynamic> json) {
    return SentimentStatistics(
      totalDocuments: json['total_documents'] ?? 0,
      sentimentDistribution:
          Map<String, dynamic>.from(json['sentiment_distribution'] ?? {}),
      percentages: Map<String, dynamic>.from(json['percentages'] ?? {}),
      averageConfidence: (json['average_confidence'] ?? 0).toDouble(),
    );
  }
}
