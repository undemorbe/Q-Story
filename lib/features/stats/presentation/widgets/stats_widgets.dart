import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';

/// Ornamented section title.
class StatsSection extends StatelessWidget {
  const StatsSection({super.key, required this.title, required this.icon, required this.children, this.trailing});
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Icon(icon, color: context.gold, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title.toUpperCase(),
                style: GoogleFonts.cinzel(
                    color: context.gold, fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.w700)),
          ),
          if (trailing != null) trailing!,
        ]),
        const SizedBox(height: 10),
        ...children,
      ]),
    );
  }
}

/// Labelled number. Text uses ink tokens, never series colours.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.icon, this.hint});
  final String label;
  final String value;
  final IconData? icon;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final tile = GothicCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          if (icon != null) ...[Icon(icon, size: 14, color: context.gold), const SizedBox(width: 6)],
          Expanded(
            child: Text(label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.dim)),
          ),
        ]),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w700, color: context.onBg)),
        ),
      ]),
    );
    return hint == null ? tile : Tooltip(message: hint!, triggerMode: TooltipTriggerMode.tap, child: tile);
  }
}

/// Responsive grid of [StatTile]s.
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.tiles});
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth > 600 ? 4 : (c.maxWidth > 360 ? 3 : 2);
      const gap = 8.0;
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final t in tiles) SizedBox(width: w, child: t)],
      );
    });
  }
}

/// Single-series vertical bar chart with hover/tap tooltip and an optional
/// dashed reference line (e.g. the daily goal).
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.values,
    required this.bottomLabel,
    required this.tooltip,
    this.referenceLine,
    this.labelEvery = 1,
    this.height = 180,
    this.highlightIndex,
  });

  final List<num> values;
  final String Function(int i) bottomLabel;
  final String Function(int i) tooltip;
  final double? referenceLine;
  final int labelEvery;
  final double height;
  final int? highlightIndex;

  @override
  Widget build(BuildContext context) {
    final gold = context.gold;
    final maxV = [
      ...values.map((v) => v.toDouble()),
      referenceLine ?? 0,
      1.0,
    ].reduce((a, b) => a > b ? a : b);
    final ink = Theme.of(context).textTheme.labelSmall?.copyWith(color: context.dim, fontSize: 10);
    return SizedBox(
      height: height,
      child: LayoutBuilder(builder: (context, c) {
        final barW = ((c.maxWidth - 40) / values.length * 0.62).clamp(3.0, 22.0);
        return BarChart(
          BarChartData(
            maxY: maxV * 1.12,
            alignment: BarChartAlignment.spaceBetween,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: maxV / 3,
              getDrawingHorizontalLine: (_) => FlLine(color: context.outlineVar.withValues(alpha: 0.4), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            extraLinesData: referenceLine == null
                ? null
                : ExtraLinesData(horizontalLines: [
                    HorizontalLine(y: referenceLine!, color: context.blood, strokeWidth: 1.5, dashArray: const [6, 4]),
                  ]),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: maxV / 3,
                  getTitlesWidget: (v, meta) =>
                      v == 0 || v >= meta.max ? const SizedBox.shrink() : Text(_compact(v), style: ink),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i % labelEvery != 0 && i != values.length - 1) return const SizedBox.shrink();
                    return Padding(padding: const EdgeInsets.only(top: 4), child: Text(bottomLabel(i), style: ink));
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => context.surfaceVar,
                tooltipBorder: BorderSide(color: context.outlineClr),
                getTooltipItem: (group, _, __, ___) => BarTooltipItem(
                  tooltip(group.x),
                  TextStyle(color: context.onBg, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < values.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: values[i].toDouble(),
                    width: barW,
                    color: highlightIndex == i ? gold : gold.withValues(alpha: 0.65),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ]),
            ],
          ),
        );
      }),
    );
  }

  static String _compact(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v >= 10000 ? 0 : 1)}k';
    return v.toStringAsFixed(0);
  }
}

/// Horizontal labelled bars for a categorical breakdown. Every bar carries
/// its label and value as text, so identity never depends on colour alone.
class BreakdownBars extends StatelessWidget {
  const BreakdownBars({super.key, required this.items});
  final List<BreakdownItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final maxV = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final total = items.fold<num>(0, (s, e) => s + e.value);
    return Column(children: [
      for (final it in items)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Icon(it.icon, size: 16, color: it.color ?? context.gold),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: Text(it.label,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.onBg, fontSize: 13)),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, c) {
                final w = maxV == 0 ? 0.0 : c.maxWidth * (it.value / maxV);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    height: 10,
                    width: w < 4 && it.value > 0 ? 4 : w,
                    decoration: BoxDecoration(
                      color: it.color ?? context.gold,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 64,
              child: Text(
                '${it.value} · ${total == 0 ? 0 : (it.value * 100 / total).round()}%',
                textAlign: TextAlign.right,
                style: TextStyle(color: context.onBg, fontSize: 12, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
          ]),
        ),
    ]);
  }
}

class BreakdownItem {
  const BreakdownItem({required this.label, required this.value, required this.icon, this.color});
  final String label;
  final int value;
  final IconData icon;
  final Color? color;
}

/// Big goal ring for today's steps.
class GoalRing extends StatelessWidget {
  const GoalRing({super.key, required this.ratio, required this.center, required this.caption});
  final double ratio;
  final String center;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 110,
        height: 110,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => CircularProgressIndicator(
                value: v,
                strokeWidth: 9,
                strokeCap: StrokeCap.round,
                color: context.gold,
                backgroundColor: context.outlineVar.withValues(alpha: 0.35),
              ),
            ),
          ),
          FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(center,
                  style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.w700, color: context.onBg)),
            ),
          ),
        ]),
      ),
      const SizedBox(width: 16),
      Expanded(child: Text(caption, style: Theme.of(context).textTheme.bodyMedium)),
    ]);
  }
}
