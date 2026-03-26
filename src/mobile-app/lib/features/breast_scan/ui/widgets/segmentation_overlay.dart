import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'mask_painter.dart';

class SegmentationOverlay extends StatefulWidget {
  final File imageFile;
  final Uint8List mask;

  const SegmentationOverlay({
    super.key,
    required this.imageFile,
    required this.mask,
  });

  @override
  State<SegmentationOverlay> createState() => _SegmentationOverlayState();
}

class _SegmentationOverlayState extends State<SegmentationOverlay> {
  ui.Image? _originalImage;
  ui.Image? _maskImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prepareImages();
  }

  @override
  void didUpdateWidget(SegmentationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageFile.path != widget.imageFile.path ||
        oldWidget.mask != widget.mask) {
      _prepareImages();
    }
  }

  Future<void> _prepareImages() async {
    setState(() => _isLoading = true);
    try {
      final original = await _loadImage(widget.imageFile);
      final mask = await _createMaskImage(widget.mask);
      if (mounted) {
        setState(() {
          _originalImage = original;
          _maskImage = mask;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<ui.Image> _loadImage(File file) async {
    final data = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> _createMaskImage(Uint8List maskData) async {
    // Assume square mask for simplicity, otherwise we'd need passed dimensions
    int size = sqrt(maskData.length).toInt();
    final pixels = Uint32List(size * size);
    for (int i = 0; i < maskData.length; i++) {
      if (maskData[i] > 0) {
        // Semi-transparent red/pink (0x88FF1493 - DeepPink with 0x88 alpha)
        pixels[i] = 0x88FF1493;
      } else {
        pixels[i] = 0x00000000;
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels.buffer.asUint8List(),
      size,
      size,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_originalImage == null || _maskImage == null) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text("Error loading images")),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        size: const Size(double.infinity, 300),
        painter: MaskPainter(_originalImage!, _maskImage!),
      ),
    );
  }
}
