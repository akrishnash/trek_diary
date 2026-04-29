import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/diary_entry.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/glass.dart';
import '../../../shared/widgets/primary_button.dart';

class DiaryEntryScreen extends ConsumerStatefulWidget {
  final String trekId;
  final int dayNum;

  const DiaryEntryScreen({super.key, required this.trekId, required this.dayNum});

  @override
  ConsumerState<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends ConsumerState<DiaryEntryScreen> {
  late final TextEditingController _textCtrl;

  // Each image entry = {url, caption}
  final List<_ImageEntry> _entries = [];
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final trek = ref.read(trekListProvider).firstWhere((t) => t.id == widget.trekId);
    final day  = trek.days.firstWhere((d) => d.dayNum == widget.dayNum);
    final existing = day.diary;

    _textCtrl = TextEditingController(text: existing?.text ?? '');
    _textCtrl.addListener(() => setState(() { _dirty = true; }));

    if (existing != null) {
      for (final img in existing.images) {
        _entries.add(_ImageEntry(
          urlCtrl:     TextEditingController(text: img.url),
          captionCtrl: TextEditingController(text: img.caption),
        ));
      }
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    for (final e in _entries) { e.urlCtrl.dispose(); e.captionCtrl.dispose(); }
    super.dispose();
  }

  void _addImageEntry() {
    setState(() {
      final entry = _ImageEntry(
        urlCtrl:     TextEditingController(),
        captionCtrl: TextEditingController(),
      );
      entry.urlCtrl.addListener(() => setState(() { _dirty = true; }));
      entry.captionCtrl.addListener(() => setState(() { _dirty = true; }));
      _entries.add(entry);
      _dirty = true;
    });
  }

  void _removeEntry(int i) {
    setState(() {
      _entries[i].urlCtrl.dispose();
      _entries[i].captionCtrl.dispose();
      _entries.removeAt(i);
      _dirty = true;
    });
  }

  void _save() {
    final images = _entries
        .where((e) => e.urlCtrl.text.trim().isNotEmpty)
        .map((e) => DiaryImage(
              url:     e.urlCtrl.text.trim(),
              caption: e.captionCtrl.text.trim(),
            ))
        .toList();

    ref.read(trekListProvider.notifier).setDiary(
      widget.trekId,
      widget.dayNum,
      DiaryEntry(text: _textCtrl.text.trim(), images: images),
    );
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Diary saved', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safe  = MediaQuery.paddingOf(context);
    final treks = ref.watch(trekListProvider);
    final trek  = treks.firstWhere((t) => t.id == widget.trekId);
    final day   = trek.days.firstWhere((d) => d.dayNum == widget.dayNum);
    final photo = trek.coverImageUrl?.isNotEmpty == true
        ? trek.coverImageUrl!
        : getTrekPhotoUrl(trek);

    return Scaffold(
      backgroundColor: AppColors.sheet,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Photo header ──────────────────────────────────────────────────
          SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: photo, fit: BoxFit.cover,
                  alignment: const Alignment(0, 0),
                  placeholder: (_, __) => const ColoredBox(color: AppColors.heroDark),
                  errorWidget:  (_, __, ___) => const ColoredBox(color: AppColors.heroDark),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Color(0x55000000), Color(0xDD000000)],
                    ),
                  ),
                ),
                Positioned(top: safe.top + 12, left: 16,
                  child: GlassBackButton(onPressed: () => context.pop())),
                Positioned(left: 24, bottom: 26,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAY ${widget.dayNum}  ·  ${trek.name.toUpperCase()}',
                        style: AppTextStyles.eyebrow,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        day.title,
                        style: AppTextStyles.heroHeading.copyWith(
                          fontSize: 24, fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.auto_stories_rounded, size: 12, color: AppColors.accentLight),
                        const SizedBox(width: 5),
                        Text('Diary Entry', style: AppTextStyles.eyebrow.copyWith(
                          color: AppColors.accentLight, letterSpacing: 2,
                        )),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Entry form ────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Journal text
                  Text('JOURNAL', style: AppTextStyles.label.copyWith(
                    color: AppColors.textHint, fontWeight: FontWeight.w800,
                    fontSize: 11, letterSpacing: 0.8,
                  )),
                  const SizedBox(height: 8),
                  _DiaryTextField(
                    controller: _textCtrl,
                    hint: 'What did you see, feel, or want to remember about this day?',
                    minLines: 5,
                  ),
                  const SizedBox(height: 28),

                  // Photos section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PHOTOS', style: AppTextStyles.label.copyWith(
                        color: AppColors.textHint, fontWeight: FontWeight.w800,
                        fontSize: 11, letterSpacing: 0.8,
                      )),
                      GestureDetector(
                        onTap: _addImageEntry,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 14, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text('Add Photo', style: GoogleFonts.poppins(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_entries.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library_outlined, size: 32, color: AppColors.textHint),
                          const SizedBox(height: 8),
                          Text('No photos yet', style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textMuted,
                          )),
                          const SizedBox(height: 4),
                          Text('Tap "+ Add Photo" to add an image URL + caption',
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...List.generate(_entries.length, (i) => _PhotoEntryCard(
                      key: ValueKey(i),
                      entry: _entries[i],
                      index: i + 1,
                      onRemove: () => _removeEntry(i),
                    )),

                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: _dirty ? 'Save Diary' : 'Saved',
                    onPressed: _dirty ? _save : null,
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
// _PhotoEntryCard — one image URL + caption entry
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoEntryCard extends StatefulWidget {
  final _ImageEntry entry;
  final int index;
  final VoidCallback onRemove;

  const _PhotoEntryCard({super.key, required this.entry, required this.index, required this.onRemove});

  @override
  State<_PhotoEntryCard> createState() => _PhotoEntryCardState();
}

class _PhotoEntryCardState extends State<_PhotoEntryCard> {
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    widget.entry.urlCtrl.addListener(() => setState(() => _loadError = false));
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.entry.urlCtrl.text.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            child: SizedBox(
              height: 180,
              child: url.isNotEmpty && !_loadError
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) setState(() => _loadError = true);
                        });
                        return _ImagePlaceholder(hasError: true);
                      },
                    )
                  : _ImagePlaceholder(hasError: _loadError && url.isNotEmpty),
            ),
          ),

          // URL + caption fields
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Photo ${widget.index}', style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary,
                    )),
                    GestureDetector(
                      onTap: widget.onRemove,
                      child: Icon(Icons.delete_outline_rounded, size: 18, color: const Color(0xFFC4524A)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _DiaryTextField(
                  controller: widget.entry.urlCtrl,
                  hint: 'Image URL (e.g. https://...)',
                  minLines: 1,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 8),
                _DiaryTextField(
                  controller: widget.entry.captionCtrl,
                  hint: 'Caption (optional)',
                  minLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final bool hasError;
  const _ImagePlaceholder({this.hasError = false});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.heroDark,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasError ? Icons.broken_image_outlined : Icons.add_photo_alternate_outlined,
            size: 32, color: AppColors.textHint,
          ),
          const SizedBox(height: 6),
          Text(
            hasError ? 'Could not load image' : 'Enter a URL above',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint),
          ),
        ],
      ),
    ),
  );
}

class _DiaryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int minLines;
  final TextInputType? keyboardType;

  const _DiaryTextField({
    required this.controller,
    required this.hint,
    this.minLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    minLines: minLines,
    maxLines: minLines == 1 ? 1 : null,
    keyboardType: keyboardType ?? (minLines > 1 ? TextInputType.multiline : TextInputType.text),
    textInputAction: minLines > 1 ? TextInputAction.newline : TextInputAction.done,
    style: GoogleFonts.poppins(
      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400, height: 1.6,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.surfaceDim,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    ),
  );
}

class _ImageEntry {
  final TextEditingController urlCtrl;
  final TextEditingController captionCtrl;
  _ImageEntry({required this.urlCtrl, required this.captionCtrl});
}
