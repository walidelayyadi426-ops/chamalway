import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final IconData icon;
  final int count;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.count,
  });

  static const List<CategoryModel> allCategories = [
    CategoryModel(
      id: 'beaches',
      title: 'Beaches',
      icon: Icons.beach_access,
      count: 6,
    ),
    CategoryModel(
      id: 'mountains',
      title: 'Mountains',
      icon: Icons.landscape,
      count: 6,
    ),
    CategoryModel(
      id: 'history',
      title: 'History',
      icon: Icons.account_balance,
      count: 6,
    ),
    CategoryModel(
      id: 'restaurants',
      title: 'Restaurants',
      icon: Icons.restaurant,
      count: 6,
    ),
    CategoryModel(
      id: 'cafes',
      title: 'Cafés',
      icon: Icons.local_cafe,
      count: 6,
    ),
    CategoryModel(
      id: 'hotels',
      title: 'Hotels',
      icon: Icons.hotel,
      count: 6,
    ),
    CategoryModel(
      id: 'shopping',
      title: 'Shopping',
      icon: Icons.shopping_bag,
      count: 6,
    ),
  ];
}

