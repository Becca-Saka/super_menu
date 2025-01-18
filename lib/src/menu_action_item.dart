import 'package:flutter/material.dart';

enum SearchType {
  parent,
  subtitle,
}

class MenuActionItem {
  final String title;
  final IconData? icon;
  final List<MenuActionItem> subMenuItems;
  final dynamic item;
  final SearchType? searchType;
  final MenuActionItem? parentItem;
  MenuActionItem({
    required this.title,
    this.subMenuItems = const [],
    this.item,
    this.icon,
    this.searchType,
    this.parentItem,
  });

  MenuActionItem copyWith({
    String? title,
    IconData? icon,
    List<MenuActionItem>? subMenuItems,
    dynamic item,
    SearchType? searchType,
    dynamic parentItem,
  }) {
    return MenuActionItem(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      subMenuItems: subMenuItems ?? this.subMenuItems,
      item: item ?? this.item,
      searchType: searchType ?? this.searchType,
      parentItem: parentItem ?? this.parentItem,
    );
  }

  @override
  String toString() {
    return 'MenuActionItem(title: $title, icon: $icon, subMenuItems: $subMenuItems, item: $item, searchType: $searchType, parentItem: $parentItem)';
  }
}
