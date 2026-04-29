import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/auth_provider.dart';

class AuthProfileScreen extends ConsumerStatefulWidget {
  const AuthProfileScreen({super.key});

  @override
  ConsumerState<AuthProfileScreen> createState() => _AuthProfileScreenState();
}

class _AuthProfileScreenState extends ConsumerState<AuthProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl  = TextEditingController();
  final _nameFocus = FocusNode();
  final _ageFocus  = FocusNode();
  String _experience = '';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill name if coming from Google or email flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = ref.read(authFormProvider);
      if (form != null && form.name.isNotEmpty) {
        _nameCtrl.text = form.name;
      }
    });
    _nameCtrl.addListener(() => setState(() {}));
    _ageCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _nameFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  bool get _valid {
    final name = _nameCtrl.text.trim();
    final ageText = _ageCtrl.text.trim();
    if (name.isEmpty) return false;
    final age = int.tryParse(ageText);
    return age != null && age >= 10 && age <= 100;
  }

  Future<void> _submit() async {
    if (!_valid || _submitting) return;
    setState(() => _submitting = true);
    try {
      final form = ref.read(authFormProvider);
      await ref.read(authProvider.notifier).completeProfile(
        name:       _nameCtrl.text.trim(),
        age:        int.parse(_ageCtrl.text.trim()),
        phone:      form?.phone ?? '',
        experience: _experience,
      );
      ref.read(authFormProvider.notifier).state = null;
      // Router redirect fires automatically to /
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1F1C), Color(0xFF252B28)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
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
                        'Complete your profile',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tell us a bit about yourself',
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full name
                      _DarkField(
                        controller: _nameCtrl,
                        focusNode: _nameFocus,
                        hint: 'Full name',
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _ageFocus.requestFocus(),
                      ),
                      const SizedBox(height: 12),

                      // Age
                      _DarkField(
                        controller: _ageCtrl,
                        focusNode: _ageFocus,
                        hint: 'Age',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 24),

                      // Experience level chips
                      Text(
                        'Experience level',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF8A9590),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: ['Beginner', 'Intermediate', 'Expert'].map((level) {
                          final selected = _experience == level;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _experience = level),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFF4A7C5F)
                                      : const Color(0xFF252B28),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFF4A7C5F)
                                        : const Color(0xFF3A4240),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  level,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF8A9590),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 36),

                      // Continue button
                      _ContinueButton(
                        enabled: _valid,
                        loading: _submitting,
                        onTap: _submit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _DarkField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
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
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
    ),
  );
}

class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;
  const _ContinueButton({
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

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
          onTap: (enabled && !loading) ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: loading
                ? const Center(
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1A1F1C),
                      ),
                    ),
                  )
                : Text(
                    'Get Started',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? const Color(0xFF1A1F1C)
                          : const Color(0xFF6A7570),
                    ),
                  ),
          ),
        ),
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
      child: const Icon(
        Icons.chevron_left_rounded,
        color: Colors.white,
        size: 22,
      ),
    ),
  );
}
