import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
// ignore: unused_import — glass.dart re-exported for convenience
import 'glass.dart';

/// Full-bleed photo header used on every screen that follows the TIDE pattern:
/// nature photo → dark scrim → eyebrow + heading + subtitle floated over it.
///
/// The content sheet (warm #F2F0EB) slides up from below, overlapping this
/// header by [sheetOverlap] pixels with a 24px top radius.
class PhotoHeroHeader extends StatelessWidget {
  final String photoUrl;
  final String? eyebrow;       // e.g. "TREK DIARY", "DAY 3 OF 6"
  final String heading;        // e.g. "Valley of Flowers"
  final String? subtitle;      // e.g. "Uttarakhand, India"
  final double height;
  final Widget? topLeft;       // GlassBackButton or null
  final List<Widget> topRight; // GlassButton actions
  final bool centerText;

  const PhotoHeroHeader({
    super.key,
    required this.photoUrl,
    this.eyebrow,
    required this.heading,
    this.subtitle,
    this.height = 260,
    this.topLeft,
    this.topRight = const [],
    this.centerText = false,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background photo ────────────────────────────────────────────
          CachedNetworkImage(
            imageUrl: photoUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => const ColoredBox(color: AppColors.heroDark),
            errorWidget: (_, __, ___) => const ColoredBox(color: AppColors.heroDark),
          ),

          // ── Scrim ────────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x8C000000), // 55% at top
                  Color(0x00000000), // transparent mid
                  Color(0xF00D1A0D), // near-black at bottom
                ],
                stops: [0.0, 0.35, 1.0],
              ),
            ),
          ),

          // ── Top action row ───────────────────────────────────────────────
          Positioned(
            top: top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (topLeft != null) topLeft! else const SizedBox(width: 38),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < topRight.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      topRight[i],
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ── Text block ───────────────────────────────────────────────────
          Positioned(
            left: centerText ? 0 : 20,
            right: centerText ? 0 : 20,
            bottom: 28,
            child: Column(
              crossAxisAlignment: centerText
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!.toUpperCase(),
                    textAlign: centerText ? TextAlign.center : TextAlign.start,
                    style: AppTextStyles.eyebrow,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  heading,
                  textAlign: centerText ? TextAlign.center : TextAlign.start,
                  style: AppTextStyles.heroHeading,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    textAlign: centerText ? TextAlign.center : TextAlign.start,
                    style: AppTextStyles.heroSubtitle,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
