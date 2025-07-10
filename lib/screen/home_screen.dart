import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';
import 'book_list_screen.dart';

class HomeScreen extends StatelessWidget {

  final List<Map<String, dynamic>> genres = [
    {'label': 'FICTION', 'icon': 'assets/icons/fiction.svg', 'topic': 'fiction', 'isSvg': true},
    {'label': 'DRAMA', 'icon': 'assets/icons/drama.svg', 'topic': 'drama', 'isSvg': true},
    {'label': 'HUMOUR', 'icon': 'assets/icons/humour.svg', 'topic': 'humor', 'isSvg': true},
    {'label': 'POLITICS', 'icon': 'assets/icons/politics.svg', 'topic': 'politics', 'isSvg': true},
    {'label': 'PHILOSOPHY', 'icon': 'assets/icons/philosophy.svg', 'topic': 'philosophy', 'isSvg': true},
    {'label': 'HISTORY', 'icon': 'assets/icons/history.svg', 'topic': 'history', 'isSvg': true},
    {'label': 'ADVENTURE', 'icon': 'assets/icons/adventure.svg', 'topic': 'adventure', 'isSvg': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F6FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.gutenbergProject,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A3FFF),
                ),
              ),
              SizedBox(height: 16),
              Text(
                  AppStrings.description,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: genres.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final genre = genres[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookListScreen(genre: genre['topic']),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            genre['isSvg']
                                ? SizedBox(
                              width: 24,
                              height: 24,
                              child: SvgPicture.asset(
                                genre['icon'],
                                fit: BoxFit.contain,
                                placeholderBuilder: (context) =>
                                    Icon(Icons.book, color: Color(0xFF5A3FFF)),
                              ),
                            )
                                : Icon(genre['icon'], color: Color(0xFF5A3FFF)),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                genre['label'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
