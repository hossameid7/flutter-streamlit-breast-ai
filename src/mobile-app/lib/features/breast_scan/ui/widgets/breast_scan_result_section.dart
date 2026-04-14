import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../logic/breast_scan_cubit.dart';
import 'classification_button.dart';
import 'detection_result_card.dart';
import 'segmentation_section.dart';
import '../../../../core/localization/context_extension.dart';

class BreastScanResultSection extends StatelessWidget {
  final File? image;

  const BreastScanResultSection({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreastScanCubit, BreastScanState>(
      builder: (context, state) {
        if (image != null && state.status == BreastScanStatus.initial) {
          return ClassificationButton(
            isLoading: false,
            onPressed: () => context.read<BreastScanCubit>().scanImage(image!),
          );
        }

        if (state.status == BreastScanStatus.loading) {
          return ClassificationButton(isLoading: true, onPressed: null);
        } else if (state.status == BreastScanStatus.failure) {
          return Column(
            children: [
              Text(
                context.l10n.statusError(state.errorMessage ?? ""),
                style: const TextStyle(color: Colors.red),
              ),
              SizedBox(height: 10.h),
              ClassificationButton(
                isLoading: false,
                onPressed: () =>
                    context.read<BreastScanCubit>().scanImage(image!),
              ),
            ],
          );
        } else if (state.status == BreastScanStatus.detectionSuccess ||
            state.status == BreastScanStatus.segmentationLoading ||
            state.status == BreastScanStatus.segmentationSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DetectionResultCard(state: state),
              if (state.predictedClass != 2) // Benign or Malignant
                SegmentationSection(state: state),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
