import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class ChipPicker extends StatelessWidget {
  final String? label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const ChipPicker({super.key, this.label, required this.options, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textHint, letterSpacing: 0.8)),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 6, runSpacing: 6,
          children: options.map((o) {
            final selected = o == value;
            return GestureDetector(
              onTap: () => onChanged(o),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent.withValues(alpha: 0.12) : AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(o, style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: selected ? AppColors.accent : AppColors.textMuted,
                )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
