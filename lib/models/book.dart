class Book {
  final String title;
  final List<dynamic> authors;
  final Map<String, String> formats;

  Book({required this.title, required this.authors, required this.formats});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      authors: json['authors'],
      formats: Map<String, String>.from(json['formats']),
    );
  }
}
