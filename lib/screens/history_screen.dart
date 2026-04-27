import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/currency.dart';
import '../data/transaction.dart';
import '../state/app_settings.dart';
import '../theme/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/icon_btn_box.dart';
import '../widgets/tx_row.dart';
import '../widgets/yp_status_bar.dart';

enum _HistoryFilter { all, inflow, outflow, split }

/// Unified transaction history — inflow/outflow summary cards,
/// filter chips, date-grouped log of all transactions across wallets.
class HistoryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const HistoryScreen({super.key, this.onBack});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryFilter _filter = _HistoryFilter.all;

  bool _matches(Transaction tx) {
    return switch (_filter) {
      _HistoryFilter.all => true,
      _HistoryFilter.inflow => tx is TransferInTx,
      _HistoryFilter.outflow => tx is TransferOutTx,
      _HistoryFilter.split => tx is SplitOutTx,
    };
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final settings = context.watch<AppSettings>();
    final lang = settings.lang;
    final displayCcy = settings.displayCcy;
    final isAr = lang == AppLang.ar;

    final filtered = kTransactions.where(_matches).toList();

    // Group by ISO date string, preserving insertion order.
    final groups = <String, List<Transaction>>{};
    for (final tx in filtered) {
      groups.putIfAbsent(tx.date, () => []).add(tx);
    }

    // Aggregate inflow/outflow over the full unfiltered list.
    final inflow = kTransactions
        .whereType<TransferInTx>()
        .fold<double>(0, (s, tx) => s + tx.amountYer);
    final outflow = kTransactions
        .where((tx) => tx is! TransferInTx && tx is! WalletLinkTx)
        .fold<double>(0, (s, tx) => s + tx.amountYer);

    return ColoredBox(
      color: pal.bg0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const YpStatusBar(),

          // Header — back · title · search
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconBtnBox(
                  size: 36,
                  onTap: widget.onBack,
                  child: Icon(
                    isAr
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    size: 20,
                  ),
                ),
                Text(
                  S.t('history_title', lang),
                  style: sansStyle(
                    lang,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: pal.text1,
                  ),
                ),
                IconBtnBox(
                  size: 36,
                  onTap: () {},
                  child: const Icon(Icons.search_rounded, size: 18),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Inflow / Outflow summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _FlowCard(
                          label: S.t('inflow', lang),
                          amount:
                              '+${fmtMoney(convertCcy(inflow, DisplayCurrency.yer, displayCcy), displayCcy, lang)}',
                          ccy: displayCcy,
                          lang: lang,
                          color: AppBrand.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FlowCard(
                          label: S.t('outflow', lang),
                          amount:
                              '−${fmtMoney(convertCcy(outflow, DisplayCurrency.yer, displayCcy), displayCcy, lang)}',
                          ccy: displayCcy,
                          lang: lang,
                          color: pal.text1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Filter chips (horizontal scroll)
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      children: [
                        _FilterChip(
                          label: S.t('all', lang),
                          isActive: _filter == _HistoryFilter.all,
                          onTap: () => setState(
                              () => _filter = _HistoryFilter.all),
                        ),
                        const SizedBox(width: 6),
                        _FilterChip(
                          label: S.t('in', lang),
                          isActive: _filter == _HistoryFilter.inflow,
                          onTap: () => setState(
                              () => _filter = _HistoryFilter.inflow),
                        ),
                        const SizedBox(width: 6),
                        _FilterChip(
                          label: S.t('out', lang),
                          isActive: _filter == _HistoryFilter.outflow,
                          onTap: () => setState(
                              () => _filter = _HistoryFilter.outflow),
                        ),
                        const SizedBox(width: 6),
                        _FilterChip(
                          label: S.t('split', lang),
                          isActive: _filter == _HistoryFilter.split,
                          onTap: () => setState(
                              () => _filter = _HistoryFilter.split),
                        ),
                        const SizedBox(width: 6),
                        _FilterChip(
                          label: S.t('filters', lang),
                          isActive: false,
                          leading: const Icon(Icons.tune_rounded, size: 14),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date-grouped tx list
                  for (final entry in groups.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                      child: Text(
                        _formatDate(entry.key, lang),
                        style: sansStyle(
                          lang,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: pal.text3,
                          letterSpacing: 0.66,
                        ),
                      ),
                    ),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: pal.bgCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: pal.border, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < entry.value.length; i++)
                            TxRow(
                              tx: entry.value[i],
                              lang: lang,
                              displayCcy: displayCcy,
                              isLast: i == entry.value.length - 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hand-rolled localized date label — avoids needing intl date locale data.
  String _formatDate(String iso, AppLang lang) {
    const today = '2026-04-26';
    if (iso == today) return S.t('today', lang).toUpperCase();

    final date = DateTime.parse(iso);
    const weekdaysEn = [
      'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY',
      'FRIDAY', 'SATURDAY', 'SUNDAY',
    ];
    const weekdaysAr = [
      'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
      'الجمعة', 'السبت', 'الأحد',
    ];
    const monthsEn = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    const monthsAr = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];

    final weekdayIdx = date.weekday - 1; // DateTime.weekday: Mon=1..Sun=7
    final monthIdx = date.month - 1;

    if (lang == AppLang.ar) {
      return '${weekdaysAr[weekdayIdx]}، ${date.day} ${monthsAr[monthIdx]}';
    }
    return '${weekdaysEn[weekdayIdx]}, ${monthsEn[monthIdx]} ${date.day}';
  }
}

class _FlowCard extends StatelessWidget {
  final String label;
  final String amount;
  final DisplayCurrency ccy;
  final AppLang lang;
  final Color color;

  const _FlowCard({
    required this.label,
    required this.amount,
    required this.ccy,
    required this.lang,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: pal.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pal.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: sansStyle(
              lang,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: pal.text3,
              letterSpacing: 0.66,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -0.02 * 22,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            '${ccy.code} · ${S.t('last_5_days', lang)}',
            style: sansStyle(lang, fontSize: 11, color: pal.text3),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Widget? leading;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lang = context.read<AppSettings>().lang;
    final fg = isActive ? pal.bg0 : pal.text2;
    final bg = isActive ? pal.text1 : Colors.transparent;
    final border =
        isActive ? null : Border.all(color: pal.border, width: 0.5);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(color: fg, size: 14),
                  child: leading!,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: sansStyle(
                  lang,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}