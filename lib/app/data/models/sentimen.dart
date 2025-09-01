class Sentiment {
  final String sentiment;
  final double count;

  Sentiment(this.sentiment, this.count);

  factory Sentiment.fromJson(Map<String, dynamic> json) {
    return Sentiment(
      json['sentiment'] as String,
      json['count'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentiment': sentiment,
      'count': count,
    };
  }
}
