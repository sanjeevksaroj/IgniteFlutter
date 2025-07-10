// book_list_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import 'book_list_state.dart';

class BookListCubit extends Cubit<BookListState> {
  BookListCubit() : super(BookListInitial());

  int _page = 1;
  bool _isFetching = false;
  String? _search;
  String? _genre;
  final List<Book> _books = [];

  void init(String genre) {
    _genre = genre;
    fetchBooks(reset: true);
  }

  void fetchBooks({bool reset = false}) async {
    if (_isFetching) return;

    _isFetching = true;
    if (reset) {
      _page = 1;
      _books.clear();
      emit(BookListLoading());
    }

    try {
      final response = await ApiService.fetchBooks(
        topic: _genre!,
        search: _search,
        page: _page,
      );
      final fetched = (response['results'] as List).map((e) => Book.fromJson(e)).toList();
      final hasReachedMax = fetched.isEmpty;

      _books.addAll(fetched);
      emit(BookListLoaded(books: List.of(_books), hasReachedMax: hasReachedMax));
      _page++;
    } catch (e) {
      emit(BookListError("Failed to load books"));
    } finally {
      _isFetching = false;
    }
  }

  void search(String query) {
    _search = query;
    fetchBooks(reset: true);
  }

  void clearSearch() {
    _search = null;
    fetchBooks(reset: true);
  }
}
