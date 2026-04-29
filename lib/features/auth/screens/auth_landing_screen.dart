import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/providers/auth_provider.dart';

class AuthLandingScreen extends ConsumerStatefulWidget {
  const AuthLandingScreen({super.key});

  @override
  ConsumerState<AuthLandingScreen> createState() => _AuthLandingScreenState();
}

class _AuthLandingScreenState extends ConsumerState<AuthLandingScreen> {
  bool _agreed = false;
  bool _googleLoading = false;

  void _onEmail() {
    if (!_agreed) { _shakeTerms(); return; }
    context.push('/auth/email');
  }

  void _onPhone() {
    if (!_agreed) { _shakeTerms(); return; }
    context.push('/auth/phone');
  }

  Future<void> _onGoogle() async {
    if (!_agreed) { _shakeTerms(); return; }
    setState(() => _googleLoading = true);
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final account = await googleSignIn.signIn();
      if (account == null || !mounted) return;
      ref.read(authFormProvider.notifier).state = (
        name:         account.displayName ?? '',
        email:        account.email,
        phone:        '',
        signInMethod: 'google',
      );
      if (mounted) context.push('/auth/profile');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Google sign-in failed. Please configure OAuth credentials.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2A3028),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _onGuest() async {
    if (!_agreed) { _shakeTerms(); return; }
    await ref.read(authProvider.notifier).continueAsGuest();
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
          // Full-bleed mountain photo
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

          // Dark overlay
          const Positioned.fill(
            child: ColoredBox(color: Color(0x88000000)),
          ),

          // X close / session-only guest
          Positioned(
            top: safe.top + 14,
            left: 16,
            child: GestureDetector(
              onTap: () {
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

          // App name + tagline
          Positioned(
            left: 0, right: 0,
            top: MediaQuery.sizeOf(context).height * 0.22,
            child: Column(
              children: [
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

          // Bottom button stack
          Positioned(
            left: 24, right: 24,
            bottom: safe.bottom + 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Terms row
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
                const SizedBox(height: 20),

                // Google — primary white pill
                _AuthButton(
                  label: 'Continue with Google',
                  icon: _GoogleIcon(),
                  primary: true,
                  loading: _googleLoading,
                  onTap: _onGoogle,
                ),
                const SizedBox(height: 10),

                // Phone — dark glass pill
                _AuthButton(
                  label: '  Continue with Phone',
                  icon: const Icon(Icons.phone_outlined, size: 17, color: Colors.white),
                  primary: false,
                  onTap: _onPhone,
                ),
                const SizedBox(height: 10),

                // Email — dark glass pill
                _AuthButton(
                  label: '✉   Continue with Email',
                  primary: false,
                  onTap: _onEmail,
                ),
                const SizedBox(height: 18),

                // Guest text link
                GestureDetector(
                  onTap: _onGuest,
                  child: Text(
                    'Continue as Guest',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// TIDE-style checkbox circle
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

// Minimal Google "G" icon
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 18, height: 18,
    decoration: const BoxDecoration(shape: BoxShape.circle),
    child: const Text(
      'G',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4),
        height: 1.25,
      ),
    ),
  );
}

// Auth button — white solid pill (primary) or dark glass pill (secondary)
class _AuthButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool primary;
  final bool loading;
  final VoidCallback onTap;

  const _AuthButton({
    required this.label,
    this.icon,
    required this.primary,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primary ? const Color(0xFF1A1F1C) : Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primary
                      ? const Color(0xFF1A1F1C)
                      : Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          );

    if (primary) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A1F1C),
            elevation: 0,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: child,
        ),
      );
    }

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
        child: child,
      ),
    );
  }
}
