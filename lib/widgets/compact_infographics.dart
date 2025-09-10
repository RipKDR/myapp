import 'package:flutter/material.dart';

/// Minimal, professional compact infographics widgets

class MiniKpiBar extends StatelessWidget {
  const MiniKpiBar({super.key, required this.kpis});
  final List<_Kpi> kpis;

  @override
  Widget build(final BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: kpis.map((final k) => _MiniKpi(k: k)).toList(),
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({required this.k});
  final _Kpi k;
  @override
  Widget build(final BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: k.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(k.icon, size: 16, color: k.color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k.value,
                style: text.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700, color: k.color)),
            Text(k.label,
                style: text.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}

class _Kpi {
  _Kpi(this.icon, this.value, this.label, this.color);
  final IconData icon;
  final String value;
  final String label;
  final Color color;
}

class CompactTimeline extends StatelessWidget {
  const CompactTimeline({super.key, required this.entries});
  final List<TimelineEntry> entries;

  @override
  Widget build(final BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: entries.map((final e) => _TimelineRow(entry: e)).toList(),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});
  final TimelineEntry entry;
  @override
  Widget build(final BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: entry.color, shape: BoxShape.circle),
              ),
              Container(
                width: 2,
                height: 16,
                color: entry.color.withValues(alpha: 0.25),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title,
                    style:
                        text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                if (entry.subtitle != null)
                  Text(entry.subtitle!,
                      style: text.labelSmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text(entry.trailing ?? '',
              style: text.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class TimelineEntry {
  const TimelineEntry(
      {required this.title, this.subtitle, this.trailing, required this.color});
  final String title;
  final String? subtitle;
  final String? trailing;
  final Color color;
}
