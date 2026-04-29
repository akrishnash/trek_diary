import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/diff_badge.dart';
import '../../../shared/widgets/glass.dart';
import '../../../shared/widgets/primary_button.dart';

class SummaryScreen extends ConsumerWidget {
  final String trekId;
  const SummaryScreen({super.key, required this.trekId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treks = ref.watch(trekListProvider);
    final trek  = treks.firstWhere((t) => t.id == trekId);
    final size  = MediaQuery.of(context).size;
    final safe  = MediaQuery.of(context).padding;
    final sheetAt = size.height * 0.52;

    // Aggregate stats
    final allStops  = trek.days.expand((d) => d.stops).toList();
    final maxElev   = allStops.isEmpty ? 0
        : allStops.map((s) => s.elevation).reduce((a, b) => a > b ? a : b);
    final minElev   = allStops.isEmpty ? 0
        : allStops.map((s) => s.elevation).reduce((a, b) => a < b ? a : b);
    final elevGain  = maxElev - minElev;
    final totalDist = allStops.fold(0.0, (sum, s) => sum + s.distance);

    return Scaffold(
      backgroundColor: AppColors.heroDark,
      body: Stack(
        children: [
          // ── Photo ──────────────────────────────────────────────────────────
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: getTrekPhotoUrl(trek),
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.3),
              placeholder: (_, __) => const ColoredBox(color: AppColors.heroDark),
              errorWidget:  (_, __, ___) => const ColoredBox(color: AppColors.heroDark),
            ),
          ),

          // ── Scrim ──────────────────────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x88000000), Color(0x00000000), Color(0xF00D1A0D)],
                  stops: [0.0, 0.30, 0.65],
                ),
              ),
            ),
          ),

          // ── Back ───────────────────────────────────────────────────────────
          Positioned(
            top: safe.top + 12, left: 16,
            child: GlassBackButton(onPressed: () => context.pop()),
          ),

          // ── TIDE editorial hero area ────────────────────────────────────────
          // Pattern from TIDE screen 2: giant editorial number → label → name → sub
          Positioned(
            left: 26, right: 26,
            bottom: size.height - sheetAt + 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  DiffBadge(difficulty: trek.difficulty),
                  const SizedBox(width: 10),
                  Text('SUMMARY', style: AppTextStyles.eyebrow),
                ]),
                const SizedBox(height: 14),

                // Primary editorial stat — days logged
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trek.daysLogged.toString().padLeft(2, '0'),
                      style: GoogleFonts.poppins(
                        fontSize: 80, fontWeight: FontWeight.w100,
                        color: Colors.white, height: 1.0, letterSpacing: -3,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 8),
                      child: Text(
                        '/ ${trek.totalDays}\nDAYS',
                        style: AppTextStyles.eyebrow.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(trek.name, style: AppTextStyles.heroHeading.copyWith(
                  fontSize: 28, fontWeight: FontWeight.w300,
                )),
                const SizedBox(height: 4),
                Text(trek.region, style: AppTextStyles.heroSubtitle),
              ],
            ),
          ),

          // ── Stats sheet ────────────────────────────────────────────────────
          Positioned(
            top: sheetAt, left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.sheet,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Big stats grid
                      Row(children: [
                        _StatTile(
                          value: allStops.isEmpty ? '—' : '${maxElev}m',
                          label: 'Max Elevation',
                          icon: Icons.landscape_rounded,
                        ),
                        const SizedBox(width: 12),
                        _StatTile(
                          value: allStops.isEmpty ? '—' : '${elevGain}m',
                          label: 'Elev. Gain',
                          icon: Icons.trending_up_rounded,
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        _StatTile(
                          value: totalDist > 0 ? '${totalDist.toStringAsFixed(1)} km' : '—',
                          label: 'Distance',
                          icon: Icons.straight_rounded,
                        ),
                        const SizedBox(width: 12),
                        _StatTile(
                          value: '${trek.stopsCount}',
                          label: 'Stops Logged',
                          icon: Icons.location_on_rounded,
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // Day breakdown
                      Text('Day Breakdown'.toUpperCase(), style: AppTextStyles.sectionLabel),
                      const SizedBox(height: 12),
                      ...trek.days.map((day) => _DayRow(day: day)),

                      // Description if present
                      if (trek.description.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text('About'.toUpperCase(), style: AppTextStyles.sectionLabel),
                        const SizedBox(height: 8),
                        Text(trek.description, style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary, height: 1.65,
                        )),
                      ],

                      const SizedBox(height: 24),
                      if (!trek.completed)
                        PrimaryButton(
                          label: 'Mark as Complete',
                          onPressed: () {
                            ref.read(trekListProvider.notifier).updateTrek(
                              trek.id, (t) => t.copyWith(completed: true),
                            );
                            context.pop();
                          },
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                size: 16, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Text('Trek Completed', style: AppTextStyles.body.copyWith(
                                color: AppColors.accent, fontWeight: FontWeight.w700,
                              )),
                            ],
                          ),
                        ),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String value, label;
  final IconData icon;

  const _StatTile({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary, letterSpacing: -0.5,
          )),
          const SizedBox(height: 2),
          Text(label.toUpperCase(), style: AppTextStyles.label.copyWith(
            color: AppColors.textHint, fontSize: 10, letterSpacing: 0.6,
          )),
        ],
      ),
    ),
  );
}

class _DayRow extends StatelessWidget {
  final dynamic day;
  const _DayRow({required this.day});

  @override
  Widget build(BuildContext context) {
    final stops = (day.stops as List).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          Text(
            day.dayNum.toString().padLeft(2, '0'),
            style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.w100,
              color: stops > 0 ? AppColors.accent : AppColors.textHint,
              height: 1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(day.title as String, style: AppTextStyles.body.copyWith(
              fontSize: 13, fontWeight: FontWeight.w600,
            )),
          ),
          Text(
            stops > 0 ? '$stops stop${stops == 1 ? '' : 's'}' : 'No stops',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
