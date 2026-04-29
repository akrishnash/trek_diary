import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/stop.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/chip_picker.dart';
import '../../../shared/widgets/glass.dart';
import '../../../shared/widgets/primary_button.dart';

class AddStopScreen extends ConsumerStatefulWidget {
  final String trekId;
  final int dayNum;

  const AddStopScreen({super.key, required this.trekId, required this.dayNum});

  @override
  ConsumerState<AddStopScreen> createState() => _AddStopScreenState();
}

class _AddStopScreenState extends ConsumerState<AddStopScreen> {
  final _nameCtrl  = TextEditingController();
  final _elevCtrl  = TextEditingController();
  final _distCtrl  = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _weather = '☀️ Sunny';
  String _mood    = '😊 Happy';

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _elevCtrl.dispose();
    _distCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final stop = TrekStop(
      id:        'stop-${DateTime.now().millisecondsSinceEpoch}',
      name:      name,
      elevation: int.tryParse(_elevCtrl.text.trim()) ?? 0,
      distance:  double.tryParse(_distCtrl.text.trim()) ?? 0.0,
      weather:   _weather,
      mood:      _mood,
      notes:     _notesCtrl.text.trim(),
      photos:    [],
    );

    ref.read(trekListProvider.notifier).addStop(widget.trekId, widget.dayNum, stop);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final treks   = ref.watch(trekListProvider);
    final trek    = treks.firstWhere((t) => t.id == widget.trekId);
    final day     = trek.days.firstWhere((d) => d.dayNum == widget.dayNum);
    final safe    = MediaQuery.of(context).padding;
    final canSave = _nameCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.sheet,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Photo header ───────────────────────────────────────────────────
          SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: getTrekPhotoUrl(trek),
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, 0.0),
                  placeholder: (_, __) => const ColoredBox(color: AppColors.heroDark),
                  errorWidget:  (_, __, ___) => const ColoredBox(color: AppColors.heroDark),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x77000000), Color(0xDD000000)],
                    ),
                  ),
                ),
                Positioned(
                  top: safe.top + 12, left: 16,
                  child: GlassBackButton(onPressed: () => context.pop()),
                ),
                Positioned(
                  left: 24, bottom: 26,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAY ${widget.dayNum}  ·  ${trek.name.toUpperCase()}',
                        style: AppTextStyles.eyebrow,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day.title,
                        style: AppTextStyles.heroHeading.copyWith(
                          fontSize: 26, fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Form ───────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormField(
                    label: 'Stop Name',
                    controller: _nameCtrl,
                    hint: 'e.g. Ghangaria Camp',
                  ),
                  const SizedBox(height: 16),

                  Row(children: [
                    Expanded(
                      child: _FormField(
                        label: 'Elevation (m)',
                        controller: _elevCtrl,
                        hint: '3200',
                        inputType: const TextInputType.numberWithOptions(signed: false),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _FormField(
                        label: 'Distance (km)',
                        controller: _distCtrl,
                        hint: '8.5',
                        inputType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  ChipPicker(
                    label: 'Weather',
                    options: AppConstants.weatherOptions,
                    value: _weather,
                    onChanged: (v) => setState(() => _weather = v),
                  ),

                  ChipPicker(
                    label: 'Mood',
                    options: AppConstants.moodOptions,
                    value: _mood,
                    onChanged: (v) => setState(() => _mood = v),
                  ),

                  _FormField(
                    label: 'Notes',
                    controller: _notesCtrl,
                    hint: 'What did you see, feel, or want to remember?',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: 'Log Stop',
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
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.inputType,
    this.inputFormatters,
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
        keyboardType: inputType,
        inputFormatters: inputFormatters,
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
