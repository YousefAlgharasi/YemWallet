import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/icon_btn_box.dart';
import '../widgets/yp_status_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final settings = context.watch<AppSettings>();
    final isAr = settings.lang == AppLang.ar;

    return ColoredBox(
      color: pal.bg0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const YpStatusBar(),

          // Header
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
            child: Row(
              children: [
                IconBtnBox(
                  size: 36,
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    isAr
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isAr ? 'الإعدادات' : 'Settings',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: pal.text1,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Appearance ─────────────────────────
                  _SectionHeader(label: isAr ? 'المظهر' : 'Appearance'),
                  const SizedBox(height: 10),
                  _SettingCard(children: [
                    _SegRow(
                      label: isAr ? 'السمة' : 'Theme',
                      options: [
                        isAr ? 'داكن' : 'Dark',
                        isAr ? 'فاتح' : 'Light',
                      ],
                      selected: settings.theme == AppThemeMode.dark ? 0 : 1,
                      onSelect: (i) => settings.setTheme(
                          i == 0 ? AppThemeMode.dark : AppThemeMode.light),
                    ),
                    _Divider(),
                    _SegRow(
                      label: isAr ? 'اللغة' : 'Language',
                      options: ['English', 'العربية'],
                      selected: settings.lang == AppLang.en ? 0 : 1,
                      onSelect: (i) =>
                          settings.setLang(i == 0 ? AppLang.en : AppLang.ar),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Display ────────────────────────────
                  _SectionHeader(label: isAr ? 'العرض' : 'Display'),
                  const SizedBox(height: 10),
                  _SettingCard(children: [
                    _SegRow(
                      label: isAr ? 'العملة' : 'Currency',
                      options: ['YER', 'SAR', 'USD'],
                      selected: settings.displayCcy.index,
                      onSelect: (i) =>
                          settings.setDisplayCcy(DisplayCurrency.values[i]),
                    ),
                    _Divider(),
                    _SegRow(
                      label: isAr ? 'الكثافة' : 'Density',
                      options: [
                        isAr ? 'مضغوط' : 'Compact',
                        isAr ? 'عادي' : 'Regular',
                        isAr ? 'مريح' : 'Comfy',
                      ],
                      selected: settings.density.index,
                      onSelect: (i) =>
                          settings.setDensity(Density.values[i]),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Dashboard ──────────────────────────
                  _SectionHeader(
                      label: isAr ? 'لوحة التحكم' : 'Dashboard'),
                  const SizedBox(height: 10),
                  _SettingCard(children: [
                    _SegRow(
                      label: isAr ? 'التخطيط' : 'Layout',
                      options: [
                        isAr ? 'بطاقات' : 'Card',
                        isAr ? 'بسيط' : 'Minimal',
                      ],
                      selected: settings.dashboardLayout.index,
                      onSelect: (i) => settings
                          .setDashboardLayout(DashboardLayout.values[i]),
                    ),
                    _Divider(),
                    _SegRow(
                      label: isAr ? 'واجهة التقسيم' : 'Split UI',
                      options: [
                        isAr ? 'شرائح' : 'Sliders',
                        isAr ? 'أجزاء' : 'Segmented',
                      ],
                      selected: settings.splitVariant.index,
                      onSelect: (i) =>
                          settings.setSplitVariant(SplitVariant.values[i]),
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // App version
                  Center(
                    child: Text(
                      'YemenPay v1.0',
                      style: TextStyle(fontSize: 12, color: pal.text3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: pal.text3,
        letterSpacing: 0.66,
      ),
    );
  }
}

// ─── Card container ───────────────────────────────────────────

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

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

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 0.5, color: context.pal.border);
  }
}

// ─── Segmented setting row ────────────────────────────────────

class _SegRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelect;

  const _SegRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: pal.text1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: pal.bg2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: pal.border, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < options.length; i++)
                  _SegChip(
                    label: options[i],
                    isActive: selected == i,
                    onTap: () => onSelect(i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Material(
      color: isActive ? AppBrand.lime : Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? pal.textOnLime : pal.text2,
            ),
          ),
        ),
      ),
    );
  }
}
