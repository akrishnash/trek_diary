import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/glass.dart';
import '../../../shared/widgets/primary_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size  = MediaQuery.of(context).size;
    final safe  = MediaQuery.of(context).padding;
    final treks = ref.watch(trekListProvider);
    final sheetAt = size.height * 0.35;

    return Scaffold(
      backgroundColor: AppColors.heroDark,
      body: Stack(
        children: [
          // ── Full-bleed nature photo ────────────────────────────────────────
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&q=80',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.4),
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
                  colors: [Color(0x77000000), Color(0x00000000), Color(0xF00D1A0D)],
                  stops: [0.0, 0.2, 0.55],
                ),
              ),
            ),
          ),

          // ── Back ───────────────────────────────────────────────────────────
          Positioned(
            top: safe.top + 12, left: 16,
            child: GlassBackButton(onPressed: () => context.pop()),
          ),

          // ── Title on photo ─────────────────────────────────────────────────
          Positioned(
            left: 26, bottom: size.height - sheetAt + 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('APP', style: AppTextStyles.eyebrow),
                const SizedBox(height: 8),
                Text('Settings', style: AppTextStyles.heroHeading.copyWith(
                  fontSize: 36, fontWeight: FontWeight.w300, letterSpacing: 0.5,
                )),
              ],
            ),
          ),

          // ── Settings sheet ─────────────────────────────────────────────────
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
                  padding: EdgeInsets.fromLTRB(20, 24, 20, safe.bottom + 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile section
                      Text('Account'.toUpperCase(), style: AppTextStyles.sectionLabel),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        label: 'My Profile',
                        sub: 'Edit your name, bio, and trekking details',
                        trailing: GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text('Edit', style: AppTextStyles.label.copyWith(
                              color: AppColors.accent, fontWeight: FontWeight.w700,
                            )),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Data section
                      Text('Data'.toUpperCase(), style: AppTextStyles.sectionLabel),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        icon: Icons.library_books_outlined,
                        label: '${treks.length} trek${treks.length == 1 ? '' : 's'} stored',
                        sub: '${treks.fold(0, (s, t) => s + t.stopsCount)} stops · local storage',
                        trailing: null,
                      ),
                      const SizedBox(height: 8),

                      // Clear data
                      _SettingsTile(
                        icon: Icons.delete_outline_rounded,
                        label: 'Clear all data',
                        sub: 'Removes all treks permanently',
                        iconColor: const Color(0xFFC4524A),
                        trailing: GestureDetector(
                          onTap: () => _confirmClear(context, ref),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0x14C4524A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0x33C4524A)),
                            ),
                            child: Text('Clear', style: AppTextStyles.label.copyWith(
                              color: const Color(0xFFC4524A), fontWeight: FontWeight.w700,
                            )),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),
                      Text('About'.toUpperCase(), style: AppTextStyles.sectionLabel),
                      const SizedBox(height: 12),

                      _SettingsTile(
                        icon: Icons.terrain_rounded,
                        label: 'Trek Diary',
                        sub: 'Offline trekking journal',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('v1.0', style: AppTextStyles.label.copyWith(
                            color: AppColors.accent, fontWeight: FontWeight.w700,
                          )),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SettingsTile(
                        icon: Icons.wifi_off_rounded,
                        label: 'Offline first',
                        sub: 'All data stored on device, no account needed',
                      ),

                      const SizedBox(height: 32),

                      PrimaryButton(
                        label: 'Back to Home',
                        onPressed: () => context.go('/'),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Sign Out',
                        danger: true,
                        onPressed: () async {
                          await ref.read(authProvider.notifier).signOut();
                          // router redirect fires automatically → /auth
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Tab bar at bottom ──────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _SettingsTabBar(onHome: () => context.go('/')),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear all data?', style: AppTextStyles.cardTitle),
        content: Text(
          'This will permanently delete all your treks and stops.',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.label.copyWith(
              color: AppColors.accent, fontWeight: FontWeight.w700,
            )),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: AppTextStyles.label.copyWith(
              color: const Color(0xFFC4524A), fontWeight: FontWeight.w700,
            )),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(trekListProvider.notifier).clearAll();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final Widget? trailing;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.sub,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    margin: const EdgeInsets.only(bottom: 2),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.borderLight, width: 1),
    ),
    child: Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body.copyWith(
                fontSize: 14, fontWeight: FontWeight.w600,
              )),
              if (sub != null) ...[
                const SizedBox(height: 2),
                Text(sub!, style: AppTextStyles.bodySmall),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

// Minimal tab bar shown at the bottom of settings (tab index = 2)
class _SettingsTabBar extends StatelessWidget {
  final VoidCallback onHome;
  const _SettingsTabBar({required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xF0252B28),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0x33FFFFFF), width: 0.5),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 20, offset: const Offset(0, 4),
          )],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _TabBtn(icon: Icons.home_outlined, label: 'Home', active: false, onTap: onHome),
            _TabBtn(icon: Icons.add_circle_outline, label: 'New', active: false,
              onTap: () => Navigator.of(context).pushNamed('/create')),
            _TabBtn(icon: Icons.settings_rounded, label: 'Settings', active: true, onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: active
        ? BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
          )
        : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22,
            color: active ? AppColors.textPrimary : AppColors.textHint),
          const SizedBox(height: 3),
          Text(label, style: AppTextStyles.tabLabel.copyWith(
            color: active ? AppColors.textPrimary : AppColors.textHint,
          )),
        ],
      ),
    ),
  );
}
