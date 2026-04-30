import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthEmailScreen — TIDE screen 2/3 exact:
//   dark charcoal bg · back chevron · bold left-aligned title ·
//   dark rounded inputs · white pill activates when fields filled
// ─────────────────────────────────────────────────────────────────────────────
class AuthEmailScreen extends ConsumerStatefulWidget {
  const AuthEmailScreen({super.key});

  @override
  ConsumerState<AuthEmailScreen> createState() => _AuthEmailScreenState();
}

class _AuthEmailScreenState extends ConsumerState<AuthEmailScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nameFocus  = FocusNode();
  final _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  bool get _valid =>
      _nameCtrl.text.trim().isNotEmpty && _emailCtrl.text.trim().isNotEmpty;

  void _continue() {
    if (!_valid) return;
    // Store in temporary Riverpod state so AuthPinScreen can read it
    ref.read(authFormProvider.notifier).state = (
      name:         _nameCtrl.text.trim(),
      email:        _emailCtrl.text.trim(),
      phone:        '',
      signInMethod: 'email',
    );
    context.push('/auth/pin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TIDE exact: dark green-charcoal gradient, no photo
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1F1C), Color(0xFF252B28)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back chevron ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _BackChevron(onTap: () => context.pop()),
              ),
              const SizedBox(height: 36),

              // ── Title block — left-aligned, TIDE exact ────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue with Email',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter your name and email to continue',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A9590),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ── Input fields ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _DarkField(
                      controller: _nameCtrl,
                      focusNode: _nameFocus,
                      hint: 'Your name',
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _emailFocus.requestFocus(),
                    ),
                    const SizedBox(height: 12),
                    _DarkField(
                      controller: _emailCtrl,
                      focusNode: _emailFocus,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _continue(),
                    ),
                    const SizedBox(height: 28),

                    // "Continue" — white pill, activates once fields filled
                    _ContinueButton(enabled: _valid, onTap: _continue),
                    const SizedBox(height: 20),

                    // Text link — matches TIDE "Continue with password"
                    GestureDetector(
                      onTap: () async {
                        await ref.read(authProvider.notifier).continueAsGuest();
                      },
                      child: Text(
                        'Continue as Guest',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8A9590),
                        ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared dark-theme field — TIDE screen 2/3 input style
// ─────────────────────────────────────────────────────────────────────────────
class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _DarkField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    onSubmitted: onSubmitted,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6A7570), fontSize: 15),
      filled: true,
      fillColor: const Color(0xFF252B28),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A4240)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A4240)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Continue button — grey when disabled, white when enabled (TIDE exact)
// ─────────────────────────────────────────────────────────────────────────────
class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _ContinueButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFF363D3A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Continue',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: enabled ? const Color(0xFF1A1F1C) : const Color(0xFF6A7570),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Back chevron — TIDE circular dark button
// ─────────────────────────────────────────────────────────────────────────────
class _BackChevron extends StatelessWidget {
  final VoidCallback onTap;
  const _BackChevron({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2E3530),
        border: Border.all(color: const Color(0xFF3A4240), width: 1),
      ),
      child: const Icon(
        Icons.chevron_left_rounded,
        color: Colors.white,
        size: 22,
      ),
    ),
  );
}
