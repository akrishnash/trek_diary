import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class StatCard extends StatelessWidget {
  final List<StatItem> stats;
  const StatCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: stats.expand((s) sync* {
          if (s != stats.first) yield Container(width: 1, color: AppColors.borderLight);
          yield Expanded(child: _StatCell(item: s));
        }).toList(),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final StatItem item;
  const _StatCell({required this.item});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(item.value, style: AppTextStyles.statValue),
      if (item.sub != null) Text(item.sub!, style: AppTextStyles.label.copyWith(color: AppColors.accent, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(item.label.toUpperCase(), style: AppTextStyles.label.copyWith(color: AppColors.textHint, letterSpacing: 0.8)),
    ],
  );
}

class StatItem {
  final String label;
  final String value;
  final String? sub;
  const StatItem({required this.label, required this.value, this.sub});
}
