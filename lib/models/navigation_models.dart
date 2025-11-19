import 'package:flutter/material.dart';

class NavigationItem {
  final IconData icon;
  final String label;
  final Color color;
  final int index;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.index,
  });
}

class NavigationGroup {
  final String title;
  final List<NavigationItem> items;
  final bool isExpandable;

  NavigationGroup({
    required this.title,
    required this.items,
    this.isExpandable = false,
  });
}
