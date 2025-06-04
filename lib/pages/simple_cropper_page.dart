import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SimpleCropperPage extends StatefulWidget {
  const SimpleCropperPage({super.key});

  @override
  State<SimpleCropperPage> createState() => _SimpleCropperPageState();
}

class _SimpleCropperPageState extends State<SimpleCropperPage> {
  Uint8List? _imageBytes;
  ui.Image? _decodedImage;

  Rect cropRect = const Rect.fromLTWH(0, 0, 200, 200);
  late Offset _initialFocalPoint;
  late Rect _initialCropRect;

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      Navigator.pop(context);
      return;
    }

    final bytes = await picked.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    setState(() {
      _imageBytes = bytes;
      _decodedImage = frame.image;
    });
  }

  Future<void> _cropImage() async {
    final image = _decodedImage!;
    final double scaleX = image.width / _previewSize.width;
    final double scaleY = image.height / _previewSize.height;

    final cropInImage = Rect.fromLTWH(
      cropRect.left * scaleX,
      cropRect.top * scaleY,
      cropRect.width * scaleX,
      cropRect.height * scaleY,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    canvas.drawImageRect(
      image,
      cropInImage,
      Rect.fromLTWH(0, 0, cropInImage.width, cropInImage.height),
      paint,
    );

    final picture = recorder.endRecording();
    final cropped = await picture.toImage(
      cropInImage.width.toInt(),
      cropInImage.height.toInt(),
    );
    final byteData = await cropped.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      Navigator.pop(context, byteData.buffer.asUint8List());
    }
  }

  Size _previewSize = const Size(300, 300);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Gambar"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _imageBytes == null || _decodedImage == null
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  final img = _decodedImage!;
                  final screenRatio =
                      constraints.maxWidth / constraints.maxHeight;
                  final imageRatio = img.width / img.height;

                  double width, height;
                  if (imageRatio > screenRatio) {
                    width = constraints.maxWidth;
                    height = width / imageRatio;
                  } else {
                    height = constraints.maxHeight;
                    width = height * imageRatio;
                  }

                  _previewSize = Size(width, height);

                  if (cropRect == Rect.zero) {
                    final side = width < height ? width : height;
                    final dx = (width - side) / 2;
                    final dy = (height - side) / 2;
                    cropRect = Rect.fromLTWH(dx, dy, side, side);
                  }

                  return Center(
                    child: Stack(
                      children: [
                        SizedBox(
                          width: width,
                          height: height,
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        GestureDetector(
                          onScaleStart: (details) {
                            _initialFocalPoint = details.focalPoint;
                            _initialCropRect = cropRect;
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              if (details.scale == 1.0) {
                                // drag
                                final delta =
                                    details.focalPoint - _initialFocalPoint;
                                final moved = _initialCropRect.shift(delta);
                                if (_isRectInside(moved, Size(width, height))) {
                                  cropRect = moved;
                                }
                              } else {
                                // zoom/resize
                                final scale = details.scale;
                                final newSize = _initialCropRect.width * scale;
                                final newRect = Rect.fromCenter(
                                  center: _initialCropRect.center,
                                  width: newSize,
                                  height: newSize,
                                );
                                if (_isRectInside(
                                  newRect,
                                  Size(width, height),
                                )) {
                                  cropRect = newRect;
                                }
                              }
                            });
                          },
                          child: SizedBox(
                            width: width,
                            height: height,
                            child: Stack(
                              children: [
                                // Overlay
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _CropOverlayPainter(cropRect),
                                  ),
                                ),
                                // Border
                                Positioned.fromRect(
                                  rect: cropRect,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cropImage,
        icon: const Icon(Icons.check),
        label: const Text("Crop"),
      ),
    );
  }

  bool _isRectInside(Rect rect, Size boundary) {
    return rect.left >= 0 &&
        rect.top >= 0 &&
        rect.right <= boundary.width &&
        rect.bottom <= boundary.height;
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  _CropOverlayPainter(this.cropRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..style = PaintingStyle.fill;

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRect(cropRect),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return cropRect != oldDelegate.cropRect;
  }
}
