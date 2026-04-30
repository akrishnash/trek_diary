import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../shared/widgets/glass.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late String _experience;
  bool _saving = false;
  bool _dirty  = false;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    _nameCtrl     = TextEditingController(text: auth.name);
    _usernameCtrl = TextEditingController(text: auth.username);
    _bioCtrl      = TextEditingController(text: auth.bio);
    _ageCtrl      = TextEditingController(text: auth.age > 0 ? auth.age.toString() : '');
    _emailCtrl    = TextEditingController(text: auth.email);
    _phoneCtrl    = TextEditingController(text: auth.phone);
    _locationCtrl = TextEditingController(text: auth.location);
    _experience   = auth.experience;

    for (final c in [_nameCtrl, _usernameCtrl, _bioCtrl, _ageCtrl,
                     _emailCtrl, _phoneCtrl, _locationCtrl]) {
      c.addListener(() => setState(() => _dirty = true));
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _usernameCtrl, _bioCtrl, _ageCtrl,
                     _emailCtrl, _phoneCtrl, _locationCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final ageText = _ageCtrl.text.trim();
    final age = ageText.isNotEmpty ? int.tryParse(ageText) : null;
    if (ageText.isNotEmpty && (age == null || age < 5 || age > 120)) {
      _showSnack('Please enter a valid age (5–120)');
      return;
    }
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack('Name cannot be empty');
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(authProvider.notifier).updateProfile(
        name:       _nameCtrl.text.trim(),
        username:   _usernameCtrl.text.trim(),
        bio:        _bioCtrl.text.trim(),
        age:        age,
        email:      _emailCtrl.text.trim(),
        phone:      _phoneCtrl.text.trim(),
        location:   _locationCtrl.text.trim(),
        experience: _experience,
      );
      setState(() => _dirty = false);
      if (mounted) _showSnack('Profile saved', success: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: success ? AppColors.accent : const Color(0xFF2A3028),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth  = ref.watch(authProvider);
    final safe  = MediaQuery.paddingOf(context);
    final size  = MediaQuery.sizeOf(context);
    final sheetAt = size.height * 0.32;
    final initials = _initials(auth.name);

    return Scaffold(
      backgroundColor: AppColors.heroDark,
      body: Stack(
        children: [
          // Photo background
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.3),
              placeholder: (_, __) => const ColoredBox(color: AppColors.heroDark),
              errorWidget: (_, __, ___) => const ColoredBox(color: AppColors.heroDark),
            ),
          ),

          // Scrim
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x88000000), Color(0x00000000), Color(0xF01A1F1C)],
                  stops: [0.0, 0.25, 0.55],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: safe.top + 12, left: 16,
            child: GlassBackButton(onPressed: () => context.pop()),
          ),

          // Avatar + name on photo
          Positioned(
            left: 0, right: 0,
            bottom: size.height - sheetAt + 16,
            child: Column(
              children: [
                // Avatar circle
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4A7C5F), Color(0xFF2E5040)],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  auth.name.isEmpty ? 'Your Profile' : auth.name,
                  style: AppTextStyles.heroHeading.copyWith(fontSize: 22),
                ),
                if (auth.experience.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      auth.experience,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Content sheet
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
                  padding: EdgeInsets.fromLTRB(20, 24, 20, safe.bottom + 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Personal
                      _SectionLabel('Personal'),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Full Name',
                        controller: _nameCtrl,
                        hint: 'Your full name',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Username',
                        controller: _usernameCtrl,
                        hint: '@username',
                        icon: Icons.alternate_email_rounded,
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Age',
                        controller: _ageCtrl,
                        hint: 'Your age',
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Bio',
                        controller: _bioCtrl,
                        hint: 'A short bio about yourself...',
                        icon: Icons.notes_rounded,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),

                      // Section: Contact
                      _SectionLabel('Contact'),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Email',
                        controller: _emailCtrl,
                        hint: 'your@email.com',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Phone',
                        controller: _phoneCtrl,
                        hint: '+91 00000 00000',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),
                      _Field(
                        label: 'Location',
                        controller: _locationCtrl,
                        hint: 'City, Country',
                        icon: Icons.location_on_outlined,
                      ),

                      const SizedBox(height: 24),

                      // Section: Trekking
                      _SectionLabel('Trekking'),
                      const SizedBox(height: 10),
                      Text(
                        'Experience Level',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Beginner', 'Intermediate', 'Expert']
                            .map((level) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _ExperienceChip(
                                    label: level,
                                    selected: _experience == level,
                                    onTap: () => setState(() {
                                      _experience = level;
                                      _dirty = true;
                                    }),
                                  ),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 32),

                      // Save button
                      _SaveButton(
                        dirty: _dirty,
                        saving: _saving,
                        onTap: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppTextStyles.sectionLabel,
  );
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const _Field({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 5),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textHint,
          ),
          prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.accent.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
        ),
      ),
    ],
  );
}

class _ExperienceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ExperienceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.border,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    ),
  );
}

class _SaveButton extends StatelessWidget {
  final bool dirty;
  final bool saving;
  final VoidCallback onTap;

  const _SaveButton({
    required this.dirty,
    required this.saving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: dirty ? Colors.white : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: dirty
            ? null
            : Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (dirty && !saving) ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: saving
                ? const Center(
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.sheet,
                      ),
                    ),
                  )
                : Text(
                    dirty ? 'Save Changes' : 'Up to date',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: dirty ? AppColors.sheet : AppColors.textHint,
                    ),
                  ),
          ),
        ),
      ),
    ),
  );
}
