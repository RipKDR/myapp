import 'package:flutter/material.dart';

/// Google-style navigation bar with clean design and smooth animations
class GoogleNavBar extends StatefulWidget {
  final List<GoogleNavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final double elevation;
  final EdgeInsetsGeometry? margin;

  const GoogleNavBar({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.elevation = 3.0,
    this.margin,
  });

  @override
  State<GoogleNavBar> createState() => _GoogleNavBarState();
}

class _GoogleNavBarState extends State<GoogleNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Animate the initially selected item
    if (widget.selectedIndex < _animationControllers.length) {
      _animationControllers[widget.selectedIndex].forward();
    }
  }

  @override
  void didUpdateWidget(GoogleNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      // Animate out the old selection
      if (oldWidget.selectedIndex < _animationControllers.length) {
        _animationControllers[oldWidget.selectedIndex].reverse();
      }

      // Animate in the new selection
      if (widget.selectedIndex < _animationControllers.length) {
        _animationControllers[widget.selectedIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: widget.elevation * 2,
            offset: Offset(0, -widget.elevation / 2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.selectedIndex;

              return Expanded(
                child: _GoogleNavBarItem(
                  item: item,
                  isSelected: isSelected,
                  animation: _animations[index],
                  onTap: () => widget.onTap?.call(index),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _GoogleNavBarItem extends StatelessWidget {
  final GoogleNavItem item;
  final bool isSelected;
  final Animation<double> animation;
  final VoidCallback? onTap;

  const _GoogleNavBarItem({
    required this.item,
    required this.isSelected,
    required this.animation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with selection indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.secondaryContainer
                            .withOpacity(0.3 + (animation.value * 0.7))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),

                const SizedBox(height: 4),

                // Label with fade animation
                AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.7,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Navigation item data model
class GoogleNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? tooltip;

  const GoogleNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.tooltip,
  });
}

/// Google-style app bar with search functionality
class GoogleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showSearch;
  final VoidCallback? onSearchTap;
  final String? searchHint;
  final bool centerTitle;
  final Widget? leading;
  final double elevation;
  final Color? backgroundColor;

  const GoogleAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.showSearch = false,
    this.onSearchTap,
    this.searchHint = 'Search',
    this.centerTitle = false,
    this.leading,
    this.elevation = 0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      elevation: elevation,
      scrolledUnderElevation: 1,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
      centerTitle: centerTitle,
      leading: leading,
      title: titleWidget ?? (title != null ? Text(title!) : null),
      titleTextStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      actions: [
        if (showSearch)
          IconButton(
            onPressed: onSearchTap,
            icon: const Icon(Icons.search),
            tooltip: searchHint,
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Google-style search bar
class GoogleSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? margin;

  const GoogleSearchBar({
    super.key,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.controller,
    this.margin,
  });

  @override
  State<GoogleSearchBar> createState() => _GoogleSearchBarState();
}

class _GoogleSearchBarState extends State<GoogleSearchBar> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
        border: _isFocused
            ? Border.all(color: colorScheme.primary, width: 2)
            : Border.all(color: colorScheme.outline, width: 1),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: widget.controller?.text.isNotEmpty == true
              ? IconButton(
                  onPressed: () {
                    widget.controller?.clear();
                    widget.onChanged?.call('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
    );
  }
}
