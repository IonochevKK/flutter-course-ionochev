import 'package:flutter/material.dart';

class SpaceCategory {
  final String code;
  final String label;
  final IconData icon;

  const SpaceCategory(this.code, this.label, this.icon);

  static const planet = SpaceCategory('planet', 'Планета', Icons.public);
  static const mission = SpaceCategory(
    'mission',
    'Миссия',
    Icons.rocket_launch,
  );

  static const values = [planet, mission];

  static SpaceCategory fromCode(String code) {
    return values.firstWhere((c) => c.code == code, orElse: () => planet);
  }
}

class SpaceItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String description;
  final List<String> colors;

  const SpaceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.description,
    required this.colors,
  });

  factory SpaceItem.fromJson(Map<String, dynamic> json) {
    return SpaceItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      colors: (json['colors'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'description': description,
      'colors': colors,
    };
  }

  SpaceCategory get spaceCategory => SpaceCategory.fromCode(category);

  List<Color> get gradient => colors.map(_parseHex).toList();

  static Color _parseHex(String hex) {
    final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    return value == null ? Colors.indigo : Color(0xFF000000 | value);
  }
}
