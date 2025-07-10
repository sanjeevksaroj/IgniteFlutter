import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static const String baseUrl = 'http://skunkworks.ignitesol.com:8000/books/';

  static Future<Map<String, dynamic>> fetchBooks({
    String? topic,
    String? search,
    int page = 1,
  }) async {
    final params = {
      'languages': 'en',
      'mime_type': 'image',
      'page': '$page',
      if (topic != null) 'topic': topic,
      if (search != null) 'search': search,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load books');
    }
  }
}
