import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/diary_entry.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/glass.dart';

// Fallback photo — same as login screen
const _kDefaultPhoto =
    'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&q=80';

class DiaryEntryScreen extends ConsumerStatefulWidget {
  final String trekId;
  final int dayNum;

  const DiaryEntryScreen({super.key, required this.trekId, required this.dayNum});

  @override
  ConsumerState<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends ConsumerState<DiaryEntryScreen> {
  final _textCtrl   = TextEditingController();
  final _focusNode  = FocusNode();
  final _scrollCtrl = ScrollController();
  final _picker     = ImagePicker();

  final List<DiaryImage> _images = [];
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final trek     = ref.read(trekListProvider).firstWhere((t) => t.id == widget.trekId);
    final day      = trek.days.firstWhere((d) => d.dayNum == widget.dayNum);
    final existing = day.diary;

    if (existing != null) {
      _textCtrl.text = existing.text;
      _images.addAll(existing.images);
    }
    _textCtrl.addListener(() => setState(() => _dirty = true));
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Formatting helpers ───────────────────────────────────────────────────

  void _insertAtCursor(String prefix, {String suffix = '', bool linePrefix = false}) {
    final ctrl      = _textCtrl;
    final sel       = ctrl.selection;
    final text      = ctrl.text;
    if (!sel.isValid) return;

    if (linePrefix) {
      // Find start of current line
      final lineStart = text.lastIndexOf('\n', sel.start > 0 ? sel.start - 1 : 0);
      final insertAt  = lineStart < 0 ? 0 : lineStart + 1;
      final already   = text.substring(insertAt).startsWith(prefix);
      final newText   = already
          ? text.replaceFirst(prefix, '', insertAt)
          : text.substring(0, insertAt) + prefix + text.substring(insertAt);
      ctrl.value = TextEditingValue(
        text:      newText,
        selection: TextSelection.collapsed(offset: sel.start + (already ? -prefix.length : prefix.length)),
      );
    } else {
      // Wrap selection
      final selected  = text.substring(sel.start, sel.end);
      final wrapped   = '$prefix$selected$suffix';
      final newText   = text.replaceRange(sel.start, sel.end, wrapped);
      ctrl.value = TextEditingValue(
        text:      newText,
        selection: TextSelection(
          baseOffset:   sel.start + prefix.length,
          extentOffset: sel.start + prefix.length + selected.length,
        ),
      );
    }
    setState(() => _dirty = true);
  }

  void _fmtHeading1()  => _insertAtCursor('# ',  linePrefix: true);
  void _fmtHeading2()  => _insertAtCursor('## ', linePrefix: true);
  void _fmtBold()      => _insertAtCursor('**', suffix: '**');
  void _fmtItalic()    => _insertAtCursor('_',  suffix: '_');
  void _fmtBullet()    => _insertAtCursor('• ',  linePrefix: true);

  Future<void> _pickImage() async {
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (result == null) return;
    setState(() {
      _images.add(DiaryImage(localPath: result.path));
      _dirty = true;
    });
  }

  void _removeImage(int i) => setState(() { _images.removeAt(i); _dirty = true; });

  void _save() {
    ref.read(trekListProvider.notifier).setDiary(
      widget.trekId,
      widget.dayNum,
      DiaryEntry(text: _textCtrl.text.trim(), images: List.from(_images)),
    );
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Diary saved', style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final safe  = MediaQuery.paddingOf(context);
    final treks = ref.watch(trekListProvider);
    final trek  = treks.firstWhere((t) => t.id == widget.trekId);
    final day   = trek.days.firstWhere((d) => d.dayNum == widget.dayNum);

    final bgPhoto = trek.coverImageUrl?.isNotEmpty == true
        ? trek.coverImageUrl!
        : getTrekPhotoUrl(trek);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1208),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Full-bleed background photo ──────────────────────────────────
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: bgPhoto,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.2),
              placeholder: (_, __) => const ColoredBox(color: Color(0xFF0D1208)),
              errorWidget: (_, __, ___) => CachedNetworkImage(
                imageUrl: _kDefaultPhoto,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(color: Color(0xFF0D1208)),
                errorWidget: (_, __, ___) => const ColoredBox(color: Color(0xFF0D1208)),
              ),
            ),
          ),

          // ── Heavy dark overlay so text is always readable ────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.82),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),

          // ── Main scrollable content ──────────────────────────────────────
          Positioned.fill(
            child: Column(
              children: [
                // Header bar
                _Header(
                  safe:    safe,
                  trek:    trek.name,
                  dayNum:  widget.dayNum,
                  dayTitle: day.title,
                  dirty:   _dirty,
                  onBack:  () => context.pop(),
                  onSave:  _save,
                ),

                // Scrollable editor body
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    padding: EdgeInsets.fromLTRB(20, 8, 20, safe.bottom + 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Writing area
                        _WritingArea(
                          controller: _textCtrl,
                          focusNode:  _focusNode,
                        ),

                        // Photos
                        if (_images.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _PhotoGrid(
                            images:    _images,
                            onRemove:  _removeImage,
                          ),
                        ],

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky formatting toolbar above keyboard ─────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _FormatToolbar(
              safe:        safe,
              onH1:        _fmtHeading1,
              onH2:        _fmtHeading2,
              onBold:      _fmtBold,
              onItalic:    _fmtItalic,
              onBullet:    _fmtBullet,
              onPhoto:     _pickImage,
              focusNode:   _focusNode,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final EdgeInsets safe;
  final String trek;
  final int dayNum;
  final String dayTitle;
  final bool dirty;
  final VoidCallback onBack;
  final VoidCallback onSave;

  const _Header({
    required this.safe,
    required this.trek,
    required this.dayNum,
    required this.dayTitle,
    required this.dirty,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(16, safe.top + 12, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GlassBackButton(onPressed: onBack),
            if (dirty)
              GestureDetector(
                onTap: onSave,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Text(
                  'Saved',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'DAY $dayNum  ·  ${trek.toUpperCase()}',
          style: AppTextStyles.eyebrow,
        ),
        const SizedBox(height: 6),
        Text(
          dayTitle,
          style: AppTextStyles.heroHeading.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.auto_stories_rounded, size: 12, color: AppColors.accentLight),
          const SizedBox(width: 5),
          Text(
            'Diary Entry',
            style: AppTextStyles.eyebrow.copyWith(
              color: AppColors.accentLight,
              letterSpacing: 2,
            ),
          ),
        ]),
      ],
    ),
  );
}

// ─── Writing area ─────────────────────────────────────────────────────────────

class _WritingArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _WritingArea({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) => TextField(
    controller:      controller,
    focusNode:       focusNode,
    maxLines:        null,
    keyboardType:    TextInputType.multiline,
    textInputAction: TextInputAction.newline,
    style: GoogleFonts.sourceCodePro(
      fontSize:   15,
      color:      Colors.white.withValues(alpha: 0.92),
      height:     1.75,
      fontWeight: FontWeight.w400,
    ),
    decoration: InputDecoration(
      hintText: '# Title\n\nStart writing your diary entry...\n\nUse the toolbar below to format text, add photos, and more.',
      hintStyle: GoogleFonts.sourceCodePro(
        fontSize:   15,
        color:      Colors.white.withValues(alpha: 0.22),
        height:     1.75,
      ),
      border:        InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      filled: false,
    ),
    cursorColor: AppColors.accentLight,
    cursorWidth: 2,
  );
}

// ─── Photo grid ───────────────────────────────────────────────────────────────

class _PhotoGrid extends StatelessWidget {
  final List<DiaryImage> images;
  final void Function(int) onRemove;

  const _PhotoGrid({required this.images, required this.onRemove});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'PHOTOS',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white.withValues(alpha: 0.35),
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(images.length, (i) => _PhotoThumb(
          image:    images[i],
          onRemove: () => onRemove(i),
        )),
      ),
    ],
  );
}

