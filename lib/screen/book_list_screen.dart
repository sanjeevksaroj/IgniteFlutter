// book_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book.dart';
import '../cubit/book_list_cubit.dart';
import '../cubit/book_list_state.dart';

class BookListScreen extends StatelessWidget {
  final String genre;

  const BookListScreen({super.key, required this.genre});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookListCubit()..init(genre),
      child: _BookListScreenView(genre: genre),
    );
  }
}

class _BookListScreenView extends StatefulWidget {
  final String genre;
  const _BookListScreenView({required this.genre});

  @override
  State<_BookListScreenView> createState() => _BookListScreenViewState();
}

class _BookListScreenViewState extends State<_BookListScreenView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final cubit = context.read<BookListCubit>();
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
        final state = cubit.state;
        if (state is BookListLoaded && !state.hasReachedMax) {
          cubit.fetchBooks();
        }
      }
    });
  }

  void _openBook(Book book) async {
    final formats = book.formats;
    final preferred = ['text/html', 'application/pdf', 'text/plain'];

    for (final type in preferred) {
      final entry = formats.entries.firstWhere(
            (e) => e.key.startsWith(type) && !e.value.endsWith('.zip'),
        orElse: () => MapEntry('', ''),
      );
      if (entry.value.isNotEmpty) {
        final url = entry.value;
        final uri = Uri.parse(url);
        if (url.isNotEmpty) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        return;
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: const Text("No viewable version available"),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FF),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF5A3FFF)),
        title: Text(
          widget.genre[0].toUpperCase() + widget.genre.substring(1).toLowerCase(),
          style: const TextStyle(
            color: Color(0xFF5A3FFF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _searchController,
                onSubmitted: context.read<BookListCubit>().search,
                onChanged: (v) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                      context.read<BookListCubit>().clearSearch();
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF0F0F6),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF5A3FFF), width: 2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<BookListCubit, BookListState>(
                builder: (context, state) {
                  if (state is BookListLoading && state is! BookListLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BookListLoaded) {
                    if (state.books.isEmpty) {
                      return const Center(child: Text("No item found"));
                    }
                    return GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
                      itemCount: state.books.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.44,
                      ),
                      itemBuilder: (_, i) => _buildBookCard(state.books[i]),
                    );
                  } else if (state is BookListError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
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
          const SizedBox(height: 4),
          Text(
            book.title.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            author,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
