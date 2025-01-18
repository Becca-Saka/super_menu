import 'package:flutter/material.dart';

import 'animated_menu_list.dart';
import 'menu_action_item.dart';

class SuperMenu extends StatefulWidget {
  final List<MenuActionItem> menuItems;
  final Function(MenuActionItem?)? onSelected;
  final Function(MenuActionItem parent, MenuActionItem child)? onSubSelected;
  final Widget? button;
  final Widget? Function(Widget child)? animationBuilder;
  final Widget? Function(MenuActionItem?)? headerBuilder;
  final Widget? Function(ValueChanged<String>)? inputButtonBuilder;

  final double? menuWidth;
  final double? menuHeight;
  final Color? backgroundColor;
  final ShapeBorder? shape;
  final String? title;
  final String? backText;
  final bool addTitleHeader;
  final bool? compact;
  final TextStyle? headerStyle;
  final TextStyle? menuStyle;
  final FocusNode? focusNode;
  const SuperMenu({
    super.key,
    required this.menuItems,
    this.button,
    this.onSelected,
    this.onSubSelected,
    this.animationBuilder,
    this.headerBuilder,
    this.menuWidth,
    this.menuHeight,
    this.backgroundColor,
    this.shape,
    this.title,
    this.backText,
    this.addTitleHeader = false,
    this.compact,
    this.headerStyle,
    this.menuStyle,
    this.focusNode,
    this.inputButtonBuilder,
  }) : assert(
          title != null || button != null || inputButtonBuilder != null,
          "Either title or button or inputButtonBuilder must be provided.",
        );

  @override
  State<SuperMenu> createState() => _SuperMenuState();
}

class _SuperMenuState extends State<SuperMenu> {
  MenuActionItem? activeItem;
  OverlayEntry? _overlayEntry;
  OverlayEntry? _subOverlayEntry;
  final GlobalKey _globalKey = GlobalKey();
  final GlobalKey _parentGlobalKey = GlobalKey();
  bool showingCompact = false;
  bool isCompact = false;

  List<MenuActionItem> searchedItems = [];
  @override
  void initState() {
    _registerFocusNode();
    super.initState();
  }

