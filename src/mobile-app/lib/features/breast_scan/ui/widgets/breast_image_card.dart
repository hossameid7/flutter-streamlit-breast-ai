import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/context_extension.dart';

class BreastImageCard extends StatelessWidget {
  final File? image;

  const BreastImageCard({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.pinkColor.withValues(alpha: 0.2)),
        image: image != null
            ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover)
            : null,
      ),
      child: image == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 60.sp,
                  color: AppTheme.pinkColor,
                ),
                SizedBox(height: 10.h),
                Text(
                  context.l10n.uploadImagePrompt,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
                ),
              ],
            )
          : null,
    );
  }
}
