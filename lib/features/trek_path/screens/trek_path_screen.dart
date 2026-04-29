import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/day.dart';
import '../../../data/repositories/trek_repository.dart';
import '../../../shared/widgets/glass.dart';

class TrekPathScreen extends ConsumerWidget {
  final String trekId;
  const TrekPathScreen({super.key, required this.trekId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treks = ref.watch(trekListProvider);
    final trek  = treks.firstWhere((t) => t.id == trekId);
    final safe  = MediaQuery.of(context).padding;

    // First day with no stops = current, all before = logged, all after = locked
    final firstEmpty = trek.days.indexWhere((d) => d.stops.isEmpty);

    _NodeState stateFor(int index) {
      if (trek.days[index].stops.isNotEmpty)   return _NodeState.logged;
      if (index == firstEmpty || firstEmpty < 0) return _NodeState.current;
      return _NodeState.locked;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A120A),
      body: Stack(
        children: [
          // ── Full-bleed photo with heavy dark overlay ───────────────────────
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: getTrekPhotoUrl(trek),
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(color: Color(0xFF0A120A)),
              errorWidget:  (_, __, ___) => const ColoredBox(color: Color(0xFF0A120A)),
            ),
          ),
          Positioned.fill(
            child: ColoredBox(color: const Color(0xCC0A120A)),
          ),

          // ── Back ───────────────────────────────────────────────────────────
          Positioned(
            top: safe.top + 12, left: 16,
            child: GlassBackButton(onPressed: () => context.pop()),
          ),

          // ── Trek name centered top ─────────────────────────────────────────
          Positioned(
            top: safe.top + 14,
            left: 60, right: 60,
            child: Text(
              trek.name,
              textAlign: TextAlign.center,
              style: AppTextStyles.heroSubtitle.copyWith(
                fontWeight: FontWeight.w500, fontSize: 14,
              ),
            ),
          ),

          // ── Progress eyebrow ───────────────────────────────────────────────
          Positioned(
            top: safe.top + 36,
            left: 0, right: 0,
            child: Text(
              '${trek.daysLogged} / ${trek.totalDays} days logged'.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTextStyles.eyebrow.copyWith(letterSpacing: 3),
            ),
          ),

          // ── Zigzag path ────────────────────────────────────────────────────
          Positioned(
            top: safe.top + 72,
            left: 0, right: 0, bottom: safe.bottom + 16,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: _ZigzagPath(
                days: trek.days,
                stateFor: stateFor,
                onTap: (day) => context.push('/trek/${trek.id}/add-stop/${day.dayNum}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

enum _NodeState { logged, current, locked }

class _ZigzagPath extends StatelessWidget {
  final List<TrekDay> days;
  final _NodeState Function(int) stateFor;
  final ValueChanged<TrekDay> onTap;

  const _ZigzagPath({required this.days, required this.stateFor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const nodeSize   = 72.0;
    const sideInset  = 56.0; // how far from the edge each column sits

    return LayoutBuilder(builder: (context, constraints) {
      final w      = constraints.maxWidth;
      final leftX  = sideInset;
      final rightX = w - sideInset - nodeSize;

      return SizedBox(
        width: w,
        child: Stack(
          children: [
            // ── Connector lines ──────────────────────────────────────────────
            CustomPaint(
              size: Size(w, _totalHeight(days.length, nodeSize)),
              painter: _PathPainter(
                nodeCount: days.length,
                nodeSize: nodeSize,
                leftX: leftX,
                rightX: rightX,
                states: List.generate(days.length, stateFor),
              ),
            ),

            // ── Node circles ─────────────────────────────────────────────────
            SizedBox(
              height: _totalHeight(days.length, nodeSize),
              child: Column(
                children: days.asMap().entries.map((e) {
                  final i     = e.key;
                  final day   = e.value;
                  final state = stateFor(i);
                  final isLeft = i.isEven;

                  return SizedBox(
                    height: nodeSize + 60, // node height + connector gap
                    child: Align(
                      alignment: isLeft
                        ? Alignment(-1 + (2 * leftX / w) + nodeSize / w, 0)
                        : Alignment(1 - (2 * (w - rightX - nodeSize) / w) - nodeSize / w, 0),
                      child: GestureDetector(
                        onTap: () => onTap(day),
                        child: _NodeCircle(day: day, state: state, size: nodeSize),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  static double _totalHeight(int count, double nodeSize) =>
      count * (nodeSize + 60) + 40;
}

// ─────────────────────────────────────────────────────────────────────────────

class _PathPainter extends CustomPainter {
  final int nodeCount;
  final double nodeSize;
  final double leftX;
  final double rightX;
  final List<_NodeState> states;

  const _PathPainter({
    required this.nodeCount,
    required this.nodeSize,
    required this.leftX,
    required this.rightX,
    required this.states,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const step = 132.0; // nodeSize + 60

    for (int i = 0; i < nodeCount - 1; i++) {
      final fromLeft = i.isEven;
      final fx = fromLeft ? leftX + nodeSize / 2 : rightX + nodeSize / 2;
      final tx = fromLeft ? rightX + nodeSize / 2 : leftX + nodeSize / 2;
      final fy = i * step + nodeSize;
      final ty = (i + 1) * step;

      final logged = states[i] == _NodeState.logged;

      final paint = Paint()
        ..color = logged
          ? AppColors.accent.withValues(alpha: 0.55)
          : Colors.white.withValues(alpha: 0.12)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      if (logged) {
        // Solid curved path for completed segments
        final path = Path()
          ..moveTo(fx, fy)
          ..cubicTo(fx, fy + (ty - fy) * 0.4, tx, ty - (ty - fy) * 0.4, tx, ty);
        canvas.drawPath(path, paint);
      } else {
        // Dashed line for locked segments
        _drawDashed(canvas, Offset(fx, fy), Offset(tx, ty), paint);
      }
    }
  }

  void _drawDashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    final d       = (to - from).distance;
    final dash    = 6.0;
    final gap     = 5.0;
    final dir     = (to - from) / d;
    double dist   = 0;
    bool   drawing = true;

    while (dist < d) {
      final seg = drawing ? dash : gap;
      final end = math.min(dist + seg, d);
      if (drawing) canvas.drawLine(from + dir * dist, from + dir * end, paint);
      dist    = end;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) =>
      old.nodeCount != nodeCount || old.states != states;
}

// ─────────────────────────────────────────────────────────────────────────────

class _NodeCircle extends StatelessWidget {
  final TrekDay day;
  final _NodeState state;
  final double size;

  const _NodeCircle({required this.day, required this.state, required this.size});

  @override
  Widget build(BuildContext context) {
    final Color bg, borderColor, textColor;
    final double borderWidth;

    switch (state) {
      case _NodeState.logged:
        bg          = AppColors.accent;
        borderColor = AppColors.accentLight.withValues(alpha: 0.5);
        textColor   = Colors.white;
        borderWidth = 2;
      case _NodeState.current:
        bg          = AppColors.nodeCurrent;
        borderColor = const Color(0xFFF0D080);
        textColor   = Colors.white;
        borderWidth = 2.5;
      case _NodeState.locked:
        bg          = Colors.white.withValues(alpha: 0.08);
        borderColor = Colors.white.withValues(alpha: 0.18);
        textColor   = Colors.white.withValues(alpha: 0.35);
        borderWidth = 1.5;
    }

    final stopCount = day.stops.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing ring for current node
        if (state == _NodeState.current)
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size + 14, height: size + 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF0D080).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
              _NodeBody(
                size: size, bg: bg, borderColor: borderColor,
                borderWidth: borderWidth, textColor: textColor, day: day,
              ),
            ],
          )
        else
          _NodeBody(
            size: size, bg: bg, borderColor: borderColor,
            borderWidth: borderWidth, textColor: textColor, day: day,
          ),

        const SizedBox(height: 7),

        // Day title below node
        SizedBox(
          width: size + 40,
          child: Text(
            day.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10, fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: state == _NodeState.locked ? 0.25 : 0.65),
              letterSpacing: 0.1,
            ),
          ),
        ),
        if (stopCount > 0) ...[
          const SizedBox(height: 2),
          Text(
            '$stopCount stop${stopCount == 1 ? '' : 's'}',
            style: GoogleFonts.poppins(
              fontSize: 9, fontWeight: FontWeight.w600,
              color: AppColors.accentLight.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}

class _NodeBody extends StatelessWidget {
  final double size;
  final Color bg, borderColor, textColor;
  final double borderWidth;
  final TrekDay day;

  const _NodeBody({
    required this.size, required this.bg, required this.borderColor,
    required this.borderWidth, required this.textColor, required this.day,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: bg,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [BoxShadow(
        color: bg.withValues(alpha: 0.4),
        blurRadius: 14, spreadRadius: 2,
      )],
    ),
    child: Center(
      child: Text(
        day.dayNum.toString().padLeft(2, '0'),
        style: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.w200,
          color: textColor, height: 1, letterSpacing: -0.5,
        ),
      ),
    ),
  );
}
