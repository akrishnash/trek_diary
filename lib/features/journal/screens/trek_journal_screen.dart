import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/day.dart';
import '../../../data/models/diary_entry.dart';
import '../../../data/models/trek.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/glass.dart';

const _kDefaultPhoto =
    'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&q=80';

class TrekJournalScreen extends ConsumerWidget {
  final String trekId;
  const TrekJournalScreen({super.key, required this.trekId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treks = ref.watch(trekListProvider);
    final trek  = treks.where((t) => t.id == trekId).firstOrNull;
    if (trek == null) return const SizedBox.shrink();
    final safe  = MediaQuery.paddingOf(context);

    final bgPhoto = trek.coverImageUrl?.isNotEmpty == true
        ? trek.coverImageUrl!
        : getTrekPhotoUrl(trek);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1208),
      body: Stack(
        children: [
          // ── Background photo ───────────────────────────────────────────────
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

          // ── Gradient overlay ───────────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.50),
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.93),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────────
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                // Top bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, safe.top + 12, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GlassBackButton(onPressed: () => context.pop()),
                        _ExportButton(trek: trek),
                      ],
                    ),
                  ),
                ),

                // Trek hero
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TREK JOURNAL', style: AppTextStyles.eyebrow),
                        const SizedBox(height: 8),
                        Text(
                          trek.name,
                          style: AppTextStyles.heroHeading.copyWith(
                            fontSize: 30, fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${trek.region}  ·  ${trek.totalDays} days  ·  ${trek.difficulty}',
                          style: AppTextStyles.heroSubtitle,
                        ),
                        const SizedBox(height: 14),
                        _JournalStats(trek: trek),
                      ],
                    ),
                  ),
                ),

                // Days
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: EdgeInsets.fromLTRB(
                          16, 0, 16, i == trek.days.length - 1 ? 0 : 10),
                      child: _DayEntry(day: trek.days[i]),
                    ),
                    childCount: trek.days.length,
                  ),
                ),

                SliverToBoxAdapter(
                    child: SizedBox(height: safe.bottom + 48)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats chips ───────────────────────────────────────────────────────────────

class _JournalStats extends StatelessWidget {
  final Trek trek;
  const _JournalStats({required this.trek});

  @override
  Widget build(BuildContext context) {
    final entriesWritten =
        trek.days.where((d) => d.diary != null && !d.diary!.isEmpty).length;
    final photoCount = trek.days.fold(0, (sum, d) {
      if (d.diary == null) return sum;
      return sum + d.diary!.images.length + d.diary!.routeImages.length;
    });

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _Chip(icon: Icons.auto_stories_rounded,
            label: '$entriesWritten / ${trek.totalDays} entries'),
        _Chip(icon: Icons.photo_library_outlined,
            label: '$photoCount photo${photoCount == 1 ? '' : 's'}'),
        _Chip(icon: Icons.place_outlined,
            label: '${trek.stopsCount} stops total'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.accentLight),
      const SizedBox(width: 5),
      Text(label, style: AppTextStyles.label.copyWith(
        color: Colors.white.withValues(alpha: 0.75), fontSize: 11,
      )),
    ]),
  );
}

// ── Single day entry ──────────────────────────────────────────────────────────

class _DayEntry extends StatelessWidget {
  final TrekDay day;
  const _DayEntry({required this.day});

  @override
  Widget build(BuildContext context) {
    final hasDiary = day.diary != null && !day.diary!.isEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xE8141A11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasDiary
              ? AppColors.accent.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Text(
                  day.dayNum.toString().padLeft(2, '0'),
                  style: GoogleFonts.poppins(
                    fontSize: 38, fontWeight: FontWeight.w100,
                    color: hasDiary ? AppColors.accent : AppColors.textHint,
                    height: 1.0, letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day.title, style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700, fontSize: 15,
                      )),
                      const SizedBox(height: 3),
                      Text(
                        day.stops.isNotEmpty
                            ? '${day.stops.length} stop${day.stops.length == 1 ? '' : 's'}  ·  ${_maxElev(day)}'
                            : 'No stops logged',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (hasDiary)
                  _EntryBadge(entry: day.diary!),
              ],
            ),
          ),

          if (hasDiary) ...[
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (day.diary!.text.isNotEmpty)
                    _MarkdownView(text: day.diary!.text),

                  if (day.diary!.images.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _PhotoSection(
                      label: 'PHOTOS',
                      icon: Icons.photo_library_outlined,
                      images: day.diary!.images,
                    ),
                  ],

                  if (day.diary!.routeImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _PhotoSection(
                      label: 'PATH MAP',
                      icon: Icons.route_rounded,
                      images: day.diary!.routeImages,
                      accent: true,
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Text(
                'No entry written for this day.',
                style: AppTextStyles.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _maxElev(TrekDay day) {
    if (day.stops.isEmpty) return '';
    final max =
        day.stops.map((s) => s.elevation).reduce((a, b) => a > b ? a : b);
    return 'Max ${max}m';
  }
}

class _EntryBadge extends StatelessWidget {
  final DiaryEntry entry;
  const _EntryBadge({required this.entry});

  @override
  Widget build(BuildContext context) {
    final photos = entry.images.length + entry.routeImages.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Entry', style: AppTextStyles.label.copyWith(
            color: AppColors.accentLight, fontSize: 10,
            fontWeight: FontWeight.w700,
          )),
          if (photos > 0)
            Text('$photos 📷', style: AppTextStyles.label.copyWith(
              color: AppColors.accentLight, fontSize: 9,
            )),
        ],
      ),
    );
  }
}

