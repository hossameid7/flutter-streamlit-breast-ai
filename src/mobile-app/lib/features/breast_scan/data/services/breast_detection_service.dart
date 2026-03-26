import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import '../../../../core/utils/image_processing_helper.dart';

class BreastDetectionService {
  Interpreter? _interpreter;

  Future<void> init() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/breast_classification_model.tflite',
    );
  }

  Future<Map<String, dynamic>> predict(File imageFile) async {
    if (_interpreter == null) await init();

    var inputTensors = _interpreter!.getInputTensors();
    var inputShape = inputTensors[0].shape;
    int modelHeight = inputShape[1];
    int modelWidth = inputShape[2];

    final resizedImage = await ImageProcessingHelper.decodeAndResize(
      imageFile,
      modelWidth,
      modelHeight,
    );

    if (resizedImage == null) throw Exception("Could not decode image");

    // This model seems to expect raw values [0-255] based on previous implementation
    final input = ImageProcessingHelper.imageToFloat32List(
      resizedImage,
      normalize: false,
    );

    var outputTensors = _interpreter!.getOutputTensors();
    var outputShape = outputTensors[0].shape;

    var output = Float32List(
      outputShape.reduce((a, b) => a * b),
    ).reshape(outputShape);

    _interpreter!.run(input.reshape(inputShape), output);

    List<double> scores = List<double>.from(output[0]);
    int maxIndex = 0;
    double maxScore = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }

    return {'index': maxIndex, 'score': maxScore, 'scores': scores};
  }

  void dispose() {
    _interpreter?.close();
  }
}
