import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/context_extension.dart';

class ClassificationButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const ClassificationButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: Text(isLoading ? context.l10n.analysing : context.l10n.runClassification),
      ),
    );
  }
}
