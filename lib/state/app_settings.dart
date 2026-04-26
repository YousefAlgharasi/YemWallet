import 'package:flutter/foundation.dart';

enum AppThemeMode { dark, light }

enum AppLang { en, ar }

enum DisplayCurrency { yer, sar, usd }

extension DisplayCurrencyX on DisplayCurrency {
  String get code => switch (this) {
        DisplayCurrency.yer => 'YER',
        DisplayCurrency.sar => 'SAR',
        DisplayCurrency.usd => 'USD',
      };

  String get symbol => switch (this) {
        DisplayCurrency.yer => 'ر.ي',
        DisplayCurrency.sar => 'ر.س',
        DisplayCurrency.usd => '\$',
      };
}

enum Density { compact, regular, comfy }

extension DensityX on Density {
  double get factor => switch (this) {
        Density.compact => 0.75,
        Density.regular => 1.0,
        Density.comfy => 1.25,
      };
}

enum DashboardLayout { card, minimal }

enum SplitVariant { sliders, segmented }

class AppSettings extends ChangeNotifier {
  AppThemeMode _theme = AppThemeMode.dark;
  AppLang _lang = AppLang.ar;
  DisplayCurrency _displayCcy = DisplayCurrency.yer;
  Density _density = Density.compact;
  DashboardLayout _dashboardLayout = DashboardLayout.minimal;
  SplitVariant _splitVariant = SplitVariant.sliders;

  AppThemeMode get theme => _theme;
  AppLang get lang => _lang;
  DisplayCurrency get displayCcy => _displayCcy;
  Density get density => _density;
  DashboardLayout get dashboardLayout => _dashboardLayout;
  SplitVariant get splitVariant => _splitVariant;

  bool get isAr => _lang == AppLang.ar;
  bool get isDark => _theme == AppThemeMode.dark;

  void setTheme(AppThemeMode v) {
    if (v == _theme) return;
    _theme = v;
    notifyListeners();
  }

  void setLang(AppLang v) {
    if (v == _lang) return;
    _lang = v;
    notifyListeners();
  }

  void setDisplayCcy(DisplayCurrency v) {
    if (v == _displayCcy) return;
    _displayCcy = v;
    notifyListeners();
  }

  void setDensity(Density v) {
    if (v == _density) return;
    _density = v;
    notifyListeners();
  }

  void setDashboardLayout(DashboardLayout v) {
    if (v == _dashboardLayout) return;
    _dashboardLayout = v;
    notifyListeners();
  }

  void setSplitVariant(SplitVariant v) {
    if (v == _splitVariant) return;
    _splitVariant = v;
    notifyListeners();
  }
}