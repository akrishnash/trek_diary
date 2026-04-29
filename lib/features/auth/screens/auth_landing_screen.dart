import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthLandingScreen — mirrors TIDE screen 0/1 exactly:
//   full-bleed dark photo · app name w200 tracked · white pill primary ·
//   dark glass secondary · terms checkbox
// ─────────────────────────────────────────────────────────────────────────────
class AuthLandingScreen extends ConsumerStatefulWidget {
  const AuthLandingScreen({super.key});

  @override
  ConsumerState<AuthLandingScreen> createState() => _AuthLandingScreenState();
}

class _AuthLandingScreenState extends ConsumerState<AuthLandingScreen> {
  bool _agreed = false;

  void _onEmail() {
    if (!_agreed) { _shakeTerms(); return; }
    context.push('/auth/email');
  }

  void _onGuest() async {
    if (!_agreed) { _shakeTerms(); return; }
    await ref.read(authProvider.notifier).continueAsGuest();
    // router redirect fires automatically
  }

  void _shakeTerms() {
    setState(() => _agreed = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please agree to the Terms first'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A3028),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E1510),
      body: Stack(
        children: [
          // ── Full-bleed dark mountain/forest photo ──────────────────────────
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&q=80',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              placeholder: (_, __) => const ColoredBox(color: Color(0xFF0E1510)),
              errorWidget: (_, __, ___) => const ColoredBox(color: Color(0xFF0E1510)),
            ),
          ),

          // ── Dark overlay — exactly like TIDE ──────────────────────────────
          const Positioned.fill(
            child: ColoredBox(color: Color(0x88000000)),
          ),

          // ── X close / skip button (top-left, TIDE style) ──────────────────
          Positioned(
            top: safe.top + 14,
            left: 16,
            child: GestureDetector(
              onTap: () {
                // Session-only: does not write td_logged_in to disk.
                // App will show auth screen again on next launch.
                ref.read(sessionGuestProvider.notifier).state = true;
              },
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),

          // ── App name + tagline — centered on photo (TIDE exact) ───────────
          Positioned(
            left: 0, right: 0,
            top: MediaQuery.sizeOf(context).height * 0.22,
            child: Column(
              children: [
                // App name: ultra-thin tracked — mirroring "TIDE"
                Text(
                  'TREK DIARY',
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    letterSpacing: 10,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your offline trekking journal.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom button stack (TIDE exact layout) ───────────────────────
          Positioned(
            left: 24, right: 24,
            bottom: safe.bottom + 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Terms row — matches TIDE screen 1 exactly
                GestureDetector(
                  onTap: () => setState(() => _agreed = !_agreed),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Checkbox(checked: _agreed),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.45),
                              height: 1.5,
                            ),
                            children: const [
                              TextSpan(text: "I've read and agreed with "),
                              TextSpan(
                                text: 'Terms',
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Dark glass secondary — "Continue as Guest"
                _AuthButton(
                  label: 'Continue as Guest',
                  primary: false,
                  onTap: _onGuest,
                ),
                const SizedBox(height: 12),

                // "Other options" text link
                Text(
                  'Other sign-in options  ›',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: 18),

                // White solid pill primary — "Continue with Email"
                _AuthButton(
                  label: '✉   Continue with Email',
                  primary: true,
                  onTap: _onEmail,
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
// TIDE-style checkbox circle
// ─────────────────────────────────────────────────────────────────────────────
class _Checkbox extends StatelessWidget {
  final bool checked;
  const _Checkbox({required this.checked});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: 18, height: 18,
    margin: const EdgeInsets.only(top: 1),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: checked ? const Color(0xFF5B8A6E) : Colors.transparent,
      border: Border.all(
        color: checked
            ? const Color(0xFF5B8A6E)
            : Colors.white.withValues(alpha: 0.35),
        width: 1.5,
      ),
    ),
    child: checked
        ? const Icon(Icons.check, color: Colors.white, size: 11)
        : null,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth button — white solid pill (primary) or dark glass pill (secondary)
// ─────────────────────────────────────────────────────────────────────────────
class _AuthButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _AuthButton({required this.label, required this.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A1F1C),
            elevation: 0,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1F1C),
            ),
          ),
        ),
      );
    }

    // Dark glass secondary pill
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0x44000000),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}
