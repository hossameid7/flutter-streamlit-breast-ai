import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../logic/breast_scan_cubit.dart';

class DetectionResultCard extends StatelessWidget {
  final BreastScanState state;

  const DetectionResultCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color cardColor = state.predictedClass == 2
        ? Colors.green[50]!
        : (state.predictedClass == 1 ? Colors.red[50]! : Colors.orange[50]!);
    Color textColor = state.predictedClass == 2
        ? Colors.green[800]!
        : (state.predictedClass == 1 ? Colors.red[800]! : Colors.orange[800]!);
    IconData icon = state.predictedClass == 2
        ? Icons.check_circle_outline
        : Icons.warning_amber_outlined;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 28.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Classification",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  state.label ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Confidence: ${((state.probability ?? 0) * 100).toStringAsFixed(2)}%",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
