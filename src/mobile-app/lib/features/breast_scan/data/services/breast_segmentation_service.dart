import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import '../../../../core/utils/image_processing_helper.dart';

class BreastSegmentationService {
  Interpreter? _interpreter;

  Future<void> init() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/breast_segmentation_model.tflite',
    );
  }

  Future<Uint8List> predict(File imageFile) async {
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

    final input = ImageProcessingHelper.imageToFloat32List(
      resizedImage,
      normalize: true,
    );

    var outputTensors = _interpreter!.getOutputTensors();
    var outputShape = outputTensors[0].shape;

    if (outputShape.length < 3) {
      throw Exception(
        "Model Error: The model loaded for segmentation (output $outputShape) "
        "is actually a classification model. Segmentation requires a model "
        "that outputs a pixel-wise mask (e.g., [1, $modelHeight, $modelWidth, 1]).\n\n"
        "Please ensure 'assets/models/breast_segmentation_model.tflite' is a valid segmentation model.",
      );
    }

    int outputSize = outputShape.reduce((a, b) => a * b);
    var output = Float32List(outputSize).reshape(outputShape);

    _interpreter!.run(input.reshape(inputShape), output);

    int outH = outputShape[1];
    int outW = outputShape[2];
    Uint8List maskBytes = Uint8List(outH * outW);

    int index = 0;
    for (int y = 0; y < outH; y++) {
      for (int x = 0; x < outW; x++) {
        double prob = outputShape.length == 4
            ? output[0][y][x][0]
            : output[0][y][x];
        maskBytes[index++] = prob > 0.5 ? 255 : 0;
      }
    }

    return maskBytes;
  }

  void dispose() {
    _interpreter?.close();
  }
}
