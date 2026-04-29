import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/trek.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/diff_badge.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TrekCard — Pangea-style: tall card, full-bleed photo hero, dark info panel.
// Font weights match the auth/login screen (Poppins w700 title, w400 sub).
// ─────────────────────────────────────────────────────────────────────────────
class TrekCard extends StatelessWidget {
  final Trek trek;
  final VoidCallback onTap;

  const TrekCard({super.key, required this.trek, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final photo    = trek.coverImageUrl?.isNotEmpty == true
        ? trek.coverImageUrl!
        : getTrekPhotoUrl(trek);
    final progress = trek.progress;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero photo (top 55%) ──────────────────────────────────────
              SizedBox(
                height: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: photo,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.2),
                      placeholder: (_, __) => const ColoredBox(color: AppColors.heroDark),
                      errorWidget:  (_, __, ___) => const ColoredBox(color: AppColors.heroDark),
                    ),
                    // Subtle bottom scrim so text below doesn't feel disconnected
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x66000000)],
                        ),
                      ),
                    ),
                    // Badges top-right
                    Positioned(
                      top: 10, right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          DiffBadge(difficulty: trek.difficulty),
                          if (trek.completed) ...[
                            const SizedBox(height: 4),
                            const _DoneBadge(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Info panel (dark, Pangea-style) ──────────────────────────
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Trek name — bold, centered, auth-screen style
                    Text(
                      trek.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Region + duration
                    Text(
                      '${trek.region.isNotEmpty ? trek.region : 'Unknown region'}  ·  ${trek.totalDays} days',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Progress row
                    Row(
                      children: [
                        Text(
                          '${trek.daysLogged}/${trek.totalDays} days logged',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${trek.stopsCount} stops',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(
                          trek.completed ? AppColors.accentLight : AppColors.accent,
                        ),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoneBadge extends StatelessWidget {
  const _DoneBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: const BoxDecoration(
      color: Color(0x33A0E0C0),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    child: Text(
      '✓ Done',
      style: AppTextStyles.label.copyWith(
        color: AppColors.accentLight,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
