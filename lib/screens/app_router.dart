import 'package:flutter/material.dart';

import 'link_wallet_screen.dart';
import 'main_shell.dart';
import 'welcome_screen.dart';

enum _Stage { welcome, linkWallet, main }

/// Root navigator for the real app flow:
///   WelcomeScreen → LinkWalletScreen → MainShell
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  _Stage _stage = _Stage.welcome;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      child: switch (_stage) {
        _Stage.welcome => WelcomeScreen(
            key: const ValueKey('welcome'),
            onStart: () => setState(() => _stage = _Stage.linkWallet),
          ),
        _Stage.linkWallet => LinkWalletScreen(
            key: const ValueKey('linkWallet'),
            onBack: () => setState(() => _stage = _Stage.welcome),
            onContinue: () => setState(() => _stage = _Stage.main),
          ),
        _Stage.main => const MainShell(key: ValueKey('main')),
      },
    );
  }
}
