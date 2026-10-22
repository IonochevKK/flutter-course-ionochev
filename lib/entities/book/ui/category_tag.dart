import 'package:flutter/material.dart';

import '../model/book_category.dart';

class CategoryTag extends StatelessWidget {
  const CategoryTag(this.category, {super.key});

  final String category;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            BookCategory.iconOf(category),
            size: 12,
            color: scheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(fontSize: 11, color: scheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
