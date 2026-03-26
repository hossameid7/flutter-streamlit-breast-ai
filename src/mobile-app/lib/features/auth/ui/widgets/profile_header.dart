import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final String firstName;
  final String lastName;

  const ProfileHeader({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.pinkColor.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 50.r,
            backgroundColor: AppTheme.lightPinkColor,
            child: Text(
              '${firstName[0]}${lastName[0]}'.toUpperCase(),
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.pinkColor,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          '$firstName $lastName',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
