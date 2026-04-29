import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiffBadge extends StatelessWidget {
  final String difficulty;
  const DiffBadge({super.key, required this.difficulty});

  static const _map = {
    'Easy':        (Color(0xFF4A9B6E), Color(0x1A4A9B6E)),
    'Moderate':    (Color(0xFFC17F3E), Color(0x1AC17F3E)),
    'Challenging': (Color(0xFFC4524A), Color(0x1AC4524A)),
    'Expert':      (Color(0xFF8B4FB8), Color(0x1A8B4FB8)),
  };

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _map[difficulty] ?? _map['Moderate']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(difficulty, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
