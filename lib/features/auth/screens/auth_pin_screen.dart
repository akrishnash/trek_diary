import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AuthPinScreen — TIDE screen 4/5 exact:
//   dark bg · "Verify code" bold title · 4 OTP cells (first red-border when
//   empty) · full custom dark numpad with sub-letters
// Adapted for Trek Diary: user SETS a 4-digit PIN on first launch.
// ─────────────────────────────────────────────────────────────────────────────
class AuthPinScreen extends ConsumerStatefulWidget {
  const AuthPinScreen({super.key});

  @override
  ConsumerState<AuthPinScreen> createState() => _AuthPinScreenState();
}

class _AuthPinScreenState extends ConsumerState<AuthPinScreen> {
  final List<int> _digits = [];

  void _onDigit(int d) {
    if (_digits.length >= 4) return;
    setState(() => _digits.add(d));
    if (_digits.length == 4) _submit();
  }

  void _onDelete() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  Future<void> _submit() async {
    final form  = ref.read(authFormProvider);
    final notifier = ref.read(authProvider.notifier);
    final pin   = _digits.map((d) => d.toString()).join();

    if (form != null) {
      await notifier.completeAuth(name: form.name, email: form.email);
      await notifier.savePin(pin);
      ref.read(authFormProvider.notifier).state = null;
    }
    // Router redirect handles navigation to /
  }

  Future<void> _skip() async {
    final form = ref.read(authFormProvider);
    if (form != null) {
      await ref.read(authProvider.notifier).completeAuth(
        name:  form.name,
        email: form.email,
      );
      ref.read(authFormProvider.notifier).state = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final form  = ref.watch(authFormProvider);
    final email = form?.email ?? '';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1F1C), Color(0xFF1E2420)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back chevron ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _BackChevron(onTap: () => context.pop()),
              ),
              const SizedBox(height: 36),

              // ── Title block (TIDE exact) ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set your PIN',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a 4-digit PIN to secure your\njournal${email.isNotEmpty ? '\n$email' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A9590),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 44),

              // ── 4 OTP cells — TIDE exact ──────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _PinCell(
                      filled:  i < _digits.length,
                      digit:   i < _digits.length ? _digits[i] : null,
                      // TIDE: first empty cell gets salmon border
                      active: i == _digits.length,
                    ),
                  )),
                ),
              ),
              const SizedBox(height: 24),

              // "Skip PIN" text link (TIDE: "Continue with verification code")
              Center(
                child: GestureDetector(
                  onTap: _skip,
                  child: Text(
                    'Skip PIN',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A9590),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ── Custom dark numpad — TIDE exact ───────────────────────────
              _Numpad(onDigit: _onDigit, onDelete: _onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OTP cell — matches TIDE verify screen cells:
//   rounded square, dark fill, red/salmon border on active-empty cell
// ─────────────────────────────────────────────────────────────────────────────
class _PinCell extends StatelessWidget {
  final bool filled;
  final int? digit;
  final bool active;

  const _PinCell({required this.filled, this.digit, required this.active});

  @override
  Widget build(BuildContext context) {
    final Color border;
    if (filled) {
      border = Colors.white.withValues(alpha: 0.3);
    } else if (active) {
      border = const Color(0xFFE07070); // TIDE's salmon/red border on first empty
    } else {
      border = const Color(0xFF3A4240);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 60, height: 66,
      decoration: BoxDecoration(
        color: filled
            ? const Color(0xFF2E3530)
            : const Color(0xFF252B28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Center(
        child: filled
            ? Text(
                digit.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full custom numpad — TIDE screen 4/5 exact.
//   3-column grid, dark rounded buttons, number + sub-letters
// ─────────────────────────────────────────────────────────────────────────────
class _Numpad extends StatelessWidget {
  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;

  const _Numpad({required this.onDigit, required this.onDelete});

  static const _rows = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
  ];

  static const _subLabels = {
    2: 'ABC', 3: 'DEF',
    4: 'GHI', 5: 'JKL', 6: 'MNO',
    7: 'PQRS', 8: 'TUV', 9: 'WXYZ',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1F1C),
      padding: EdgeInsets.only(
        top: 4,
        bottom: MediaQuery.paddingOf(context).bottom + 4,
      ),
      child: Column(
        children: [
          ..._rows.map((row) => _NumRow(
            digits: row,
            subLabels: _subLabels,
            onDigit: onDigit,
          )),
          // Bottom row: blank · 0 · delete
          SizedBox(
            height: 72,
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                Expanded(child: _NumBtn(digit: 0, onTap: () => onDigit(0))),
                Expanded(
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252B28),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.backspace_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
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

class _NumRow extends StatelessWidget {
  final List<int> digits;
  final Map<int, String> subLabels;
  final ValueChanged<int> onDigit;

  const _NumRow({required this.digits, required this.subLabels, required this.onDigit});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 72,
    child: Row(
      children: digits.map((d) => Expanded(
        child: _NumBtn(
          digit: d,
          sub: subLabels[d],
          onTap: () => onDigit(d),
        ),
      )).toList(),
    ),
  );
}

class _NumBtn extends StatelessWidget {
  final int digit;
  final String? sub;
  final VoidCallback onTap;

  const _NumBtn({required this.digit, this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF252B28),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            digit.toString(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              style: GoogleFonts.poppins(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6A7570),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

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
      child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 22),
    ),
  );
}
