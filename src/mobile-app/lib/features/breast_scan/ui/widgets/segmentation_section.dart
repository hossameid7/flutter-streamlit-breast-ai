import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../logic/breast_scan_cubit.dart';
import 'segmentation_overlay.dart';

class SegmentationSection extends StatelessWidget {
  final BreastScanState state;

  const SegmentationSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = state.status == BreastScanStatus.segmentationLoading;
    final bool isSuccess = state.status == BreastScanStatus.segmentationSuccess;

    return Column(
      children: [
        SizedBox(height: 20.h),
        if (!isSuccess) ...[
          ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    if (state.image != null) {
                      context.read<BreastScanCubit>().runSegmentation(
                        state.image!,
                      );
                    }
                  },
            icon: Icon(
              isLoading ? Icons.hourglass_empty : Icons.layers_outlined,
            ),
            label: Text(isLoading ? "Segmenting..." : "Run Segmentation"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.pinkColor,
              side: BorderSide(color: AppTheme.pinkColor),
              elevation: 0,
            ),
          ),
        ],
        if (isSuccess && state.mask != null && state.image != null)
          _buildSegmentationOverlay(state),
      ],
    );
  }

  Widget _buildSegmentationOverlay(BreastScanState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_outlined,
              color: AppTheme.pinkColor,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            const Text(
              "Segmentation Result",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        SegmentationOverlay(imageFile: state.image!, mask: state.mask!),
      ],
    );
  }
}
