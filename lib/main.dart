import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/app_settings.dart';
import 'theme/app_theme.dart';
import 'screens/app_router.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const YemenPayApp(),
    ),
  );
}

class YemenPayApp extends StatelessWidget {
  const YemenPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return MaterialApp(
      title: 'YemenPay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(settings),
      darkTheme: AppTheme.dark(settings),
      themeMode: settings.theme == AppThemeMode.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      builder: (context, child) {
        final pal = Theme.of(context).extension<AppPalette>()!;
        return Directionality(
          textDirection: settings.lang == AppLang.ar
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: ColoredBox(
            color: pal.bg0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
      home: const AppRouter(),
    );
  }
}