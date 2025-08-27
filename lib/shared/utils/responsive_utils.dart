import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Check device type
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  // Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  // Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      // Very small phones
      return baseFontSize * 0.85;
    } else if (screenWidth < mobileBreakpoint) {
      // Regular mobile phones
      return baseFontSize;
    } else if (screenWidth < desktopBreakpoint) {
      // Tablets
      return baseFontSize * 1.1;
    } else {
      // Desktop
      return baseFontSize * 1.2;
    }
  }

  // Get responsive grid count
  static int getGridCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 400) {
      return 1; // Very small screens - single column
    } else if (screenWidth < mobileBreakpoint) {
      return 2; // Mobile - 2 columns
    } else if (screenWidth < desktopBreakpoint) {
      return 3; // Tablet - 3 columns
    } else {
      return 4; // Desktop - 4 columns
    }
  }

  // Get responsive spacing
  static double getResponsiveSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return 8.0;
    } else if (screenWidth < mobileBreakpoint) {
      return 12.0;
    } else if (screenWidth < desktopBreakpoint) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  // Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenHeight < 600) {
      return 45.0; // Shorter screens
    } else if (screenHeight < 800) {
      return 50.0; // Normal screens
    } else {
      return 55.0; // Tall screens
    }
  }

  // Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return baseSize * 0.8;
    } else if (screenWidth < mobileBreakpoint) {
      return baseSize;
    } else {
      return baseSize * 1.2;
    }
  }

  // Get responsive container width
  static double getResponsiveWidth(BuildContext context, double percentage) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * percentage;
  }

  // Get responsive container height
  static double getResponsiveHeight(BuildContext context, double percentage) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * percentage;
  }

  // Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
    );
  }

  // Get dynamic app bar height
  static double getAppBarHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenHeight < 600) {
      return 50.0;
    } else if (screenHeight < 800) {
      return 56.0;
    } else {
      return 60.0;
    }
  }
}

// Extension to make responsive utilities easier to use
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  EdgeInsets get responsivePadding =>
      ResponsiveUtils.getResponsivePadding(this);
  EdgeInsets get responsiveMargin => ResponsiveUtils.getResponsiveMargin(this);
  double get responsiveSpacing => ResponsiveUtils.getResponsiveSpacing(this);
  double get responsiveButtonHeight =>
      ResponsiveUtils.getResponsiveButtonHeight(this);

  double responsiveFontSize(double baseSize) =>
      ResponsiveUtils.getResponsiveFontSize(this, baseSize);
  double responsiveIconSize(double baseSize) =>
      ResponsiveUtils.getResponsiveIconSize(this, baseSize);
  double responsiveWidth(double percentage) =>
      ResponsiveUtils.getResponsiveWidth(this, percentage);
  double responsiveHeight(double percentage) =>
      ResponsiveUtils.getResponsiveHeight(this, percentage);
}
