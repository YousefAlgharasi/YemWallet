import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/yp_logo.dart';
import '../widgets/yp_tab_bar.dart';
import 'checkout/checkout_flow.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'link_wallet_screen.dart';
import 'receive_screen.dart';
import 'send_screen.dart';
import 'settings_screen.dart';
import 'split_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  YpTab _tab = YpTab.home;

  void _onAction(String tag) {
    switch (tag) {
      case 'send':
        _push(SendScreen(
          onBack: () => Navigator.pop(context),
          onSent: () => Navigator.pop(context),
        ));
      case 'receive':
      case 'qr':
        _push(const ReceiveScreen());
      case 'split':
        _pushSplit();
      case 'scan':
        _push(CheckoutFlow(onExit: () => Navigator.pop(context)));
      case 'settings':
        _push(const SettingsScreen());
      case 'addWallet':
        _push(LinkWalletScreen(
          onBack: () => Navigator.pop(context),
          onContinue: () => Navigator.pop(context),
        ));
      case 'history':
        setState(() => _tab = YpTab.history);
      case 'home':
        setState(() => _tab = YpTab.home);
      case 'stores':
        setState(() => _tab = YpTab.stores);
      case 'profile':
        setState(() => _tab = YpTab.profile);
    }
  }

  void _pushSplit() {
    _push(SplitScreen(
      onBack: () => Navigator.pop(context),
      onConfirm: () => Navigator.pop(context),
    ));
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _body() {
    return switch (_tab) {
      YpTab.home => DashboardScreen(
          showTabBar: false,
          onAction: _onAction,
        ),
      YpTab.history => HistoryScreen(
          onBack: () => setState(() => _tab = YpTab.home),
        ),
      YpTab.stores => const _StoresScreen(),
      YpTab.profile =>
        _ProfileScreen(onSettings: () => _push(const SettingsScreen())),
    };
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Scaffold(
      backgroundColor: pal.bg0,
      body: _body(),
      bottomNavigationBar: YpTabBar(
        active: _tab,
        onTap: (t) => setState(() => _tab = t),
        onSplitTap: _pushSplit,
      ),
    );
  }
}

// ─── Stores ───────────────────────────────────────────────────

class _StoresScreen extends StatelessWidget {
  const _StoresScreen();

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final isAr = context.watch<AppSettings>().lang == AppLang.ar;
    return ColoredBox(
      color: pal.bg0,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: pal.bg2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: pal.border, width: 0.5),
                  ),
                  child: Icon(Icons.storefront_outlined,
                      size: 28, color: pal.text3),
                ),
                const SizedBox(height: 16),
                Text(
                  isAr ? 'قريباً' : 'Coming soon',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: pal.text1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr
                      ? 'تصفح المتاجر المحلية وادفع في خطوة واحدة.'
                      : 'Browse local merchants and pay in one tap.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 14, color: pal.text3, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Profile ──────────────────────────────────────────────────

class _ProfileScreen extends StatelessWidget {
  final VoidCallback onSettings;
  const _ProfileScreen({required this.onSettings});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final isAr = context.watch<AppSettings>().lang == AppLang.ar;

    return ColoredBox(
      color: pal.bg0,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: pal.bg2,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: pal.border, width: 0.5),
                      ),
                      child: Text(
                        'OA',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: pal.text1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isAr ? 'عمر' : 'Omar',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: pal.text1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppBrand.success,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAr ? '٣ محافظ مرتبطة' : '3 wallets linked',
                          style:
                              TextStyle(fontSize: 13, color: pal.text3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _MenuCard(children: [
                _MenuRow(
                  icon: Icons.settings_outlined,
                  label: isAr ? 'الإعدادات' : 'Settings',
                  onTap: onSettings,
                ),
                Container(height: 0.5, color: pal.border),
                _MenuRow(
                  icon: Icons.shield_outlined,
                  label: isAr ? 'الأمان والخصوصية' : 'Security & Privacy',
                  onTap: () {},
                ),
                Container(height: 0.5, color: pal.border),
                _MenuRow(
                  icon: Icons.help_outline_rounded,
                  label: isAr ? 'المساعدة' : 'Help & Support',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 12),
              _MenuCard(children: [
                _MenuRow(
                  icon: Icons.logout_rounded,
                  label: isAr ? 'تسجيل الخروج' : 'Sign out',
                  color: AppBrand.danger,
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const YpLogo(size: 18),
                    const SizedBox(width: 8),
                    Text('YemenPay v1.0',
                        style:
                            TextStyle(fontSize: 12, color: pal.text3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: pal.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pal.border, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final fg = color ?? pal.text1;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: pal.text3),
            ],
          ),
        ),
      ),
    );
  }
}
