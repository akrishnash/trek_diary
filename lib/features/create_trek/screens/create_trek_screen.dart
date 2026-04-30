import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/trek_templates.dart';
import '../../../core/utils/id_generator.dart';
import '../../../data/models/day.dart';
import '../../../data/models/stop.dart';
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

  // Template autofill state
  List<TrekTemplate> _suggestions   = [];
  TrekTemplate?      _pickedTemplate;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.dispose();
    _regionCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    // Clear pick if user edits name after selecting a template
    if (_pickedTemplate != null &&
        _nameCtrl.text.trim() != _pickedTemplate!.name) {
      _pickedTemplate = null;
    }
    final results = TrekTemplate.search(_nameCtrl.text);
    setState(() => _suggestions = results);
  }

  void _pickTemplate(TrekTemplate t) {
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.text = t.name;
    _nameCtrl.addListener(_onNameChanged);
    if (_regionCtrl.text.isEmpty) _regionCtrl.text = t.region;
    if (_descCtrl.text.isEmpty)   _descCtrl.text   = t.description;
    setState(() {
      _pickedTemplate = t;
      _suggestions    = [];
      _days           = t.totalDays;
      _difficulty     = t.difficulty;
    });
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final days = _buildDays();
    final trek = Trek(
      id:            generateId(),
      name:          name,
      region:        _regionCtrl.text.trim(),
      difficulty:    _difficulty,
      totalDays:     _days,
      coverGradient: '',
      description:   _descCtrl.text.trim(),
      createdAt:     DateTime.now().toIso8601String().split('T').first,
      days:          days,
    );

    ref.read(trekListProvider.notifier).addTrek(trek);
    context.pushReplacement('/trek/${trek.id}');
  }

  List<TrekDay> _buildDays() {
    if (_pickedTemplate != null) {
      final t = _pickedTemplate!;
      return List.generate(t.days.length, (i) {
        final d = t.days[i];
        final stops = d.stops.map((s) => TrekStop(
          id:        generateId(),
          name:      s.name,
          elevation: s.elevation,
          distance:  s.distance,
          weather:   '',
          mood:      '',
          notes:     '',
          photos:    const [],
        )).toList();
        return TrekDay(dayNum: i + 1, title: d.title, stops: stops);
      });
    }
    return List.generate(
      _days,
      (i) => TrekDay(dayNum: i + 1, title: 'Day ${i + 1}', stops: []),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safe    = MediaQuery.paddingOf(context);
    final canSave = _nameCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.sheet,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Photo header ──────────────────────────────────────────────────
          SizedBox(
            height: 230,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800&q=80',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, 0.3),
                  placeholder: (_, __) =>
                      const ColoredBox(color: AppColors.heroDark),
                  errorWidget: (_, __, ___) =>
                      const ColoredBox(color: AppColors.heroDark),
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
                  top: safe.top + 12,
                  left: 16,
                  child: GlassBackButton(onPressed: () => context.pop()),
                ),
                Positioned(
                  left: 24,
                  bottom: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NEW TREK', style: AppTextStyles.eyebrow),
                      const SizedBox(height: 8),
                      Text(
                        'Start a\nnew journey',
                        style: AppTextStyles.heroHeading.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Form ──────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trek name with instant local autocomplete
                  const _FieldLabel('Trek Name'),
                  const SizedBox(height: 6),
                  _NameField(
                    controller:  _nameCtrl,
                    suggestions: _suggestions,
                    onPick:      _pickTemplate,
                  ),

                  // Template banner — shown after picking a trek
                  if (_pickedTemplate != null) ...[
                    const SizedBox(height: 10),
                    _TemplateBanner(template: _pickedTemplate!),
                  ],

                  // Day-wise preview — shown after picking a trek
                  if (_pickedTemplate != null) ...[
                    const SizedBox(height: 16),
                    _DayPreviewList(template: _pickedTemplate!),
                  ],

                  const SizedBox(height: 16),
                  _FormField(
                    label:      'Region',
                    controller: _regionCtrl,
                    hint:       'e.g. Uttarakhand, India',
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label:      'Description (optional)',
                    controller: _descCtrl,
                    hint:       'A short note about this trek…',
                    maxLines:   3,
                  ),
                  const SizedBox(height: 20),

                  const _FieldLabel('Duration'),
                  const SizedBox(height: 10),
                  _DaysStepper(
                    value:     _days,
                    onChanged: (v) => setState(() => _days = v),
                  ),
                  const SizedBox(height: 20),

                  ChipPicker(
                    label:     'Difficulty',
                    options:   AppConstants.difficultyOptions,
                    value:     _difficulty,
                    onChanged: (v) => setState(() => _difficulty = v),
                  ),

                  const SizedBox(height: 8),
                  PrimaryButton(
                    label:     'Create Trek',
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

// ── Name field with instant local autocomplete ────────────────────────────────

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final List<TrekTemplate> suggestions;
  final ValueChanged<TrekTemplate> onPick;

  const _NameField({
    required this.controller,
    required this.suggestions,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            style: AppTextStyles.body.copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g. Kedarkantha Trek',
              hintStyle:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                borderSide:
                    const BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
          ),
          if (suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: suggestions.map((t) {
                  final isFirst = t == suggestions.first;
                  final isLast  = t == suggestions.last;
                  return InkWell(
                    borderRadius: BorderRadius.vertical(
                      top:    Radius.circular(isFirst ? 14 : 0),
                      bottom: Radius.circular(isLast  ? 14 : 0),
                    ),
                    onTap: () => onPick(t),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      child: Row(children: [
                        const Icon(Icons.terrain_rounded,
                            size: 15, color: AppColors.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.name,
                                  style: AppTextStyles.body
                                      .copyWith(fontSize: 13)),
                              Text(
                                '${t.region}  ·  ${t.totalDays} days  ·  ${t.difficulty}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${t.totalStops} stops',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );
}

// ── Template selected banner ──────────────────────────────────────────────────

class _TemplateBanner extends StatelessWidget {
  final TrekTemplate template;
  const _TemplateBanner({required this.template});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 16, color: AppColors.accentLight),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${template.totalDays}-day itinerary auto-filled  ·  ${template.totalStops} stops ready',
              style: AppTextStyles.label.copyWith(
                color: AppColors.accentLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]),
      );
}

// ── Day-wise preview list ─────────────────────────────────────────────────────

class _DayPreviewList extends StatelessWidget {
  final TrekTemplate template;
  const _DayPreviewList({required this.template});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Itinerary Preview'),
          const SizedBox(height: 8),
          ...template.days.asMap().entries.map((e) {
            final i   = e.key;
            final day = e.value;
            return _DayPreviewCard(dayNum: i + 1, day: day);
          }),
        ],
      );
}

class _DayPreviewCard extends StatelessWidget {
  final int         dayNum;
  final DayTemplate day;
  const _DayPreviewCard({required this.dayNum, required this.day});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Day $dayNum',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  day.title,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            // Stops
            if (day.stops.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...day.stops.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.name,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (s.elevation > 0)
                          Text(
                            '${s.elevation} m',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: AppColors.textHint,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.8,
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
              hintStyle:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                borderSide:
                    const BorderSide(color: AppColors.accent, width: 1.5),
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
            icon:  Icons.remove_rounded,
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
            icon:  Icons.add_rounded,
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
          width: 36,
          height: 36,
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
            icon,
            size: 18,
            color: onTap != null ? AppColors.accent : AppColors.textHint,
          ),
        ),
      );
}
