import 'dart:math';

import 'package:flutter/material.dart';

class ResponsiveLayout {
  final Size size;

  const ResponsiveLayout(this.size);

  factory ResponsiveLayout.of(BuildContext context) {
    return ResponsiveLayout(MediaQuery.of(context).size);
  }

  double get shortestSide => min(size.width, size.height);

  bool get isMobile => shortestSide < 600;
  bool get isPhonePortrait => isMobile && size.height >= size.width;
  bool get isPhoneLandscape => isMobile && size.width > size.height;
  bool get isTablet => !isMobile && size.width >= 600 && size.width < 1200;
  bool get isDesktop => size.width >= 1200 && size.width < 1920;
  bool get isSmartTV => size.width >= 1920;

  double get screenWidth => size.width;
  double get screenHeight => size.height;

  double get largeScreenScale {
    if (isSmartTV) return (size.width / 1200).clamp(1.75, 2.8).toDouble();
    if (isDesktop) return (size.width / 1200).clamp(1.12, 1.45).toDouble();
    if (isTablet) return (size.width / 800).clamp(1.0, 1.2).toDouble();
    return 1.0;
  }

  double get titleFontSize {
    if (isMobile) return 20.0;
    if (isTablet) return 26.0 * largeScreenScale;
    if (isSmartTV) return 30.0 * largeScreenScale;
    return 24.0 * largeScreenScale;
  }

  double get chipFontSize {
    if (isMobile) return 13.0;
    if (isTablet) return 16.0 * largeScreenScale;
    if (isSmartTV) return 18.0 * largeScreenScale;
    return 16.0 * largeScreenScale;
  }

  double get pointSummaryFontSize {
    if (isPhonePortrait) return 19.0;
    if (isMobile) return 20.0;
    if (isTablet) return 27.0 * largeScreenScale;
    if (isSmartTV) return 32.0 * largeScreenScale;
    return 26.0 * largeScreenScale;
  }

  double get buttonFontSize {
    if (isMobile) return 14.0;
    if (isTablet) return 15.0 * largeScreenScale;
    if (isSmartTV) return 15.0 * largeScreenScale;
    return 13.0 * largeScreenScale;
  }

  double get bodyFontSize {
    if (isMobile) return 12.0;
    if (isTablet) return 14.0 * largeScreenScale;
    if (isSmartTV) return 15.0 * largeScreenScale;
    return 14.0 * largeScreenScale;
  }

  double get tableInputFontSize {
    if (isPhonePortrait) return 18.0;
    if (isMobile) return 19.0;
    if (isSmartTV) return 28.0 * largeScreenScale;
    return 24.0 * largeScreenScale;
  }

  double get tableHeaderFontSize {
    if (isPhonePortrait) return 11.0;
    if (isMobile) return 13.0;
    if (isSmartTV) return 20.0 * largeScreenScale;
    return 16.0 * largeScreenScale;
  }

  double get tableLabelFontSize {
    if (isPhonePortrait) return 12.0;
    if (isMobile) return 14.0;
    if (isSmartTV) return 22.0 * largeScreenScale;
    return 18.0 * largeScreenScale;
  }

  double get moonFontSize {
    if (isPhonePortrait) return 10.0;
    if (isMobile) return 12.0;
    if (isSmartTV) return 12.0 * largeScreenScale;
    return 11.0 * largeScreenScale;
  }

  double get tableMinWidth {
    if (isPhonePortrait) return size.width;
    return max(isDesktop ? 1000.0 : 760.0, size.width);
  }

  double get appPadding {
    if (isMobile) return 8.0;
    if (isTablet) return 12.0 * largeScreenScale;
    if (isSmartTV) return 16.0 * largeScreenScale;
    return 14.0 * largeScreenScale;
  }
}
