import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/radius.dart';

/// Bottom Navigation Bar Component
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavigationItem>? items;

  static const List<AppNavigationItem> defaultItems = [
    AppNavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
    AppNavigationItem(icon: Icons.account_balance_wallet, label: 'Budget'),
    AppNavigationItem(icon: Icons.calendar_today, label: 'Calendar'),
    AppNavigationItem(icon: Icons.message, label: 'Messages'),
    AppNavigationItem(icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final navigationItems = items ?? defaultItems;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: theme.colorScheme.surface,
      elevation: 3,
      shadowColor: theme.colorScheme.shadow,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      indicatorColor: theme.colorScheme.secondaryContainer,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: navigationItems.map((final item) => NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon ?? item.icon),
          label: item.label,
        )).toList(),
    );
  }
}

/// Navigation Item Model
class AppNavigationItem {
  const AppNavigationItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}

/// Tab Bar Component
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
    this.onTap,
  });

  final List<AppTab> tabs;
  final TabController? controller;
  final bool isScrollable;
  final ValueChanged<int>? onTap;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline, width: 0.5),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs
            .map(
              (final tab) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(tab.icon, size: NDISSpacing.iconSm),
                      const SizedBox(width: NDISSpacing.sm),
                    ],
                    Text(tab.label),
                  ],
                ),
              ),
            )
            .toList(),
        isScrollable: isScrollable,
        onTap: onTap,
        indicatorColor: theme.colorScheme.primary,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelLarge,
        unselectedLabelStyle: theme.textTheme.labelMedium,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 3,
        indicatorPadding: const EdgeInsets.symmetric(
          horizontal: NDISSpacing.md,
        ),
      ),
    );
  }
}

/// Tab Model
class AppTab {
  const AppTab({required this.label, this.icon});

  final String label;
  final IconData? icon;
}

/// Floating Action Button with Navigation
class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
      foregroundColor: foregroundColor ?? theme.colorScheme.onPrimaryContainer,
      elevation: 3,
      highlightElevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NDSRadius.fab),
      ),
      child: Icon(icon, size: NDISSpacing.iconLg),
    );
  }
}

/// App Bar with Actions
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
    this.scrolledUnderElevation = 1,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final double scrolledUnderElevation;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      titleTextStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(
        color: theme.colorScheme.onSurface,
        size: NDISSpacing.iconMd,
      ),
      actionsIconTheme: IconThemeData(
        color: theme.colorScheme.onSurface,
        size: NDISSpacing.iconMd,
      ),
      systemOverlayStyle: theme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
