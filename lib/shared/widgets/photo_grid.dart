import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';

class PhotoGrid extends StatelessWidget {
  final List<String> photos; // file paths
  final ValueChanged<String> onAdd;

  const PhotoGrid({super.key, required this.photos, required this.onAdd});

  Future<void> _pick() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) onAdd(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...photos.map((path) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(path), fit: BoxFit.cover),
        )),
        GestureDetector(
          onTap: _pick,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5, style: BorderStyle.solid),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppColors.textHint, size: 18),
                SizedBox(height: 4),
                Text('Add', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textHint)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
