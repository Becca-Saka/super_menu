import 'package:flutter/material.dart';

import 'menu_action_item.dart';
import 'menu_wrapper.dart';

class AnimatedMenuList extends StatefulWidget {
  const AnimatedMenuList({
    super.key,
    required this.horizontalPosition,
    required this.verticalPosition,
    required this.items,
    required this.onHover,
    required this.onRemoveOverlay,
    required this.onSelected,
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
  });
  final double horizontalPosition;
  final double verticalPosition;
  final List<MenuActionItem> items;
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

  @override
  State<AnimatedMenuList> createState() => _AnimatedMenuListState();
}

class _AnimatedMenuListState extends State<AnimatedMenuList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> createAnimation;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  static const Curve curve = Curves.easeIn;

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    createAnimation = Tween<Offset>(
      begin: const Offset(0.5, 1.0),
      end: const Offset(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: curve,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    moveAnimation();
  }

  void moveAnimation() {
    if (!_controller.isAnimating) {
      _controller.forward();
    }
  }

  Widget _buildChild() {
    return MenuWrapper(
      scrollController: _scrollController,
      horizontalPosition: widget.horizontalPosition,
      verticalPosition: widget.verticalPosition,
      menuWidth: widget.menuWidth,
      maxItemHeight: widget.maxItemHeight,
      items: widget.items,
      onHover: widget.onHover,
      onRemoveOverlay: widget.onRemoveOverlay,
      onSelected: widget.onSelected,
      compact: widget.compact,
      item: widget.item,
      onHeaderTap: widget.onHeaderTap,
      animationBuilder: widget.animationBuilder,
      menuHeight: widget.menuHeight,
      backgroundColor: widget.backgroundColor,
      shape: widget.shape,
      headerBuilder: widget.headerBuilder,
      backText: widget.backText,
      addTitleHeader: widget.addTitleHeader,
      headerStyle: widget.headerStyle,
      menuStyle: widget.menuStyle,
      onTitleSelected: widget.onTitleSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: widget.backgroundColor,
      shape: widget.shape,
      child: SizedBox(
        height: widget.maxItemHeight,
        width: widget.menuWidth ?? 200,
        child: widget.animationBuilder?.call(_buildChild()) ??
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: child!,
                  ),
                );
              },
              child: _buildChild(),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
