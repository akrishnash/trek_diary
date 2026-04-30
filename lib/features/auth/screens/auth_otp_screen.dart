import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/auth_provider.dart';

class AuthOtpScreen extends ConsumerStatefulWidget {
  const AuthOtpScreen({super.key});

  @override
  ConsumerState<AuthOtpScreen> createState() => _AuthOtpScreenState();
}

class _AuthOtpScreenState extends ConsumerState<AuthOtpScreen> {
  final List<int> _digits = [];
  int _resendSeconds = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          t.cancel();
        }
      });
    });
  }

  void _onDigit(int d) {
    if (_digits.length >= 6) return;
    setState(() => _digits.add(d));
    if (_digits.length == 6) _submit();
  }

  void _onDelete() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  Future<void> _submit() async {
    // TODO: Replace with real Firebase Phone Auth verification
    // e.g. await FirebaseAuth.instance.signInWithCredential(...)
    // For now, any 6-digit code succeeds.
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    context.push('/auth/profile');
  }

  @override
  Widget build(BuildContext context) {
    final form  = ref.watch(authFormProvider);
    final phone = form?.phone ?? '';

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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _BackChevron(onTap: () => context.pop()),
              ),
              const SizedBox(height: 36),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify your number',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 6-digit code sent to\n+91 $phone',
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

              // 6 OTP cells
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(6, (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _OtpCell(
                      filled:  i < _digits.length,
                      digit:   i < _digits.length ? _digits[i] : null,
                      active:  i == _digits.length,
                    ),
                  )),
                ),
              ),
              const SizedBox(height: 24),

              // Resend link
              Center(
                child: GestureDetector(
                  onTap: _resendSeconds == 0 ? _startResendTimer : null,
                  child: Text(
                    _resendSeconds > 0
                        ? 'Resend code in ${_resendSeconds}s'
                        : 'Resend code',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _resendSeconds == 0
                          ? Colors.white
                          : const Color(0xFF8A9590),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              _Numpad(onDigit: _onDigit, onDelete: _onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

// OTP cell — matches TIDE PIN cell style
class _OtpCell extends StatelessWidget {
  final bool filled;
  final int? digit;
  final bool active;

  const _OtpCell({required this.filled, this.digit, required this.active});

  @override
  Widget build(BuildContext context) {
    final Color border;
    if (filled) {
      border = Colors.white.withValues(alpha: 0.3);
    } else if (active) {
      border = const Color(0xFFE07070);
    } else {
      border = const Color(0xFF3A4240);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 46, height: 56,
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF2E3530) : const Color(0xFF252B28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Center(
        child: filled
            ? Text(
                digit.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}

// Numpad — identical to auth_pin_screen numpad
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
