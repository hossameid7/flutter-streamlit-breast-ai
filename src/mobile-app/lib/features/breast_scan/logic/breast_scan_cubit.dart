import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repo/breast_scan_repo.dart';

enum BreastScanStatus {
  initial,
  loading,
  detectionSuccess,
  segmentationLoading,
  segmentationSuccess,
  failure,
}

class BreastScanState extends Equatable {
  final BreastScanStatus status;
  final File? image;
  final int? predictedClass;
  final double? probability;
  final Uint8List? mask;
  final String? errorMessage;
  final List<String> classNames = const ['Benign', 'Malignant', 'Normal'];

  const BreastScanState({
    this.status = BreastScanStatus.initial,
    this.image,
    this.predictedClass,
    this.probability,
    this.mask,
    this.errorMessage,
  });

  String? get label =>
      predictedClass != null ? classNames[predictedClass!] : null;

  BreastScanState copyWith({
    BreastScanStatus? status,
    File? image,
    int? predictedClass,
    double? probability,
    Uint8List? mask,
    String? errorMessage,
  }) {
    return BreastScanState(
      status: status ?? this.status,
      image: image ?? this.image,
      predictedClass: predictedClass ?? this.predictedClass,
      probability: probability ?? this.probability,
      mask: mask ?? this.mask,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    image,
    predictedClass,
    probability,
    mask,
    errorMessage,
  ];
}

class BreastScanCubit extends Cubit<BreastScanState> {
  final BreastScanRepo repo;

  BreastScanCubit(this.repo) : super(const BreastScanState());

  Future<void> scanImage(File image) async {
    emit(state.copyWith(status: BreastScanStatus.loading, image: image));

    // Add a small delay to allow UI to show loading indicator
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final result = await repo.detectTumor(image);
      emit(
        state.copyWith(
          status: BreastScanStatus.detectionSuccess,
          predictedClass: result['index'],
          probability: result['score'],
          mask: null, // Clear any previous mask
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BreastScanStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> runSegmentation(File image) async {
    emit(state.copyWith(status: BreastScanStatus.segmentationLoading));

    // Add a small delay for UI feedback
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final mask = await repo.segmentTumor(image);
      emit(
        state.copyWith(
          status: BreastScanStatus.segmentationSuccess,
          mask: mask,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: BreastScanStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(const BreastScanState());
  }
}
