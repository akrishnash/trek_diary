import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/glass.dart';

class StopDetailScreen extends ConsumerWidget {
  final String trekId;
  final int dayNum;
  final String stopId;

  const StopDetailScreen({
    super.key,
    required this.trekId,
    required this.dayNum,
    required this.stopId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treks = ref.watch(trekListProvider);
    final trek  = treks.firstWhere((t) => t.id == trekId);
    final day   = trek.days.firstWhere((d) => d.dayNum == dayNum);
    final stop  = day.stops.firstWhere((s) => s.id == stopId);
    final safe  = MediaQuery.of(context).padding;

    // Deterministic photo per stop
    int h = 0;
    for (final c in stopId.codeUnits) h = (h * 31 + c) & 0xFFFFFFFF;
    final photo = AppConstants.naturePhotos[h.abs() % AppConstants.naturePhotos.length];

    return Scaffold(
      backgroundColor: AppColors.heroDark,
      body: Stack(
        children: [
          // ── Full-bleed photo ───────────────────────────────────────────────
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: photo,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.1),
              placeholder: (_, __) => const ColoredBox(color: AppColors.heroDark),
              errorWidget:  (_, __, ___) => const ColoredBox(color: AppColors.heroDark),
            ),
          ),

          // ── Scrim — heavy at bottom (TIDE screen 2 style) ──────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x55000000),
                    Color(0x00000000),
                    Color(0xEA000000),
                  ],
                  stops: [0.0, 0.22, 1.0],
                ),
              ),
            ),
          ),

          // ── Back ───────────────────────────────────────────────────────────
          Positioned(
            top: safe.top + 12, left: 16,
            child: GlassBackButton(onPressed: () => context.pop()),
          ),

          // ── Edit chip ──────────────────────────────────────────────────────
          Positioned(
            top: safe.top + 12, right: 16,
            child: GlassButton(
              label: 'Edit',
              icon: const Icon(Icons.edit_rounded, size: 13, color: Colors.white),
              onPressed: () {},
            ),
          ),

          // ── TIDE editorial content — bottom-anchored ───────────────────────
          // Pattern: eyebrow → giant thin number → subtitle → dash divider → quote notes → chips
          Positioned(
            left: 26, right: 26,
            bottom: safe.bottom + 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DAY $dayNum  ·  ${trek.name.toUpperCase()}',
                  style: AppTextStyles.eyebrow,
                ),
                const SizedBox(height: 14),

                // TIDE editorial number — elevation
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stop.elevation.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 84, fontWeight: FontWeight.w100,
                        color: Colors.white, height: 1.0, letterSpacing: -3,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 6),
                      child: Text('m', style: AppTextStyles.heroSubtitle.copyWith(fontSize: 20)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Stop name
                Text(stop.name, style: AppTextStyles.heroHeading.copyWith(
                  fontSize: 24, fontWeight: FontWeight.w300, letterSpacing: 0.5,
                )),
                const SizedBox(height: 20),

                // Short dash — TIDE uses this before attribution text
                Container(width: 36, height: 1.5, color: Colors.white.withValues(alpha: 0.28)),
                const SizedBox(height: 14),

                // Notes — TIDE quote text (w300, generous line-height, on photo)
                if (stop.notes.isNotEmpty) ...[
                  Text(
                    stop.notes,
                    style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w300,
                      color: AppColors.onPhotoMid, height: 1.75, letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Context chips: weather · mood · distance
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _PhotoChip(stop.weather),
                    _PhotoChip(stop.mood),
                    if (stop.distance > 0) _PhotoChip('+${stop.distance} km'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoChip extends StatelessWidget {
  final String label;
  const _PhotoChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.40),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
    ),
    child: Text(label, style: AppTextStyles.glassAction.copyWith(
      fontWeight: FontWeight.w500, letterSpacing: 0.2, fontSize: 12,
    )),
  );
}
