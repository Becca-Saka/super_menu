import 'package:flutter/material.dart';

import 'menu_action_item.dart';

class MenuWrapper extends StatelessWidget {
  final double horizontalPosition;
  final double verticalPosition;
  final List<MenuActionItem> items;
  final List<MenuActionItem>? searchedItems;
  final MenuActionItem? item;
  final Function(MenuActionItem)? onHover;
  final Function()? onRemoveOverlay;
  final Function(MenuActionItem)? onSelected;
  final Function()? onHeaderTap;
  final double? maxItemHeight;
  final bool compact;
  final Widget? Function(Widget child)? animationBuilder;
  final Widget? Function(MenuActionItem?)? headerBuilder;
  final double? menuWidth;
  final double? menuHeight;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final String? backText;
  final bool addTitleHeader;
  final TextStyle? headerStyle;
  final TextStyle? menuStyle;
  final Function()? onTitleSelected;

  final ScrollController scrollController;
  const MenuWrapper({
    super.key,
    required this.horizontalPosition,
    required this.verticalPosition,
    required this.items,
    required this.onHover,
    required this.onRemoveOverlay,
    required this.onSelected,
    required this.scrollController,
    this.maxItemHeight,
    this.compact = false,
    this.item,
    this.onHeaderTap,
    this.animationBuilder,
    this.menuWidth,
    this.menuHeight,
    this.backgroundColor,
    this.shape,
    this.headerBuilder,
    this.backText,
    this.addTitleHeader = false,
    this.headerStyle,
    this.menuStyle,
    this.onTitleSelected,
    this.searchedItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (compact && item != null) ...[
          InkWell(
            onTap: () => onHeaderTap?.call(),
            child: headerBuilder?.call(item) ??
                Container(
                  width: menuWidth ?? 200,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_back_ios,
                        size: 12,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        backText ?? item!.title,
                        style: headerStyle,
                      ),
                    ],
                  ),
                ),
          ),
          if (addTitleHeader && headerBuilder == null && backText != null)
            InkWell(
              onTap: () => onTitleSelected?.call(),
              child: Container(
                width: menuWidth ?? 200,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Text(
                  item!.title,
                  style: headerStyle,
                ),
              ),
            ),
        ],
        Expanded(
          flex: maxItemHeight != null ? 1 : 0,
          child: Scrollbar(
            thumbVisibility: true,
            controller: scrollController,
            child: SingleChildScrollView(
              physics: maxItemHeight != null
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: addTitleHeader && compact ? 8 : 0),
                child: Builder(builder: (context) {
                  if (searchedItems != null && searchedItems!.isNotEmpty) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: searchedItems!.map(
                        (subItem) {
                          return _MenuItem(
                            width: menuHeight,
                            height: menuHeight,
                            item: subItem,
                            onHover: onHover,
                            onSelected: onSelected,
                            style: menuStyle,
                          );
                        },
                      ).toList(),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: items.map(
                      (subItem) {
                        return _MenuItem(
                          width: menuHeight,
                          height: menuHeight,
                          item: subItem,
                          onHover: onHover,
                          onSelected: onSelected,
                          style: menuStyle,
                        );
                      },
                    ).toList(),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final MenuActionItem item;
  final Function(MenuActionItem)? onHover;
  final Function(MenuActionItem)? onSelected;
  final double? width;
  final double? height;
  final TextStyle? style;
  const _MenuItem({
    required this.item,
    this.onHover,
    this.onSelected,
    this.width,
    this.height,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover?.call(item),
      child: InkWell(
        onTap: () {
          onSelected?.call(item);
        },
        child: Container(
          width: width ?? 200,
          height: height ?? (item.searchType == SearchType.subtitle ? 65 : 50),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: style,
                    ),
                    if (item.searchType != null &&
                        item.searchType == SearchType.subtitle &&
                        item.parentItem != null)
                      Text(
                        item.parentItem!.title,
                        style: style?.copyWith(fontSize: 12) ??
                            const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (item.subMenuItems.isNotEmpty && item.searchType == null)
                const Icon(Icons.chevron_right, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