class _PhotoThumb extends StatelessWidget {
  final DiaryImage image;
  final VoidCallback onRemove;

  const _PhotoThumb({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final size = (MediaQuery.sizeOf(context).width - 56) / 2;
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: size, height: size * 0.75,
            child: image.localPath.isNotEmpty
                ? Image.file(File(image.localPath), fit: BoxFit.cover)
                : (image.url.isNotEmpty
                    ? CachedNetworkImage(imageUrl: image.url, fit: BoxFit.cover)
                    : const ColoredBox(color: AppColors.surface)),
          ),
        ),
        // Remove button
        Positioned(
          top: 6, right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Formatting toolbar ───────────────────────────────────────────────────────

class _FormatToolbar extends StatefulWidget {
  final EdgeInsets safe;
  final VoidCallback onH1;
  final VoidCallback onH2;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onBullet;
  final VoidCallback onPhoto;
  final FocusNode focusNode;

  const _FormatToolbar({
    required this.safe,
    required this.onH1,
    required this.onH2,
    required this.onBold,
    required this.onItalic,
    required this.onBullet,
    required this.onPhoto,
    required this.focusNode,
  });

  @override
  State<_FormatToolbar> createState() => _FormatToolbarState();
}

class _FormatToolbarState extends State<_FormatToolbar> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final atBottom    = bottomInset < 50;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: atBottom ? widget.safe.bottom : bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xF0141A11),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            _ToolBtn(label: 'H1',  onTap: widget.onH1,    text: true),
            _ToolBtn(label: 'H2',  onTap: widget.onH2,    text: true),
            const _Divider(),
            _ToolBtn(icon: Icons.format_bold,          onTap: widget.onBold),
            _ToolBtn(icon: Icons.format_italic,        onTap: widget.onItalic),
            _ToolBtn(icon: Icons.format_list_bulleted, onTap: widget.onBullet),
            const Spacer(),
            _ToolBtn(
              icon:  Icons.add_photo_alternate_outlined,
              onTap: widget.onPhoto,
              accent: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool text;
  final bool accent;

  const _ToolBtn({
    this.label,
    this.icon,
    required this.onTap,
    this.text  = false,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: 40, height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: accent
            ? AppColors.accent.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: text
            ? Text(
                label!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              )
            : Icon(
                icon,
                size: 20,
                color: accent
                    ? AppColors.accentLight
                    : Colors.white.withValues(alpha: 0.75),
              ),
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 22,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    color: Colors.white.withValues(alpha: 0.12),
  );
}
