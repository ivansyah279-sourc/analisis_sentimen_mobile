class SentimentAnalysis {
  final int id;
  final int scrapedDataId;
  final String sentimentLabel;
  final double sentimentScore;
  final double confidenceScore;
  final String modelUsed;
  final String title;
  final DateTime publishedDate;
  final String category;
  final String author;

  SentimentAnalysis({
    required this.id,
    required this.scrapedDataId,
    required this.sentimentLabel,
    required this.sentimentScore,
    required this.confidenceScore,
    required this.modelUsed,
    required this.title,
    required this.publishedDate,
    required this.category,
    required this.author,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) {
    return SentimentAnalysis(
      id: json['id'] ?? 0,
      scrapedDataId: json['scraped_data_id'] ?? 0,
      sentimentLabel: json['sentiment_label'] ?? '',
      sentimentScore: (json['sentiment_score'] ?? 0).toDouble(),
      confidenceScore: (json['confidence_score'] ?? 0).toDouble(),
      modelUsed: json['model_used'] ?? '',
      title: json['title'] ?? '',
      publishedDate: DateTime.tryParse(json['published_date'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      category: json['category'] ?? '',
      author: json['author'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scraped_data_id': scrapedDataId,
      'sentiment_label': sentimentLabel,
      'sentiment_score': sentimentScore,
      'confidence_score': confidenceScore,
      'model_used': modelUsed,
      'title': title,
      'published_date': publishedDate.toIso8601String(),
      'category': category,
      'author': author,
    };
  }
}
