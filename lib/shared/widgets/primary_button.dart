import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool danger;
  final bool small;

  const PrimaryButton({super.key, required this.label, this.onPressed, this.danger = false, this.small = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: small ? null : double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: danger ? const Color(0x14C4524A) : (onPressed == null ? AppColors.surface : AppColors.accent),
          foregroundColor: danger ? const Color(0xFFC4524A) : (onPressed == null ? AppColors.textMuted : Colors.white),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: small ? const EdgeInsets.symmetric(horizontal: 18, vertical: 8) : const EdgeInsets.symmetric(vertical: 14),
          side: danger ? const BorderSide(color: Color(0x33C4524A), width: 1.5) : BorderSide.none,
        ),
        child: Text(label, style: GoogleFonts.poppins(fontSize: small ? 13 : 15, fontWeight: FontWeight.w800, letterSpacing: 0.1)),
      ),
    );
  }
}
