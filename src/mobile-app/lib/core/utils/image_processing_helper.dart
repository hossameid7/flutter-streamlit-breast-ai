import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageProcessingHelper {
  /// Decodes and resizes an image in a background isolate.
  static Future<img.Image?> decodeAndResize(
    File imageFile,
    int width,
    int height,
  ) async {
    final imageData = await imageFile.readAsBytes();
    return await Isolate.run(() {
      img.Image? originalImage = img.decodeImage(imageData);
      if (originalImage == null) return null;
      return img.copyResize(originalImage, width: width, height: height);
    });
  }

  /// Converts an [img.Image] to a [Float32List] for TFLite model input.
  /// [normalize] determines if pixel values should be divided by 255.0.
  static Float32List imageToFloat32List(
    img.Image image, {
    bool normalize = true,
  }) {
    var input = Float32List(1 * image.height * image.width * 3);
    var buffer = Float32List.view(input.buffer);
    int pixelIndex = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        var pixel = image.getPixel(x, y);
        if (normalize) {
          buffer[pixelIndex++] = pixel.r.toDouble() / 255.0;
          buffer[pixelIndex++] = pixel.g.toDouble() / 255.0;
          buffer[pixelIndex++] = pixel.b.toDouble() / 255.0;
        } else {
          buffer[pixelIndex++] = pixel.r.toDouble();
          buffer[pixelIndex++] = pixel.g.toDouble();
          buffer[pixelIndex++] = pixel.b.toDouble();
        }
      }
    }
    return input;
  }
}
