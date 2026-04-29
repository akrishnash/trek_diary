import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/trek.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/diff_badge.dart';

class TrekCard extends StatelessWidget {
  final Trek trek;
  final VoidCallback onTap;

  const TrekCard({super.key, required this.trek, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Compute once per build; stable across hot-reloads via deterministic hash
    final photo    = getTrekPhotoUrl(trek);
    final progress = trek.progress;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Nature photo ──────────────────────────────────────────────
              CachedNetworkImage(
                imageUrl: photo,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(color: AppColors.heroDark),
                errorWidget:  (_, __, ___) => const ColoredBox(color: AppColors.heroDark),
              ),

              // ── Diagonal scrim — const ────────────────────────────────────
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xA6000000), Color(0x33000000)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              // ── Card content ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trek.name,
                                style: AppTextStyles.cardTitleOnPhoto,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                trek.region,
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.onPhotoDim, fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            DiffBadge(difficulty: trek.difficulty),
                            if (trek.completed) ...[
                              const SizedBox(height: 4),
                              const _DoneBadge(),
                            ],
                          ],
                        ),
                      ],
                    ),

                    // Bottom: progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${trek.totalDays} days · ${trek.stopsCount} stops',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.onPhotoSubtle, fontSize: 11,
                              ),
                            ),
                            Text(
                              '${trek.daysLogged}/${trek.totalDays}',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.onPhotoSubtle, fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: const Color(0x26FFFFFF),
                            valueColor: const AlwaysStoppedAnimation(AppColors.accentLight),
                            minHeight: 3,
                          ),
                        ),
                      ],
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

// const — no rebuild cost, used on every completed trek card
class _DoneBadge extends StatelessWidget {
  const _DoneBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: const BoxDecoration(
      color: Color(0x33A0E0C0),   // accentLight at 20% — fully const
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
