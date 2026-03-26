import 'dart:io';
import 'dart:typed_data';
import '../services/breast_detection_service.dart';
import '../services/breast_segmentation_service.dart';

class BreastScanRepo {
  final BreastDetectionService detectionService;
  final BreastSegmentationService segmentationService;

  BreastScanRepo({
    required this.detectionService,
    required this.segmentationService,
  });

  Future<Map<String, dynamic>> detectTumor(File image) async {
    return await detectionService.predict(image);
  }

  Future<Uint8List> segmentTumor(File image) async {
    return await segmentationService.predict(image);
  }

  void dispose() {
    detectionService.dispose();
    segmentationService.dispose();
  }
}