  void _registerFocusNode() {
    if (widget.focusNode != null && widget.inputButtonBuilder != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.focusNode!.addListener(() {
          if (widget.focusNode!.hasFocus) {
            searchedItems.clear();
            _showMenu(context);
          }
        });
      });
    }
  }

  void _showSubMenu(BuildContext context, MenuActionItem item) {
    _removeSubMenu();
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final button =
        _parentGlobalKey.currentContext?.findRenderObject() as RenderBox;

    final buttonPos = button.localToGlobal(Offset.zero, ancestor: overlay);

    final parentIndex = widget.menuItems.indexOf(item);
    final remainingParentItems = widget.menuItems.sublist(0, parentIndex);
    double itemHeight = item.subMenuItems.length * 50;
    final parentHeight = remainingParentItems.length * 50;

    final size = MediaQuery.of(context).size;
    final buttonSize = button.size;
    final spaceBottom = size.height - buttonPos.dy - parentHeight;
    final spaceTop = size.height - buttonPos.dy + buttonSize.height;

    if (isCompact) {
      itemHeight = itemHeight + 50;
    }

    double? maxItemHeight;

    double verticalPosition =
        size.height - (buttonPos.dy + itemHeight + parentHeight);

    if (spaceBottom < itemHeight || spaceTop < itemHeight) {
      verticalPosition = 10;

      maxItemHeight =
          size.height < itemHeight ? size.height - 30 : itemHeight.toDouble();
    }

    if (isCompact) {
      _removeMenu();
      showingCompact = true;

      _overlayEntry = _buildOverlayEntry(
        horizontalPosition: buttonPos.dx,
        verticalPosition: verticalPosition + 5,
        maxItemHeight: maxItemHeight,
        isCompact: true,
        item: item,
        items: item.subMenuItems,
        onRemoveOverlay: () => _clearMenu(),
        onHover: (hoveredItem) {},
        onSelected: (v) {
          _clearMenu();
          widget.onSubSelected?.call(item, v);
        },
      );

      Overlay.of(context).insert(_overlayEntry!);
    } else {
      showingCompact = false;
      _subOverlayEntry = _buildOverlayEntry(
        horizontalPosition: buttonPos.dx + 200,
        verticalPosition: verticalPosition + 5,
        maxItemHeight: maxItemHeight,
        item: item,
        items: item.subMenuItems,
        onRemoveOverlay: () => _clearMenu(),
        onHover: (hoveredItem) {},
        onSelected: (v) {
          _clearMenu();
          widget.onSubSelected?.call(item, v);
        },
      );

      Overlay.of(context).insert(_subOverlayEntry!);
    }
  }

  void _showMenu(BuildContext context) {
    _removeMenu();
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final button = _globalKey.currentContext?.findRenderObject() as RenderBox;

    final buttonPos = button.localToGlobal(Offset.zero, ancestor: overlay);
    double itemHeight = widget.menuItems.length * 50;
    if (searchedItems.isNotEmpty) {
      itemHeight = searchedItems.length * 65;
    }

    final size = MediaQuery.of(context).size;
    final buttonSize = button.size;
    final spaceBottom = size.height - buttonPos.dy - buttonSize.height;
    final spaceTop = size.height - buttonPos.dy + buttonSize.height;
    double? maxItemHeight;
    double verticalPosition =
        size.height - (buttonPos.dy + buttonSize.height + itemHeight + 10);
    final useButtom = spaceBottom > itemHeight;
    final useTop = spaceBottom < itemHeight;
    if (useTop) {
      verticalPosition = size.height - (buttonPos.dy);
      if (spaceTop < itemHeight) {
        verticalPosition = 10;
        maxItemHeight =
            size.height < itemHeight ? size.height - 30 : itemHeight.toDouble();
      }
    }
    if (useButtom && spaceBottom < itemHeight) {
      verticalPosition = 10;
      maxItemHeight = spaceBottom < itemHeight && size.height < itemHeight
          ? size.height - 30
          : itemHeight.toDouble();
    }

    final spaceRight = size.width - (buttonPos.dx + buttonSize.width);
    final spaceLeft = buttonPos.dx;
    isCompact = spaceRight < 200 && spaceLeft < 200;

    final offset = (Offset(buttonPos.dx, verticalPosition + 5), maxItemHeight);

    _overlayEntry = _buildOverlayEntry(
      key: _parentGlobalKey,
      horizontalPosition: offset.$1.dx,
      verticalPosition: offset.$1.dy,
      items: widget.menuItems,
      maxItemHeight: offset.$2,
      onRemoveOverlay: () => _clearMenu(),
      onHover: (hoveredItem) {
        if (!isCompact) {
          if (!showingCompact) {
            if (hoveredItem.subMenuItems.isNotEmpty) {
              _showSubMenu(context, hoveredItem);
            } else {
              _removeSubMenu();
            }
          } else {
            showingCompact = false;
          }
        }
      },
      onSelected: (v) {
        if (isCompact) {
          if (v.subMenuItems.isNotEmpty) {
            _showSubMenu(context, v);
          } else {
            _removeSubMenu();
          }
        } else {
          _clearMenu();
          widget.onSelected?.call(v);
        }
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _buildOverlayEntry({
    required double horizontalPosition,
    required double verticalPosition,
    required List<MenuActionItem> items,
    required Function(MenuActionItem)? onHover,
    required Function()? onRemoveOverlay,
    required Function(MenuActionItem)? onSelected,
    double? maxItemHeight,
    Key? key,
    bool isCompact = false,
    MenuActionItem? item,
  }) {
    return OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: onRemoveOverlay,
                behavior: HitTestBehavior.translucent,
                child: Container(),
              ),
            ),
            Positioned(
              left: horizontalPosition,
              bottom: verticalPosition,
              child: AnimatedMenuList(
                key: key,
                compact: widget.compact ?? isCompact,
                horizontalPosition: horizontalPosition,
                verticalPosition: verticalPosition,
                onHover: onHover,
                items: items,
                searchedItems: searchedItems,
                onRemoveOverlay: onRemoveOverlay,
                onSelected: onSelected,
                maxItemHeight: maxItemHeight,
                item: item,
                animationBuilder: widget.animationBuilder,
                backgroundColor: widget.backgroundColor,
                shape: widget.shape,
                menuWidth: widget.menuWidth,
                menuHeight: widget.menuHeight,
                addTitleHeader: widget.addTitleHeader,
                backText: widget.backText,
                headerBuilder: widget.headerBuilder,
                headerStyle: widget.headerStyle,
                menuStyle: widget.menuStyle,
                onTitleSelected: () {
                  widget.onSelected?.call(item);
                  _clearMenu();
                },
                onHeaderTap: () {
                  _showMenu(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearMenu() {
    if (widget.focusNode != null && widget.inputButtonBuilder != null) {
      if (widget.focusNode?.hasFocus != true) {
        _removeSubMenu();
        _removeMenu();
        searchedItems.clear();
      }
    } else {
      _removeSubMenu();
      _removeMenu();
    }
  }

  Future<void> _removeMenu() async {
    _overlayEntry?.remove();
    _overlayEntry = null;
    activeItem = null;
  }

  void _removeSubMenu() {
    _subOverlayEntry?.remove();
    _subOverlayEntry = null;
    activeItem = null;
  }

  void _filterItems(String value) {
    searchedItems.clear();
    if (value.isNotEmpty) {
      final mainSearchedItem = widget.menuItems
          .where((item) => item.title.toLowerCase().contains(value))
          .map((item) => item.copyWith(searchType: SearchType.parent))
          .toList();
      final subSearchedItems = widget.menuItems
          .where((item) =>
              item.subMenuItems.isNotEmpty &&
              item.subMenuItems
                  .any((title) => title.title.toLowerCase().contains(value)))
          .map((item) {
        final subtitleItem = item.subMenuItems.firstWhere(
            (element) => element.title.toLowerCase().contains(value));

        return subtitleItem.copyWith(
          searchType: SearchType.subtitle,
          parentItem: item,
        );
      }).toList();
      searchedItems = [...mainSearchedItem, ...subSearchedItems];
    }
    setState(() {});
    _showMenu(context);
  }

  @override
  void dispose() {
    _clearMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.focusNode != null && widget.inputButtonBuilder != null) {
      return SizedBox(
          key: _globalKey,
          child: widget.inputButtonBuilder!.call(_filterItems));
    }
    return GestureDetector(
      key: _globalKey,
      onTap: () => _showMenu(context),
      child: widget.button ??
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.title!),
          ),
    );
  }
}
