import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final String imageBg;
  final int count;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.imageBg,
    required this.count,
  });
}
