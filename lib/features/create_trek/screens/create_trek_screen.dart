import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/day.dart';
import '../../../data/models/trek.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/chip_picker.dart';
import '../../../shared/widgets/glass.dart';
import '../../../shared/widgets/primary_button.dart';

class CreateTrekScreen extends ConsumerStatefulWidget {
  const CreateTrekScreen({super.key});

  @override
  ConsumerState<CreateTrekScreen> createState() => _CreateTrekScreenState();
}

class _CreateTrekScreenState extends ConsumerState<CreateTrekScreen> {
  final _nameCtrl   = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _descCtrl   = TextEditingController();
  int    _days       = 3;
  String _difficulty = 'Moderate';

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _regionCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final trek = Trek(
      id:             'trek-${DateTime.now().millisecondsSinceEpoch}',
      name:           name,
      region:         _regionCtrl.text.trim(),
      difficulty:     _difficulty,
      totalDays:      _days,
      coverGradient:  '',
      description:    _descCtrl.text.trim(),
      createdAt:      DateTime.now().toIso8601String().split('T').first,
      days: List.generate(_days, (i) => TrekDay(
        dayNum: i + 1, title: 'Day ${i + 1}', stops: [],
      )),
    );

    ref.read(trekListProvider.notifier).addTrek(trek);
    context.pushReplacement('/trek/${trek.id}');
  }

  @override
  Widget build(BuildContext context) {
    final safe    = MediaQuery.of(context).padding;
    final canSave = _nameCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.sheet,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Photo header (TIDE screen 0 / 3 style) ─────────────────────────
          SizedBox(
            height: 230,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800&q=80',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, 0.3),
                  placeholder: (_, __) => const ColoredBox(color: AppColors.heroDark),
                  errorWidget:  (_, __, ___) => const ColoredBox(color: AppColors.heroDark),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x77000000), Color(0xCC000000)],
                    ),
                  ),
                ),
                Positioned(
                  top: safe.top + 12, left: 16,
                  child: GlassBackButton(onPressed: () => context.pop()),
                ),
                // Title — TIDE thin tracked text on photo
                Positioned(
                  left: 24, bottom: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NEW TREK', style: AppTextStyles.eyebrow),
                      const SizedBox(height: 8),
                      Text(
                        'Start a\nnew journey',
                        style: AppTextStyles.heroHeading.copyWith(
                          fontSize: 30, fontWeight: FontWeight.w300, letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Form in warm sheet ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormField(
                    label: 'Trek Name',
                    controller: _nameCtrl,
                    hint: 'e.g. Valley of Flowers',
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Region',
                    controller: _regionCtrl,
                    hint: 'e.g. Uttarakhand, India',
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Description (optional)',
                    controller: _descCtrl,
                    hint: 'A short note about this trek…',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Duration stepper
                  _FieldLabel('Duration'),
                  const SizedBox(height: 10),
                  _DaysStepper(
                    value: _days,
                    onChanged: (v) => setState(() => _days = v),
                  ),
                  const SizedBox(height: 20),

                  // Difficulty
                  ChipPicker(
                    label: 'Difficulty',
                    options: AppConstants.difficultyOptions,
                    value: _difficulty,
                    onChanged: (v) => setState(() => _difficulty = v),
                  ),

                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: 'Create Trek',
                    onPressed: canSave ? _submit : null,
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

// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppTextStyles.label.copyWith(
      color: AppColors.textHint, fontWeight: FontWeight.w800,
      fontSize: 11, letterSpacing: 0.8,
    ),
  );
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FieldLabel(label),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.body.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      ),
    ],
  );
}

class _DaysStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _DaysStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _StepBtn(
        icon: Icons.remove_rounded,
        onTap: value > 1 ? () => onChanged(value - 1) : null,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Text(
          '$value ${value == 1 ? 'day' : 'days'}',
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      _StepBtn(
        icon: Icons.add_rounded,
        onTap: value < 30 ? () => onChanged(value + 1) : null,
      ),
    ],
  );
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: onTap != null
          ? AppColors.accent.withValues(alpha: 0.10)
          : AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: onTap != null
            ? AppColors.accent.withValues(alpha: 0.30)
            : AppColors.border,
        ),
      ),
      child: Icon(
        icon, size: 18,
        color: onTap != null ? AppColors.accent : AppColors.textHint,
      ),
    ),
  );
}
