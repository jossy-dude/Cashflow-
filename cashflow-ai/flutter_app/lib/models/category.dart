import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final double monthlyBudget;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.monthlyBudget,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'category',
      monthlyBudget: (json['monthly_budget'] as num?)?.toDouble() ?? 0.0,
      color: Color(json['color'] ?? 0xFF19E6A2),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'monthly_budget': monthlyBudget,
      'color': color.value,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    double? monthlyBudget,
    Color? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      color: color ?? this.color,
    );
  }
}
