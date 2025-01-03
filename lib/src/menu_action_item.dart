import 'package:flutter/material.dart';

class MenuActionItem {
  final String title;
  final IconData? icon;
  final List<MenuActionItem> subMenuItems;
  final dynamic item;
  MenuActionItem({
    required this.title,
    this.subMenuItems = const [],
    this.item,
    this.icon,
  });
}
