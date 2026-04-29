import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GlassCard — frosted glass rectangle, dark or light variant.
// Use on top of nature photography.
// ─────────────────────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final bool dark;
  final double radius;
  final EdgeInsets padding;

  const GlassCard({
    super.key,
    required this.child,
    this.dark = true,
    this.radius = 18,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: dark ? AppColors.glassDarkBg : AppColors.glassLightBg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: dark ? AppColors.glassDarkBorder : AppColors.glassLightBorder,
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GlassButton — small frosted glass action button (e.g. "Path", "Stats",
// "Back"). Appears on dark photo headers.
// ─────────────────────────────────────────────────────────────────────────────
class GlassButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final VoidCallback onPressed;
  final bool active; // e.g. "Done" highlighted in green

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.accentLight.withValues(alpha: 0.25)
                  : AppColors.glassLightBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active
                    ? AppColors.accentLight.withValues(alpha: 0.45)
                    : AppColors.glassLightBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 5)],
                Text(label,
                  style: AppTextStyles.glassAction.copyWith(
                    color: active ? AppColors.accentLight : AppColors.onPhoto,
                  )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GlassBackButton — frosted-glass back chevron for dark photo headers.
// ─────────────────────────────────────────────────────────────────────────────
class GlassBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GlassBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.glassLightBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassLightBorder, width: 0.5),
            ),
            child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PillButton — solid white pill, TIDE's primary CTA style ("Start").
// ─────────────────────────────────────────────────────────────────────────────
class PillButton extends StatelessWidget {
  final String label;
  final Widget? leadingIcon;
  final VoidCallback? onPressed;
  final bool dark; // dark glass variant (TIDE "Continue with Google")

  const PillButton({
    super.key,
    required this.label,
    this.leadingIcon,
    this.onPressed,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    if (dark) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.glassDarkBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.glassDarkBorder, width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 10)],
                  Text(label, style: AppTextStyles.pillSecondary),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Solid white pill (primary)
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.pillWhiteText,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 10)],
            Text(label, style: AppTextStyles.pillPrimary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GlassTabBar — pill-shaped frosted glass tab bar, TIDE home screen style.
// ─────────────────────────────────────────────────────────────────────────────
class GlassTabBar extends StatelessWidget {
  final List<GlassTabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              // Dark glass pill — matches auth screen dark button style
              color: const Color(0xF0252B28),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x33FFFFFF), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: tabs.asMap().entries.map((e) {
                final active = e.key == currentIndex;
                return GestureDetector(
                  onTap: () => onTap(e.key),
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
                        Icon(
                          active ? e.value.activeIcon : e.value.icon,
                          size: 22,
                          color: active ? Colors.white : AppColors.textMuted,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          e.value.label,
                          style: AppTextStyles.tabLabel.copyWith(
                            color: active ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassTabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const GlassTabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PhotoScrim — standard dark-to-transparent gradient overlay on hero photos.
// ─────────────────────────────────────────────────────────────────────────────
class PhotoScrim extends StatelessWidget {
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<Color> colors;

  const PhotoScrim({
    super.key,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.colors = const [Color(0x8C000000), Color(0x00000000)],
  });

  /// Standard hero scrim — dark top fading to transparent, then very dark at bottom.
  const PhotoScrim.hero({super.key})
      : begin = Alignment.topCenter,
        end = Alignment.bottomCenter,
        colors = const [
          Color(0x8C000000), // ~55%
          Color(0x00000000),
          Color(0xF8001000), // near-black at very bottom
        ];

  /// Card scrim — diagonal, lighter.
  const PhotoScrim.card({super.key})
      : begin = Alignment.centerLeft,
        end = Alignment.centerRight,
        colors = const [Color(0xA6000000), Color(0x40000000)];

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: begin, end: end, colors: colors),
    ),
    child: const SizedBox.expand(),
  );
}
