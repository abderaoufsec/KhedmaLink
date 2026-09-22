import 'package:flutter/material.dart';

import '../utils/responsive_utils.dart' show ResponsiveUtils, ScreenSize;

/// Responsive builder widget that adapts layout based on screen size
///
/// Provides different widgets for mobile, tablet, and desktop screen sizes.
/// Supports both width-based and height-based responsive design.
class ResponsiveBuilder extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? mobileLandscape;
  final Widget? tabletLandscape;
  final Widget? desktopLandscape;

  const ResponsiveBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.mobileLandscape,
    this.tabletLandscape,
    this.desktopLandscape,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen size category
        final screenSize = ResponsiveUtils.getScreenSize(constraints.maxWidth);
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        // Return appropriate widget based on screen size and orientation
        if (isLandscape) {
          switch (screenSize) {
            case ScreenSize.mobile:
              return mobileLandscape ?? mobile ?? const SizedBox.shrink();
            case ScreenSize.tablet:
              return tabletLandscape ??
                  tablet ??
                  mobile ??
                  const SizedBox.shrink();
            case ScreenSize.desktop:
              return desktopLandscape ??
                  desktop ??
                  tablet ??
                  mobile ??
                  const SizedBox.shrink();
          }
        } else {
          switch (screenSize) {
            case ScreenSize.mobile:
              return mobile ?? const SizedBox.shrink();
            case ScreenSize.tablet:
              return tablet ?? mobile ?? const SizedBox.shrink();
            case ScreenSize.desktop:
              return desktop ?? tablet ?? mobile ?? const SizedBox.shrink();
          }
        }
      },
    );
  }
}

/// Responsive layout builder for adaptive layouts
///
/// Provides more granular control over responsive layouts
/// with custom breakpoints and callbacks.
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;

  const ResponsiveLayout({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }
}

/// Responsive padding widget
///
/// Automatically adjusts padding based on screen size
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ResponsiveUtils.getScreenSize(constraints.maxWidth);

        EdgeInsets padding;
        switch (screenSize) {
          case ScreenSize.mobile:
            padding = mobilePadding ?? const EdgeInsets.all(16.0);
            break;
          case ScreenSize.tablet:
            padding = tabletPadding ?? const EdgeInsets.all(24.0);
            break;
          case ScreenSize.desktop:
            padding = desktopPadding ?? const EdgeInsets.all(32.0);
            break;
        }

        return Padding(padding: padding, child: child);
      },
    );
  }
}

/// Responsive container with max width
///
/// Centers content and applies max width based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ResponsiveUtils.getScreenSize(constraints.maxWidth);

        // Default max widths based on screen size
        final defaultMaxWidth = switch (screenSize) {
          ScreenSize.mobile => double.infinity,
          ScreenSize.tablet => 800.0,
          ScreenSize.desktop => 1200.0,
        };

        final effectiveMaxWidth = maxWidth ?? defaultMaxWidth;
        final effectivePadding = padding ?? _getDefaultPadding(screenSize);

        return Container(
          alignment: alignment,
          padding: effectivePadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
            child: child,
          ),
        );
      },
    );
  }

  EdgeInsets _getDefaultPadding(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.symmetric(horizontal: 16.0);
      case ScreenSize.tablet:
        return const EdgeInsets.symmetric(horizontal: 24.0);
      case ScreenSize.desktop:
        return const EdgeInsets.symmetric(horizontal: 32.0);
    }
  }
}

/// Responsive grid layout
///
/// Automatically adjusts number of columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ResponsiveUtils.getScreenSize(constraints.maxWidth);

        // Default columns based on screen size
        final columns = switch (screenSize) {
          ScreenSize.mobile => mobileColumns ?? 1,
          ScreenSize.tablet => tabletColumns ?? 2,
          ScreenSize.desktop => desktopColumns ?? 3,
        };

        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        );
      },
    );
  }
}

/// Responsive flex layout
///
/// Automatically adjusts flex direction and spacing based on screen size
class ResponsiveFlex extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;
  final bool? wrapOnMobile;
  final bool? wrapOnTablet;
  final bool? wrapOnDesktop;

  const ResponsiveFlex({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 16.0,
    this.wrapOnMobile,
    this.wrapOnTablet,
    this.wrapOnDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = ResponsiveUtils.getScreenSize(constraints.maxWidth);

        // Determine if should wrap based on screen size
        final shouldWrap = switch (screenSize) {
          ScreenSize.mobile => wrapOnMobile ?? true,
          ScreenSize.tablet => wrapOnTablet ?? false,
          ScreenSize.desktop => wrapOnDesktop ?? false,
        };

        if (shouldWrap) {
          // Use Wrap widget for smaller screens
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          );
        } else {
          // Use Row for larger screens
          return Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: _addSpacing(children, spacing),
          );
        }
      },
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }
    return spacedChildren;
  }
}
