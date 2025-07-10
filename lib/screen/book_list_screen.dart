import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book.dart';
import '../services/api_service.dart';

class BookListScreen extends StatefulWidget {
  final String genre;
  const BookListScreen({required this.genre});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<Book> books = [];
  int page = 1;
  bool isLoading = false;
  String? search;
  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 300) {
        _fetchBooks();
      }
    });
  }

  Future<void> _fetchBooks() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final response = await ApiService.fetchBooks(
        topic: widget.genre.toLowerCase(),
        search: search,
        page: page,
      );
      final newBooks = (response['results'] as List)
          .map((json) => Book.fromJson(json))
          .toList();
      setState(() {
        books.addAll(newBooks);
        page++;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchSubmitted(String value) {
    setState(() {
      search = value;
      page = 1;
      books.clear();
    });
    _fetchBooks();
  }

  void _openBook(Book book) async {
    final formats = book.formats;
    final preferred = [
      'text/html',
      'application/pdf',
      'text/plain',
      'image/jpeg',
    ];

    for (final type in preferred) {
      final entry = formats.entries.firstWhere(
            (e) => e.key.startsWith(type) && !e.value.endsWith('.zip'),
        orElse: () => MapEntry('', ''),
      );

      if (entry.value.isNotEmpty) {
        final url = entry.value;
        final uri = Uri.tryParse(url);
        if (uri != null ) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }
    }

    // Show dialog only if no format worked
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text("No viewable version available"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }


  Widget _buildBookCard(Book book) {
    final imageUrl = book.formats['image/jpeg'] ?? '';
    final author = book.authors.isNotEmpty ? book.authors[0]['name'] : 'Unknown';

    return GestureDetector(
      onTap: () => _openBook(book),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.65,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            book.title.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            author,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F6FF),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F6FF),
        elevation: 0,
        leading: BackButton(color: Color(0xFF5A3FFF)),
        title: Text(
          _formatTitle(widget.genre),
          style: TextStyle(
            color: Color(0xFF5A3FFF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                onSubmitted: _onSearchSubmitted,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                      setState(() {
                        search = null;
                        books.clear();
                        page = 1;
                      });
                      _fetchBooks();
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Color(0xFFF0F0F6),
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Color(0xFF5A3FFF),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Grid of Books
      Expanded(
        child: Container(
          color: Color(0xFFF0F0F6),
          padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
          child: isLoading && books.isEmpty
              ? Center(child: CircularProgressIndicator())
              : books.isEmpty
              ? Center(
            child: Text(
              "No item found",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : GridView.builder(
            controller: _controller,
            itemCount: books.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 16,
              childAspectRatio: 0.44,
            ),
            itemBuilder: (_, index) => _buildBookCard(books[index]),
          ),
        ),
      ),

          ],
        ),
      ),
    );
  }

  String _formatTitle(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
