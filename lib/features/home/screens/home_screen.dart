import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/trek.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/diff_badge.dart';
import '../../../shared/widgets/glass.dart';
import '../../../shared/widgets/stat_card.dart';
import '../widgets/trek_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — outer widget is StatelessWidget; all ref.watch calls are
// pushed into the smallest possible Consumer so the photo/scrim/tab bar
// never rebuild when trek data changes.
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // sizeOf / paddingOf only rebuild this widget on size/padding changes,
    // not on arbitrary MediaQuery changes.
    final size = MediaQuery.sizeOf(context);
    final safe = MediaQuery.paddingOf(context);
    final sheetTop = size.height * 0.42;

    return Scaffold(
      backgroundColor: AppColors.heroDark,
      body: Stack(
        children: [
          // ── Static layers — rebuilt only when HomeScreen mounts ────────────
          const Positioned.fill(child: _HeroPhoto()),
          const Positioned.fill(child: _Scrim()),

          // ── Top-right glass create button ──────────────────────────────────
          Positioned(
            top: safe.top + 12,
            right: 16,
            child: _CreateButton(onTap: () => context.push('/create')),
          ),

          // ── Hero text — Consumer watches trekCount + totalStops only ───────
          Positioned(
            left: 22,
            right: 22,
            bottom: size.height - sheetTop + 24,
            child: const _HeroTextBlock(),
          ),

          // ── Content sheet — Consumer watches full list for rendering ────────
          Positioned(
            top: sheetTop,
            left: 0, right: 0, bottom: 0,
            child: _ContentSheet(
              onCreateTrek: () => context.push('/create'),
              onSelectTrek: (id) => context.push('/trek/$id'),
            ),
          ),

          // ── Tab bar — fully static ─────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: GlassTabBar(
              currentIndex: 0,
              onTap: (i) {
                if (i == 1) context.push('/create');
                if (i == 2) context.push('/settings');
              },
              tabs: const [
                GlassTabItem(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                ),
                GlassTabItem(
                  label: 'New',
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle_rounded,
                ),
                GlassTabItem(
                  label: 'Settings',
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Static hero photo — never rebuilds after first mount.
// ─────────────────────────────────────────────────────────────────────────────
class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto();

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    imageUrl: AppConstants.homeHero,
    fit: BoxFit.cover,
    alignment: const Alignment(0.0, -0.3),
    placeholder: (_, __) => const ColoredBox(color: AppColors.heroDark),
    errorWidget:  (_, __, ___) => const ColoredBox(color: AppColors.heroDark),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Static gradient scrim — completely const, zero rebuild cost.
// ─────────────────────────────────────────────────────────────────────────────
class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x8C000000),
          Color(0x00000000),
          Color(0xF50D1A0D),
        ],
        stops: [0.0, 0.34, 0.68],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Frosted-glass create button (top-right).
// ─────────────────────────────────────────────────────────────────────────────
class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: AppColors.glassLightBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassLightBorder, width: 0.5),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero text block — ConsumerWidget watching only the two count providers.
// Rebuilds when trek count or stop count changes, not on any trek mutation.
// ─────────────────────────────────────────────────────────────────────────────
class _HeroTextBlock extends ConsumerWidget {
  const _HeroTextBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trekCount = ref.watch(trekCountProvider);
    final stopCount = ref.watch(totalStopsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // TIDE eyebrow: dot + label
        Row(
          children: [
            Container(
              width: 5, height: 5,
              decoration: const BoxDecoration(
                color: AppColors.accentLight,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text('Trek Diary', style: AppTextStyles.eyebrow),
          ],
        ),
        const SizedBox(height: 10),

        // Main heading
        Text(
          'Trek\nDiary',
          style: AppTextStyles.heroHeading.copyWith(
            fontSize: 46, fontWeight: FontWeight.w800,
            letterSpacing: -0.8, height: 1.05, color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        // Live-updating subtitle
        Text(
          '$trekCount ${trekCount == 1 ? 'trek' : 'treks'} · $stopCount stops recorded',
          style: AppTextStyles.heroSubtitle,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content sheet — warm #F2F0EB surface.
// Split into two Consumers so the stats bar and trek list rebuild independently.
// ─────────────────────────────────────────────────────────────────────────────
class _ContentSheet extends StatelessWidget {
  final VoidCallback onCreateTrek;
  final ValueChanged<String> onSelectTrek;

  const _ContentSheet({
    required this.onCreateTrek,
    required this.onSelectTrek,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppColors.sheet,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats row — own Consumer, rebuilds only on count changes
            _StatsRow(),
            const SizedBox(height: 22),

            // Active trek spotlight — own Consumer, rebuilds only when
            // the active trek identity changes
            _ActiveSpotlight(onTap: onSelectTrek),

            // Full trek list — rebuilds whenever the list changes
            _TrekListSection(
              onCreateTrek: onCreateTrek,
              onSelectTrek: onSelectTrek,
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row — watches three derived count providers.
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total     = ref.watch(trekCountProvider);
    final stops     = ref.watch(totalStopsProvider);
    final completed = ref.watch(completedCountProvider);

    if (total == 0) return const SizedBox.shrink();

    return StatCard(stats: [
      StatItem(label: 'Treks',     value: '$total'),
      StatItem(label: 'Stops',     value: '$stops'),
      StatItem(label: 'Completed', value: '$completed'),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Active trek spotlight — highlighted card for the in-progress trek.
// Watches activeTrekProvider; rebuilds only when the active trek changes.
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveSpotlight extends ConsumerWidget {
  final ValueChanged<String> onTap;
  const _ActiveSpotlight({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeTrekProvider);
    if (active == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label with live indicator
        Row(
          children: [
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                color: AppColors.nodeCurrent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text('Active Trek'.toUpperCase(), style: AppTextStyles.sectionLabel),
          ],
        ),
        const SizedBox(height: 10),

        // Featured card — slightly taller than regular cards
        _FeaturedTrekCard(trek: active, onTap: () => onTap(active.id)),
        const SizedBox(height: 22),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Featured card for the active trek — taller, shows day progress bar + next
// unlogged day label.
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturedTrekCard extends StatelessWidget {
  final Trek trek;
  final VoidCallback onTap;
  const _FeaturedTrekCard({required this.trek, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final photo    = getTrekPhotoUrl(trek);
    final nextDay  = trek.days.where((d) => d.stops.isEmpty).firstOrNull;
    final progress = trek.progress;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 172,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: photo,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(color: AppColors.heroDark),
                errorWidget:  (_, __, ___) => const ColoredBox(color: AppColors.heroDark),
              ),

              // Heavier scrim for featured card
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xBB000000), Color(0x44000000)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top row: badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DiffBadge(difficulty: trek.difficulty),
                        // Progress fraction chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${trek.daysLogged}/${trek.totalDays} days',
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white, fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Bottom: trek name + next day label + progress
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trek.name, style: AppTextStyles.cardTitleOnPhoto.copyWith(
                          fontSize: 19,
                        )),
                        const SizedBox(height: 2),
                        if (nextDay != null)
                          Text(
                            'Next up: ${nextDay.title}',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.onPhotoDim, fontSize: 11,
                            ),
                          ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.18),
                            valueColor: const AlwaysStoppedAnimation(AppColors.accentLight),
                            minHeight: 4,
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

// ─────────────────────────────────────────────────────────────────────────────
// Trek list section — only ConsumerWidget that watches the full list.
// The active trek is already shown above; this shows all treks with a header.
// ─────────────────────────────────────────────────────────────────────────────
class _TrekListSection extends ConsumerWidget {
  final VoidCallback onCreateTrek;
  final ValueChanged<String> onSelectTrek;

  const _TrekListSection({
    required this.onCreateTrek,
    required this.onSelectTrek,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treks = ref.watch(trekListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'All Treks',
          action: '+ New',
          onAction: onCreateTrek,
        ),
        const SizedBox(height: 10),

        if (treks.isEmpty)
          const _EmptyState()
        else
          ...treks.map((trek) => TrekCard(
            key: ValueKey(trek.id),   // stable key → no unnecessary reparenting
            trek: trek,
            onTap: () => onSelectTrek(trek.id),
          )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header row — const-constructible sub-widgets.
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title.toUpperCase(), style: AppTextStyles.sectionLabel),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(
            action!,
            style: AppTextStyles.label.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state — fully const, no rebuild cost ever.
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        const Text('🏔️', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 14),
        Text(
          'No treks yet',
          style: AppTextStyles.cardTitle.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          'Start your first adventure',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: 160,
          child: ElevatedButton(
            onPressed: () => context.push('/create'),
            child: const Text('Create Trek'),
          ),
        ),
      ],
    ),
  );
}
