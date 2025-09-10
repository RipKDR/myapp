import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tokens/spacing.dart';

/// NDIS Connect App Scaffold
/// Provides consistent layout structure with accessibility support
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.showAppBar = true,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final Widget? body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool showAppBar;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              centerTitle: centerTitle,
              automaticallyImplyLeading: automaticallyImplyLeading,
              actions: actions,
              elevation: 0,
              scrolledUnderElevation: 1,
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
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
    );
  }
}

/// App Scaffold with Safe Area
class SafeAppScaffold extends StatelessWidget {
  const SafeAppScaffold({
    super.key,
    required this.title,
    this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.showAppBar = true,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.padding = const EdgeInsets.all(NDISSpacing.screenPadding),
  });

  final String title;
  final Widget? body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool showAppBar;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final EdgeInsets padding;

  @override
  Widget build(final BuildContext context) => AppScaffold(
      title: title,
      actions: actions,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      showAppBar: showAppBar,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      body: SafeArea(
        child: Padding(padding: padding, child: body),
      ),
    );
}
