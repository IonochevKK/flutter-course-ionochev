import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String creatorId;
  final String name;
  final String? coverUrl;
  final String author;
  final String description;
  final int year;
  final List<String> category;
  final DateTime createdAt;

  const Book({
    required this.id,
    required this.creatorId,
    required this.name,
    this.coverUrl,
    this.description = '',
    required this.year,
    required this.author,
    required this.category,
    required this.createdAt,
  });

  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final category = data['category'];
    final createdAt = data['createdAt'];
    final year = data['year'];
    return Book(
      id: doc.id,
      creatorId: _string(data['creatorId']),
      name: _string(data['name']),
      coverUrl: data['coverUrl'] is String ? data['coverUrl'] : null,
      author: _string(data['author']),
      description: _string(data['description']),
      year: year is num ? year.toInt() : 0,
      category: category is List ? category.whereType<String>().toList() : [],
      createdAt: createdAt is Timestamp ? createdAt.toDate() : DateTime.now(),
    );
  }

  static String _string(Object? value) => value is String ? value : '';

  Map<String, dynamic> toCreateMap() {
    return {
      'creatorId': creatorId,
      'name': name,
      'coverUrl': coverUrl,
      'author': author,
      'description': description,
      'year': year,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'coverUrl': coverUrl,
      'author': author,
      'description': description,
      'year': year,
      'category': category,
    };
  }

  @override
  List<Object?> get props => [
    id,
    creatorId,
    name,
    coverUrl,
    author,
    description,
    year,
    category,
    createdAt,
  ];
}
