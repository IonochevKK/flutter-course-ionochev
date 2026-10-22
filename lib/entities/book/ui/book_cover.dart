import 'package:flutter/material.dart';

import '../model/book.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    this.width,
    this.height,
    this.letterSize = 40,
    this.borderRadius = 8,
    this.letterOpacity = 0.55,
  });

  final Book book;
  final double? width;
  final double? height;
  final double letterSize;
  final double borderRadius;
  final double letterOpacity;

  static const _palette = [
    Color(0xFFB8452F),
    Color(0xFF2E6E6E),
    Color(0xFF3E5A80),
    Color(0xFFC8902E),
    Color(0xFF6B4E8C),
    Color(0xFF4F7A3A),
    Color(0xFF8C3B5A),
  ];

  static Color colorFor(String name) {
    final sum = name.codeUnits.fold<int>(0, (acc, c) => acc + c);
    return _palette[sum % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final url = book.coverUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    final letter = book.name.isEmpty ? '?' : book.name.characters.first;
    return ColoredBox(
      color: colorFor(book.name),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: letterOpacity),
            fontSize: letterSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
