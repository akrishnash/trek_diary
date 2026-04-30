import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/trek.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/diff_badge.dart';
import '../../../shared/widgets/glass.dart';
import '../widgets/trek_card.dart';

// Dark bg matching onboarding
const _kBg = Color(0xFF0E1510);
const _kCardBg = Color(0xFF131A14);
const _kCardBorder = Color(0xFF253022);
const _kOverlay = Color(0x88000000);
const _kDim = Color(0x99FFFFFF);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: _kBg,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      const _HeroPhoto(),
                      // Same overlay as onboarding
                      const ColoredBox(color: _kOverlay),
                      const _Scrim(),
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 32,
                        child: const _HeroTextBlock(),
                      ),
                    ],
                  ),
                ),
                actions: [
                  _LogoutButton(),
                  const SizedBox(width: 8),
                  _CreateButtonSmall(onTap: () => context.push('/create')),
                  const SizedBox(width: 16),
                ],
              ),

              SliverToBoxAdapter(
                child: _ContentBody(
                  onCreateTrek: () => context.push('/create'),
                  onSelectTrek: (id) => context.push('/trek/$id'),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

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
// Hero photo — same URL logic as before, same as onboarding approach
// ─────────────────────────────────────────────────────────────────────────────
class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto();

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    imageUrl: AppConstants.homeHero,
    fit: BoxFit.cover,
    alignment: const Alignment(0.0, -0.3),
    placeholder: (_, __) => const ColoredBox(color: _kBg),
    errorWidget:  (_, __, ___) => const ColoredBox(color: _kBg),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom-fade scrim
// ─────────────────────────────────────────────────────────────────────────────
class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x00000000), Color(0xEE0E1510)],
        stops: [0.35, 1.0],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass create button
// ─────────────────────────────────────────────────────────────────────────────
class _CreateButtonSmall extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateButtonSmall({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Logout button
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    onTap: () async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _kCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: _kCardBorder),
          ),
          title: Text(
            'Sign out?',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          content: Text(
            'You\'ll need to sign in again to access your treks.',
            style: GoogleFonts.poppins(color: _kDim, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                style: GoogleFonts.poppins(color: _kDim, fontSize: 13)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Sign out',
                style: GoogleFonts.poppins(color: Colors.red.shade400, fontSize: 13)),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await ref.read(authProvider.notifier).signOut();
      }
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 0.5),
          ),
          child: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero text — poppins w200 tracked, mirroring onboarding title style
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
        Text(
          'TREK DIARY',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            letterSpacing: 8,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$trekCount ${trekCount == 1 ? 'trek' : 'treks'} · $stopCount stops recorded',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: Colors.white.withValues(alpha: 0.6),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content body — dark themed, matching onboarding bg
// ─────────────────────────────────────────────────────────────────────────────
class _ContentBody extends StatelessWidget {
  final VoidCallback onCreateTrek;
  final ValueChanged<String> onSelectTrek;

  const _ContentBody({required this.onCreateTrek, required this.onSelectTrek});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatsRow(),
        const SizedBox(height: 22),
        _ActiveSpotlight(onTap: onSelectTrek),
        _TrekListSection(
          onCreateTrek: onCreateTrek,
          onSelectTrek: onSelectTrek,
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total     = ref.watch(trekCountProvider);
    final stops     = ref.watch(totalStopsProvider);
    final completed = ref.watch(completedCountProvider);

    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kCardBorder, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Treks', value: '$total'),
          _Divider(),
          _StatItem(label: 'Stops', value: '$stops'),
          _Divider(),
          _StatItem(label: 'Completed', value: '$completed'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11, fontWeight: FontWeight.w300,
          color: Colors.white.withValues(alpha: 0.5), letterSpacing: 0.5,
        ),
      ),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 0.5, height: 32,
    color: Colors.white.withValues(alpha: 0.12),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Active trek spotlight
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
            Text(
              'ACTIVE TREK',
              style: GoogleFonts.poppins(
                fontSize: 10, fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.45), letterSpacing: 1.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _FeaturedTrekCard(trek: active, onTap: () => onTap(active.id)),
        const SizedBox(height: 22),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Featured card for active trek
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturedTrekCard extends StatelessWidget {
  final Trek trek;
  final VoidCallback onTap;
  const _FeaturedTrekCard({required this.trek, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final photo    = trek.coverImageUrl?.isNotEmpty == true
        ? trek.coverImageUrl!
        : getTrekPhotoUrl(trek);
    final nextDay  = trek.days.where((d) => d.stops.isEmpty).firstOrNull;
    final progress = trek.progress;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 172,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _kCardBorder, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
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
                placeholder: (_, __) => const ColoredBox(color: _kCardBg),
                errorWidget:  (_, __, ___) => const ColoredBox(color: _kCardBg),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xCC000000), Color(0x44000000)],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DiffBadge(difficulty: trek.difficulty),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
                          ),
                          child: Text(
                            '${trek.daysLogged}/${trek.totalDays} days',
                            style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trek.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w600,
                            color: Colors.white, height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (nextDay != null)
                          Text(
                            'Next up: ${nextDay.title}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 11, fontWeight: FontWeight.w300,
                            ),
                          ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
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

// ─────────────────────────────────────────────────────────────────────────────
// Trek list section
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
            key: ValueKey(trek.id),
            trek: trek,
            onTap: () => onSelectTrek(trek.id),
          )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
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
      Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10, fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.45), letterSpacing: 1.8,
        ),
      ),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(
            action!,
            style: GoogleFonts.poppins(
              color: AppColors.accentLight,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Column(
      children: [
        const Text('🏔️', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 14),
        Text(
          'No treks yet',
          style: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Start your first adventure',
          style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w300,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 180,
          child: ElevatedButton(
            onPressed: () => context.push('/create'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _kBg,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'Create Trek',
              style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600, color: _kBg,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
