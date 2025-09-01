class ScrapedNews {
  final int id;
  final String title;
  final String content;
  final String author;
  final String category;
  final String sourceUrl;
  final DateTime publishedDate;

  ScrapedNews({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.category,
    required this.sourceUrl,
    required this.publishedDate,
  });

  factory ScrapedNews.fromJson(Map<String, dynamic> json) {
    return ScrapedNews(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: json['author'],
      category: json['category'],
      sourceUrl: json['source_url'],
      publishedDate: DateTime.parse(json['published_date']),
    );
  }
}
