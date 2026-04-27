import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/app_settings.dart';

/// Floating runtime-customization panel. Collapses to a small "Tweaks"
/// pill in the corner and expands to a card with all settings rows.
/// Intended to be placed inside a [Stack] by the caller (the [HomeShell]
/// positions it in the bottom-right).
class TweaksPanel extends StatefulWidget {
  const TweaksPanel({super.key});

  @override
  State<TweaksPanel> createState() => _TweaksPanelState();
}

class _TweaksPanelState extends State<TweaksPanel> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Material(
      elevation: 12,
      color: const Color(0xF2FAF9F7),
      borderRadius: BorderRadius.circular(14),
      shadowColor: Colors.black.withOpacity(0.18),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: _open
            ? _ExpandedPanel(
                settings: settings,
                onClose: () => setState(() => _open = false),
              )
            : _CollapsedPill(
                onTap: () => setState(() => _open = true),
              ),
      ),
    );
  }
}

class _CollapsedPill extends StatelessWidget {
  final VoidCallback onTap;
  const _CollapsedPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 14, color: Color(0xFF29261B)),
            SizedBox(width: 8),
            Text(
              'Tweaks',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF29261B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedPanel extends StatelessWidget {
  final AppSettings settings;
  final VoidCallback onClose;

  const _ExpandedPanel({required this.settings, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tweaks',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF29261B),
                    ),
                  ),
                ),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Color(0xFF29261B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable settings body
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Section(label: 'Display'),
                  const SizedBox(height: 8),
                  _RadioRow<AppThemeMode>(
                    label: 'Theme',
                    value: settings.theme,
                    options: const [
                      _Option(AppThemeMode.dark, 'Dark'),
                      _Option(AppThemeMode.light, 'Light'),
                    ],
                    onChange: settings.setTheme,
                  ),
                  const SizedBox(height: 10),
                  _RadioRow<AppLang>(
                    label: 'Language',
                    value: settings.lang,
                    options: const [
                      _Option(AppLang.en, 'EN'),
                      _Option(AppLang.ar, 'AR (RTL)'),
                    ],
                    onChange: settings.setLang,
                  ),
                  const SizedBox(height: 10),
                  _SelectRow<DisplayCurrency>(
                    label: 'Display currency',
                    value: settings.displayCcy,
                    options: const [
                      _Option(DisplayCurrency.yer, 'YER · ر.ي'),
                      _Option(DisplayCurrency.sar, 'SAR · ر.س'),
                      _Option(DisplayCurrency.usd, 'USD · \$'),
                    ],
                    onChange: settings.setDisplayCcy,
                  ),
                  const SizedBox(height: 10),
                  _RadioRow<Density>(
                    label: 'Density',
                    value: settings.density,
                    options: const [
                      _Option(Density.compact, 'Compact'),
                      _Option(Density.regular, 'Regular'),
                      _Option(Density.comfy, 'Comfy'),
                    ],
                    onChange: settings.setDensity,
                  ),
                  const SizedBox(height: 14),
                  const _Section(label: 'Variants'),
                  const SizedBox(height: 8),
                  _RadioRow<DashboardLayout>(
                    label: 'Dashboard',
                    value: settings.dashboardLayout,
                    options: const [
                      _Option(DashboardLayout.card, 'Card'),
                      _Option(DashboardLayout.minimal, 'Editorial'),
                    ],
                    onChange: settings.setDashboardLayout,
                  ),
                  const SizedBox(height: 10),
                  _RadioRow<SplitVariant>(
                    label: 'Split UX',
                    value: settings.splitVariant,
                    options: const [
                      _Option(SplitVariant.sliders, 'Sliders'),
                      _Option(SplitVariant.segmented, 'Segmented %'),
                    ],
                    onChange: settings.setSplitVariant,
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

class _Section extends StatelessWidget {
  final String label;
  const _Section({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0x73291B26),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Option<T> {
  final T value;
  final String label;
  const _Option(this.value, this.label);
}

// ─── Segmented radio row ─────────────────────────────────────

class _RadioRow<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<_Option<T>> options;
  final ValueChanged<T> onChange;

  const _RadioRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xB7291B26),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 26,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0x0F000000),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              for (final opt in options)
                Expanded(
                  child: Material(
                    color: opt.value == value
                        ? const Color(0xE6FFFFFF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      onTap: () => onChange(opt.value),
                      borderRadius: BorderRadius.circular(6),
                      child: Center(
                        child: Text(
                          opt.label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF29261B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Dropdown select row ─────────────────────────────────────

class _SelectRow<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<_Option<T>> options;
  final ValueChanged<T> onChange;

  const _SelectRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xB7291B26),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0x99FFFFFF),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: const Color(0x1A000000), width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF29261B),
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: Color(0x80000000),
              ),
              items: [
                for (final o in options)
                  DropdownMenuItem<T>(value: o.value, child: Text(o.label)),
              ],
              onChanged: (v) {
                if (v != null) onChange(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}