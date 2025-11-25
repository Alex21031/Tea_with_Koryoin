class Post {
  final int id;
  final String title;
  final String content;
  final String author;
  final String createdAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: json['author'],
      createdAt: json['created_at'], // 서버 필드명에 맞춤
    );
  }
}