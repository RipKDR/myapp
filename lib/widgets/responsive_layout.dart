import 'package:flutter/material.dart';

/// Responsive layout system for adaptive UI design across different screen sizes
class ResponsiveLayout extends StatelessWidget {

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
      builder: (final context, final constraints) {
        final breakpoint = ScreenBreakpoint.fromWidth(constraints.maxWidth);

        switch (breakpoint) {
          case ScreenBreakpoint.mobile:
            return mobile;
          case ScreenBreakpoint.tablet:
            return tablet ?? mobile;
          case ScreenBreakpoint.desktop:
            return desktop ?? tablet ?? mobile;
          case ScreenBreakpoint.largeDesktop:
            return largeDesktop ?? desktop ?? tablet ?? mobile;
        }
      },
    );
}

/// Screen breakpoint definitions following Material Design guidelines
enum ScreenBreakpoint {
  mobile, // < 600px
  tablet, // 600px - 1024px
  desktop, // 1024px - 1440px
  largeDesktop; // > 1440px

  static ScreenBreakpoint fromWidth(final double width) {
    if (width < 600) return ScreenBreakpoint.mobile;
    if (width < 1024) return ScreenBreakpoint.tablet;
    if (width < 1440) return ScreenBreakpoint.desktop;
    return ScreenBreakpoint.largeDesktop;
  }

  bool get isMobile => this == ScreenBreakpoint.mobile;
  bool get isTablet => this == ScreenBreakpoint.tablet;
  bool get isDesktop => this == ScreenBreakpoint.desktop;
  bool get isLargeDesktop => this == ScreenBreakpoint.largeDesktop;

  bool get isTabletOrLarger => index >= ScreenBreakpoint.tablet.index;
  bool get isDesktopOrLarger => index >= ScreenBreakpoint.desktop.index;
}

/// Responsive padding that adapts to screen size
class ResponsivePadding extends StatelessWidget {

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;
  final EdgeInsets? largeDesktop;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
      builder: (final context, final constraints) {
        final breakpoint = ScreenBreakpoint.fromWidth(constraints.maxWidth);

        EdgeInsets padding;
        switch (breakpoint) {
          case ScreenBreakpoint.mobile:
            padding = mobile ?? const EdgeInsets.all(16);
            break;
          case ScreenBreakpoint.tablet:
            padding = tablet ?? mobile ?? const EdgeInsets.all(24);
            break;
          case ScreenBreakpoint.desktop:
            padding = desktop ?? tablet ?? mobile ?? const EdgeInsets.all(32);
            break;
          case ScreenBreakpoint.largeDesktop:
            padding = largeDesktop ??
                desktop ??
                tablet ??
                mobile ??
                const EdgeInsets.all(40);
            break;
        }

        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
}

/// Responsive grid that adapts column count based on screen size
class ResponsiveGrid extends StatelessWidget {

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.largeDesktopColumns,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
  });
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? largeDesktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
      builder: (final context, final constraints) {
        final breakpoint = ScreenBreakpoint.fromWidth(constraints.maxWidth);

        int columns;
        switch (breakpoint) {
          case ScreenBreakpoint.mobile:
            columns = mobileColumns ?? 1;
            break;
          case ScreenBreakpoint.tablet:
            columns = tabletColumns ?? mobileColumns ?? 2;
            break;
          case ScreenBreakpoint.desktop:
            columns = desktopColumns ?? tabletColumns ?? mobileColumns ?? 3;
            break;
          case ScreenBreakpoint.largeDesktop:
            columns = largeDesktopColumns ??
                desktopColumns ??
                tabletColumns ??
                mobileColumns ??
                4;
            break;
        }

        final content = GridView.builder(
          padding: padding,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
          ),
          itemCount: children.length,
          itemBuilder: (final context, final index) => children[index],
        );

        return content;
      },
    );
}

/// Responsive width container that constrains content width on large screens
class ResponsiveContainer extends StatelessWidget {

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.center = true,
    this.padding,
  });
  final Widget child;
  final double? maxWidth;
  final bool center;
  final EdgeInsets? padding;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
      builder: (final context, final constraints) {
        final shouldConstrain =
            maxWidth != null && constraints.maxWidth > maxWidth!;

        Widget content = child;

        if (padding != null) {
          content = Padding(padding: padding!, child: content);
        }

        if (shouldConstrain) {
          content = SizedBox(
            width: maxWidth,
            child: content,
          );

          if (center) {
            content = Center(child: content);
          }
        } else if (padding != null) {
          // Apply padding even when not constraining width
          content = Padding(padding: padding!, child: child);
        }

        return content;
      },
    );
}

/// Utility class for responsive values
class ResponsiveValue<T> {

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;

  T getValue(final BuildContext context) => getValueForWidth(MediaQuery.of(context).size.width);

  T getValueForWidth(final double width) {
    final breakpoint = ScreenBreakpoint.fromWidth(width);

    switch (breakpoint) {
      case ScreenBreakpoint.mobile:
        return mobile;
      case ScreenBreakpoint.tablet:
        return tablet ?? mobile;
      case ScreenBreakpoint.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenBreakpoint.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Extension methods for responsive design
extension ResponsiveContext on BuildContext {
  ScreenBreakpoint get breakpoint => ScreenBreakpoint.fromWidth(MediaQuery.of(this).size.width);

  bool get isMobile => breakpoint.isMobile;
  bool get isTablet => breakpoint.isTablet;
  bool get isDesktop => breakpoint.isDesktop;
  bool get isLargeDesktop => breakpoint.isLargeDesktop;

  bool get isTabletOrLarger => breakpoint.isTabletOrLarger;
  bool get isDesktopOrLarger => breakpoint.isDesktopOrLarger;

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}

/// Responsive text that scales with screen size
class ResponsiveText extends StatelessWidget {

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });
  final String text;
  final TextStyle? style;
  final ResponsiveValue<double>? fontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(final BuildContext context) {
    final responsiveFontSize = fontSize?.getValue(context);

    return Text(
      text,
      style: style?.copyWith(fontSize: responsiveFontSize) ??
          TextStyle(fontSize: responsiveFontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