// ── Markdown renderer ─────────────────────────────────────────────────────────

class _MarkdownView extends StatelessWidget {
  final String text;
  const _MarkdownView({required this.text});

  static final _h1 = GoogleFonts.poppins(
    fontSize: 19, fontWeight: FontWeight.w600,
    color: Colors.white, height: 1.3,
  );
  static final _h2 = GoogleFonts.poppins(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: Colors.white.withValues(alpha: 0.9), height: 1.4,
  );
  static final _body = GoogleFonts.lora(
    fontSize: 13.5, color: Colors.white.withValues(alpha: 0.80),
    height: 1.75, fontWeight: FontWeight.w400,
  );

  static final _inlinePattern = RegExp(r'\*\*(.+?)\*\*|_(.+?)_');

  static List<TextSpan> _parseInline(String text, TextStyle base) {
    final spans = <TextSpan>[];
    int lastEnd = 0;
    for (final match in _inlinePattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start), style: base));
      }
      if (match.group(1) != null) {
        spans.add(TextSpan(
          text: match.group(1),
          style: base.copyWith(fontWeight: FontWeight.bold),
        ));
      } else {
        spans.add(TextSpan(
          text: match.group(2),
          style: base.copyWith(fontStyle: FontStyle.italic),
        ));
      }
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: base));
    }
    return spans.isEmpty ? [TextSpan(text: text, style: base)] : spans;
  }

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map(_buildLine).toList(),
    );
  }

  Widget _buildLine(String line) {
    if (line.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 5),
        child: RichText(text: TextSpan(children: _parseInline(line.substring(2), _h1))),
      );
    }
    if (line.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: RichText(text: TextSpan(children: _parseInline(line.substring(3), _h2))),
      );
    }
    if (line.startsWith('• ') || line.startsWith('- ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, left: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Container(
              width: 4, height: 4,
              decoration: const BoxDecoration(
                  color: AppColors.accent, shape: BoxShape.circle),
            ),
          ),
          Expanded(child: RichText(text: TextSpan(children: _parseInline(line.substring(2), _body)))),
        ]),
      );
    }
    if (line.isEmpty) return const SizedBox(height: 7);
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: RichText(text: TextSpan(children: _parseInline(line, _body))),
    );
  }
}

// ── Photo section ─────────────────────────────────────────────────────────────

