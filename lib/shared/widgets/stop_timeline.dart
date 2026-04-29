import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/stop.dart';

class StopTimeline extends StatelessWidget {
  final List<TrekStop> stops;
  final ValueChanged<TrekStop> onStopTap;

  const StopTimeline({super.key, required this.stops, required this.onStopTap});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connector line + dots column
          SizedBox(
            width: 28,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(top: 16, bottom: 16, child: Container(width: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0x445B8A6E), Color(0x22C17F3E)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                  ),
                )),
                Column(
                  children: stops.asMap().entries.map((e) => Expanded(
                    child: Center(
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: e.key == 0 ? AppColors.accent : AppColors.diffModerate,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.sheet, width: 2),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: stops.map((stop) => GestureDetector(
                onTap: () => onStopTap(stop),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 1))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stop.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 5),
                      Wrap(spacing: 8, children: [
                        _ElevLabel(elev: stop.elevation),
                        if (stop.distance > 0) _DistLabel(dist: stop.distance),
                        if (stop.weather.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFF5F3EE), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                            child: Text(stop.weather, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF7A7570))),
                          ),
                      ]),
                      if (stop.notes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(stop.notes, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElevLabel extends StatelessWidget {
  final int elev;
  const _ElevLabel({required this.elev});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.show_chart, size: 12, color: AppColors.accent),
    const SizedBox(width: 2),
    Text('${elev.toString()}m', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
  ]);
}

class _DistLabel extends StatelessWidget {
  final double dist;
  const _DistLabel({required this.dist});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.arrow_forward, size: 12, color: AppColors.textMuted),
    const SizedBox(width: 2),
    Text('+$dist km', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
  ]);
}
