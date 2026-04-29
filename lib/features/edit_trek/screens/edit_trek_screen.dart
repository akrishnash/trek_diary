import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/chip_picker.dart';
import '../../../shared/widgets/glass.dart';
import '../../../shared/widgets/primary_button.dart';

class EditTrekScreen extends ConsumerStatefulWidget {
  final String trekId;
  const EditTrekScreen({super.key, required this.trekId});

  @override
  ConsumerState<EditTrekScreen> createState() => _EditTrekScreenState();
}

class _EditTrekScreenState extends ConsumerState<EditTrekScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _regionCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _coverCtrl;
  late String _difficulty;
  bool _previewError = false;

  @override
  void initState() {
    super.initState();
    final trek = ref.read(trekListProvider).firstWhere((t) => t.id == widget.trekId);
    _nameCtrl   = TextEditingController(text: trek.name);
    _regionCtrl = TextEditingController(text: trek.region);
    _descCtrl   = TextEditingController(text: trek.description);
    _coverCtrl  = TextEditingController(text: trek.coverImageUrl ?? '');
    _difficulty = trek.difficulty;
    _nameCtrl.addListener(() => setState(() {}));
    _coverCtrl.addListener(() => setState(() { _previewError = false; }));
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _regionCtrl.dispose();
    _descCtrl.dispose(); _coverCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final cover = _coverCtrl.text.trim();

    ref.read(trekListProvider.notifier).updateTrek(widget.trekId, (t) => t.copyWith(
      name:          name,
      region:        _regionCtrl.text.trim(),
      description:   _descCtrl.text.trim(),
      difficulty:    _difficulty,
      coverImageUrl: cover.isNotEmpty ? cover : null,
      clearCoverImage: cover.isEmpty,
    ));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final safe     = MediaQuery.paddingOf(context);
    final canSave  = _nameCtrl.text.trim().isNotEmpty;
    final coverUrl = _coverCtrl.text.trim();

    return Scaffold(
      backgroundColor: AppColors.sheet,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Cover preview header ───────────────────────────────────────────
          SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (coverUrl.isNotEmpty && !_previewError)
                  CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _previewError = true);
                      });
                      return const ColoredBox(color: AppColors.heroDark);
                    },
                  )
                else
                  const ColoredBox(color: AppColors.heroDark),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x55000000), Color(0xDD000000)],
                    ),
                  ),
                ),
                Positioned(top: safe.top + 12, left: 16,
                  child: GlassBackButton(onPressed: () => context.pop())),
                Positioned(left: 24, bottom: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EDIT TREK', style: AppTextStyles.eyebrow),
                      const SizedBox(height: 8),
                      Text('Update details', style: AppTextStyles.heroHeading.copyWith(
                        fontSize: 28, fontWeight: FontWeight.w300,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Form ──────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover image URL
                  _SectionLabel('Cover Photo'),
                  const SizedBox(height: 6),
                  _DarkField(
                    controller: _coverCtrl,
                    hint: 'Paste an image URL (optional)',
                    keyboardType: TextInputType.url,
                  ),
                  if (_previewError) ...[
                    const SizedBox(height: 4),
                    Text('Could not load this URL — check it\'s a direct image link.',
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFC4524A))),
                  ],
                  const SizedBox(height: 20),

                  _SectionLabel('Trek Name'),
                  const SizedBox(height: 6),
                  _DarkField(controller: _nameCtrl, hint: 'e.g. Valley of Flowers'),
                  const SizedBox(height: 16),

                  _SectionLabel('Region'),
                  const SizedBox(height: 6),
                  _DarkField(controller: _regionCtrl, hint: 'e.g. Uttarakhand, India'),
                  const SizedBox(height: 16),

                  _SectionLabel('Description (optional)'),
                  const SizedBox(height: 6),
                  _DarkField(controller: _descCtrl, hint: 'A short note about this trek…', maxLines: 3),
                  const SizedBox(height: 20),

                  ChipPicker(
                    label: 'Difficulty',
                    options: AppConstants.difficultyOptions,
                    value: _difficulty,
                    onChanged: (v) => setState(() => _difficulty = v),
                  ),

                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: 'Save Changes',
                    onPressed: canSave ? _save : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppTextStyles.label.copyWith(
      color: AppColors.textHint, fontWeight: FontWeight.w800,
      fontSize: 11, letterSpacing: 0.8,
    ),
  );
}

class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _DarkField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    style: GoogleFonts.poppins(
      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    ),
  );
}
