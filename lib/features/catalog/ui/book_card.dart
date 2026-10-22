import 'package:flutter/material.dart';

import '../../../entities/book/model/book.dart';
import '../../../entities/book/ui/book_cover.dart';
import '../../../entities/book/ui/category_tag.dart';
import '../../../entities/book/ui/like_button.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.liked,
    required this.onTap,
    required this.onLike,
  });

  final Book book;
  final bool liked;
  final VoidCallback onTap;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 74,
                height: 100,
                child: Stack(
                  children: [
                    Hero(
                      tag: 'cover-${book.id}',
                      child: BookCover(book: book, width: 74, height: 100),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: LikeButton(liked: liked, onPressed: onLike),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.author} · ${book.year}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final c in book.category) CategoryTag(c)],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
