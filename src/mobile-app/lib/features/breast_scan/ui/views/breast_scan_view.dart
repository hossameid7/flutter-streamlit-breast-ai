import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/routes.dart';
import '../../logic/breast_scan_cubit.dart';
import '../widgets/breast_image_card.dart';
import '../widgets/breast_scan_action_buttons.dart';
import '../widgets/breast_scan_result_section.dart';

class BreastScanView extends StatefulWidget {
  const BreastScanView({super.key});

  @override
  State<BreastScanView> createState() => _BreastScanViewState();
}

class _BreastScanViewState extends State<BreastScanView> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selected = await _picker.pickImage(source: source);
    if (selected != null) {
      if (!mounted) return;
      context.read<BreastScanCubit>().reset();
      setState(() {
        _image = File(selected.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Breast Detection & Segmentation"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, Routes.profile),
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BreastImageCard(image: _image),
              SizedBox(height: 20.h),
              BreastScanActionButtons(onPickImage: _pickImage),
              SizedBox(height: 20.h),
              BreastScanResultSection(image: _image),
            ],
          ),
        ),
      ),
    );
  }
}