class _PhotoSection extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<DiaryImage> images;
  final bool accent;

  const _PhotoSection({
    required this.label,
    required this.icon,
    required this.images,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppColors.accentLight : Colors.white.withValues(alpha: 0.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.poppins(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: color, letterSpacing: 1.5,
          )),
        ]),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: List.generate(images.length, (i) {
            final img = images[i];
            final w = (MediaQuery.sizeOf(context).width - 72) / 2;
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: w, height: w * 0.7,
                child: _imageWidget(img),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _imageWidget(DiaryImage img) {
    if (img.localPath.isNotEmpty) {
      if (kIsWeb) {
        return Image.network(img.localPath, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder);
      }
      return Image.file(File(img.localPath), fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder);
    }
    if (img.url.isNotEmpty) {
      return CachedNetworkImage(imageUrl: img.url, fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _placeholder);
    }
    return _placeholder;
  }

  static final _placeholder = Container(
    color: AppColors.surface,
    child: const Center(
      child: Icon(Icons.image_outlined, color: AppColors.textHint, size: 24),
    ),
  );
}

// ── Export button ─────────────────────────────────────────────────────────────

class _ExportButton extends StatefulWidget {
  final Trek trek;
  const _ExportButton({required this.trek});

  @override
  State<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<_ExportButton> {
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final bytes = await _buildPdf(widget.trek);
      final filename =
          '${widget.trek.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_journal.pdf';
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Export failed: $e'),
        backgroundColor: const Color(0xFFC4524A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List> _buildPdf(Trek trek) async {
    final doc = pw.Document();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 52, vertical: 48),
      build: (ctx) {
        final widgets = <pw.Widget>[
          // ── Cover ──
          pw.SizedBox(height: 48),
          pw.Text('TREK JOURNAL',
              style: const pw.TextStyle(
                  fontSize: 9,
                  letterSpacing: 4,
                  color: PdfColors.grey500)),
          pw.SizedBox(height: 10),
          pw.Text(trek.name,
              style: pw.TextStyle(
                  fontSize: 28, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(
            '${trek.region}  ·  ${trek.totalDays} days  ·  ${trek.difficulty}',
            style: const pw.TextStyle(
                fontSize: 12, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 20),
          if (trek.description.isNotEmpty) ...[
            pw.Text(trek.description,
                style: const pw.TextStyle(
                    fontSize: 12, color: PdfColors.grey700)),
            pw.SizedBox(height: 20),
          ],
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 32),
        ];

        // ── Days ──
        for (final day in trek.days) {
          final diary = day.diary;
          final hasDiary = diary != null && !diary.isEmpty;

          widgets.addAll([
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  day.dayNum.toString().padLeft(2, '0'),
                  style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: hasDiary ? PdfColors.teal700 : PdfColors.grey400),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(day.title,
                          style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold)),
                      if (day.stops.isNotEmpty)
                        pw.Text(
                          '${day.stops.length} stops',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey500),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
          ]);

          if (hasDiary && diary.text.isNotEmpty) {
            for (final line in diary.text.split('\n')) {
              if (line.isEmpty) {
                widgets.add(pw.SizedBox(height: 5));
              } else if (line.startsWith('# ')) {
                widgets.addAll([
                  pw.SizedBox(height: 10),
                  pw.Text(_stripMd(line.substring(2)),
                      style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                ]);
              } else if (line.startsWith('## ')) {
                widgets.addAll([
                  pw.SizedBox(height: 8),
                  pw.Text(_stripMd(line.substring(3)),
                      style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 3),
                ]);
              } else if (line.startsWith('• ') || line.startsWith('- ')) {
                widgets.add(pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12, top: 2),
                  child: pw.Text('• ${_stripMd(line.substring(2))}',
                      style: const pw.TextStyle(fontSize: 11)),
                ));
              } else {
                widgets.add(pw.Text(_stripMd(line),
                    style: const pw.TextStyle(
                        fontSize: 11, lineSpacing: 3)));
              }
            }
          } else if (!hasDiary) {
            widgets.add(pw.Text('No entry for this day.',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey400)));
          }

          // Photo count note
          if (hasDiary) {
            final photos =
                diary.images.length + diary.routeImages.length;
            if (photos > 0) {
              widgets.addAll([
                pw.SizedBox(height: 6),
                pw.Text(
                  '[ $photos photo${photos == 1 ? '' : 's'} attached ]',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey500),
                ),
              ]);
            }
          }

          widgets.addAll([
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.grey200),
            pw.SizedBox(height: 20),
          ]);
        }

        return widgets;
      },
    ));

    return doc.save();
  }

  static String _stripMd(String s) => s
      .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m[1]!)
      .replaceAllMapped(RegExp(r'_(.+?)_'), (m) => m[1]!);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _busy ? null : _export,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _busy
            ? Colors.white.withValues(alpha: 0.06)
            : AppColors.accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _busy
              ? Colors.white.withValues(alpha: 0.12)
              : AppColors.accent.withValues(alpha: 0.45),
          width: 0.8,
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (_busy)
          const SizedBox(
            width: 13, height: 13,
            child: CircularProgressIndicator(
                strokeWidth: 1.5, color: Colors.white),
          )
        else
          const Icon(Icons.picture_as_pdf_rounded,
              color: Colors.white, size: 15),
        const SizedBox(width: 6),
        Text(
          _busy ? 'Building PDF...' : 'Export PDF',
          style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ]),
    ),
  );
}
