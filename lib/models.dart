class Article
{
  const Article({this.source, this.id, this.author, this.description, this.imageUrl, this.publishesAt, this.title, this.url});
  final String source;
  final String id;
  final String author;
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final DateTime publishesAt;
}
