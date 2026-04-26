import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_settings.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';

enum YpTab { home, history, stores, profile }

/// 78px tall bottom tab bar with a floating lime "Split" button that
/// hangs 22px above the bar (covering the dashboard's center slot).
class YpTabBar extends StatelessWidget {
  final YpTab active;
  final ValueChanged<YpTab> onTap;
  final VoidCallback onSplitTap;

  const YpTabBar({
    super.key,
    required this.active,
    required this.onTap,
    required this.onSplitTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lang = context.watch<AppSettings>().lang;

    final items = <_TabItem>[
      _TabItem(YpTab.home, Icons.home_outlined, S.t('home', lang)),
      _TabItem(YpTab.history, Icons.access_time_rounded, S.t('history', lang)),
      const _TabItem(null, null, ''), // placeholder for floating lime button
      _TabItem(YpTab.stores, Icons.storefront_outlined, S.t('stores', lang)),
      _TabItem(YpTab.profile, Icons.person_outline_rounded, S.t('profile', lang)),
    ];

    return SizedBox(
      height: 78,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tab bar background
          Container(
            decoration: BoxDecoration(
              color: pal.bg1,
              border: Border(
                top: BorderSide(color: pal.border, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                for (final item in items)
                  Expanded(
                    child: item.tab == null
                        ? const SizedBox.shrink()
                        : _TabItemView(
                            item: item,
                            isActive: active == item.tab,
                            onTap: () => onTap(item.tab!),
                          ),
                  ),
              ],
            ),
          ),

          // Floating lime split button
          Positioned(
            top: -22,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onSplitTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppBrand.lime,
                    border: Border.all(color: pal.bg1, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppBrand.lime.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.alt_route_rounded,
                    size: 24,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  final YpTab? tab;
  final IconData? icon;
  final String label;
  const _TabItem(this.tab, this.icon, this.label);
}

class _TabItemView extends StatelessWidget {
  final _TabItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItemView({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final color = isActive ? pal.text1 : pal.text3;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}