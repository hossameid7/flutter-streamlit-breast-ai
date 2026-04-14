import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/localization/context_extension.dart';

class BreastScanActionButtons extends StatelessWidget {
  final Function(ImageSource) onPickImage;

  const BreastScanActionButtons({super.key, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onPickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: Text(context.l10n.gallery),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onPickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: Text(context.l10n.camera),
          ),
        ),
      ],
    );
  }
}
