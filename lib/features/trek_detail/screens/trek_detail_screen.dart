import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/day.dart';
import '../../../data/models/stop.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/diff_badge.dart';
import '../../../shared/widgets/glass.dart';

class TrekDetailScreen extends ConsumerStatefulWidget {
  final String trekId;
  const TrekDetailScreen({super.key, required this.trekId});

  @override
  ConsumerState<TrekDetailScreen> createState() => _TrekDetailScreenState();
}

class _TrekDetailScreenState extends ConsumerState<TrekDetailScreen> {
  int _openDay = -1;

  @override
  Widget build(BuildContext context) {
    final trek = ref.watch(
      trekListProvider.select(
        (list) => list.where((t) => t.id == widget.trekId).firstOrNull,
      ),
    );
    if (trek == null) return const SizedBox.shrink();
    final size = MediaQuery.sizeOf(context);
    final safe = MediaQuery.paddingOf(context);
    final sheetAt = size.height * 0.44;

    return Scaffold(
      backgroundColor: AppColors.heroDark,
      body: Stack(
        children: [
          // ── Photo ──────────────────────────────────────────────────────────
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: trek.coverImageUrl?.isNotEmpty == true
                  ? trek.coverImageUrl!
                  : getTrekPhotoUrl(trek),
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.2),
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
                  colors: [Color(0x99000000), Color(0x00000000), Color(0xF00D1A0D)],
                  stops: [0.0, 0.35, 0.7],
                ),
              ),
            ),
          ),

          // ── Back ───────────────────────────────────────────────────────────
          Positioned(
            top: safe.top + 12,
            left: 16,
            child: GlassBackButton(onPressed: () => context.pop()),
          ),

          // ── Action chips ───────────────────────────────────────────────────
          // left: 62 reserves space for the back button; reverse: true keeps
          // buttons right-aligned and scrolls toward the left on small screens.
          Positioned(
            top: safe.top + 12,
            left: 62,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(children: [
                GlassButton(
                  label: 'Journal',
                  icon: const Icon(Icons.auto_stories_rounded, size: 13, color: Colors.white),
                  onPressed: () => context.push('/trek/${trek.id}/journal'),
                ),
                const SizedBox(width: 8),
                GlassButton(
                  label: 'Edit',
                  icon: const Icon(Icons.edit_rounded, size: 13, color: Colors.white),
                  onPressed: () => context.push('/trek/${trek.id}/edit'),
                ),
                const SizedBox(width: 8),
                GlassButton(
                  label: 'Path',
                  icon: const Icon(Icons.route_rounded, size: 13, color: Colors.white),
                  onPressed: () => context.push('/trek/${trek.id}/path'),
                ),
                const SizedBox(width: 8),
                GlassButton(
                  label: 'Summary',
                  icon: const Icon(Icons.bar_chart_rounded, size: 13, color: Colors.white),
                  onPressed: () => context.push('/trek/${trek.id}/summary'),
                ),
              ]),
            ),
          ),

          // ── Hero text ──────────────────────────────────────────────────────
          Positioned(
            left: 22, right: 22,
            bottom: size.height - sheetAt + 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  DiffBadge(difficulty: trek.difficulty),
                  const SizedBox(width: 10),
                  Text(
                    '${trek.daysLogged} of ${trek.totalDays} days'.toUpperCase(),
                    style: AppTextStyles.eyebrow,
                  ),
                ]),
                const SizedBox(height: 10),
                Text(trek.name, style: AppTextStyles.heroHeading.copyWith(
                  fontSize: 36, fontWeight: FontWeight.w700,
                  letterSpacing: -0.4, height: 1.05,
                )),
                const SizedBox(height: 6),
                Text(trek.region, style: AppTextStyles.heroSubtitle),
              ],
            ),
          ),

          // ── Day sheet ──────────────────────────────────────────────────────
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
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Days'.toUpperCase(), style: AppTextStyles.sectionLabel),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => context.push('/trek/${trek.id}/journal'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  const Icon(Icons.auto_stories_rounded, size: 11, color: AppColors.accentLight),
                                  const SizedBox(width: 4),
                                  Text('Full Journal', style: AppTextStyles.label.copyWith(
                                    color: AppColors.accentLight, fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  )),
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...trek.days.map((day) => _DayCard(
                        day: day,
                        isOpen: _openDay == day.dayNum,
                        onTap: () => setState(() =>
                          _openDay = _openDay == day.dayNum ? -1 : day.dayNum),
                        onAddStop: () => context.push(
                          '/trek/${trek.id}/add-stop/${day.dayNum}'),
                        onStopTap: (stop) => context.push(
                          '/trek/${trek.id}/stop/${day.dayNum}/${stop.id}'),
                        onDiary: () => context.push(
                          '/trek/${trek.id}/diary/${day.dayNum}'),
                      )),
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

class _DayCard extends StatelessWidget {
  final TrekDay day;
  final bool isOpen;
  final VoidCallback onTap;
  final VoidCallback onAddStop;
  final ValueChanged<TrekStop> onStopTap;
  final VoidCallback onDiary;

  const _DayCard({
    required this.day, required this.isOpen, required this.onTap,
    required this.onAddStop, required this.onStopTap, required this.onDiary,
  });

  @override
  Widget build(BuildContext context) {
    final logged = day.stops.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOpen
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.borderLight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  // TIDE-style editorial day number
                  Text(
                    day.dayNum.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 34, fontWeight: FontWeight.w100,
                      color: logged ? AppColors.accent : AppColors.textHint,
                      height: 1.0, letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(day.title, style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700, height: 1.2,
                        )),
                        const SizedBox(height: 2),
                        Text(
                          logged
                            ? '${day.stops.length} stop${day.stops.length == 1 ? '' : 's'}'
                            : 'No stops yet',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 7, height: 7,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: logged ? AppColors.accent : AppColors.borderLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                    size: 18, color: AppColors.textHint,
                  ),
                ],
              ),
            ),

            if (isOpen) ...[
              Divider(height: 1, color: AppColors.borderLight),
              if (day.stops.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onAddStop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDim,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, size: 16, color: AppColors.accent),
                          const SizedBox(width: 6),
                          Text('Log a stop', style: AppTextStyles.label.copyWith(
                            color: AppColors.accent, fontWeight: FontWeight.w700,
                          )),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                ...day.stops.map((s) => _StopRow(stop: s, onTap: () => onStopTap(s))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: InkWell(
                    onTap: onAddStop,
                    child: Row(children: [
                      Icon(Icons.add_rounded, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text('Add stop', style: AppTextStyles.label.copyWith(
                        color: AppColors.accent, fontWeight: FontWeight.w700,
                      )),
                    ]),
                  ),
                ),
              ],
              // ── Diary button ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: onDiary,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B8A6E).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          day.diary != null && !day.diary!.isEmpty
                              ? Icons.auto_stories_rounded
                              : Icons.edit_note_rounded,
                          size: 15,
                          color: AppColors.accentLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          day.diary != null && !day.diary!.isEmpty
                              ? 'View diary entry'
                              : 'Add diary entry',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.accentLight, fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (day.diary != null && day.diary!.images.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${day.diary!.images.length} photo${day.diary!.images.length == 1 ? '' : 's'}',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.accentLight, fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
          ),
        ),
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  final TrekStop stop;
  final VoidCallback onTap;
  const _StopRow({required this.stop, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(right: 12, top: 1),
            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.name, style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600, fontSize: 13,
                )),
                Text(
                  '${stop.elevation} m  ·  ${stop.weather}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textHint),
        ],
      ),
    ),
  );
}
