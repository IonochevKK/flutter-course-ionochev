import 'package:flutter/material.dart';

class SpaceCategory {
  final String label;
  final IconData icon;

  const SpaceCategory(this.label, this.icon);

  static const planet = SpaceCategory('Планета', Icons.public);
  static const mission = SpaceCategory('Миссия', Icons.rocket_launch);
}

class SpaceItem {
  final int id;
  final String title;
  final String subtitle;
  final SpaceCategory category;
  final List<Color> colors;
  final String? description;

  const SpaceItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.colors,
    this.description,
  });
}
