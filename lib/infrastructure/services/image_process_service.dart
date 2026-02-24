import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:ml_test/domain/interfaces/services/i_image_process_service.dart';

class ImageProcessService implements IImageProcessService {
  @override
  Future<String?> applyFaceBw({
    required File file,
    required List<Face> faces,
    double padFactor = 0.06,
    double featherSigma = 6.0,
  }) async {
    if (faces.isEmpty) return null;

    final bytes = await file.readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return null;

    var baseImage = img.bakeOrientation(original);

    if (baseImage.width > 2000 || baseImage.height > 2000) {
      final scale = 2000 / max(baseImage.width, baseImage.height);
      baseImage = img.copyResize(
        baseImage,
        width: (baseImage.width * scale).round(),
        height: (baseImage.height * scale).round(),
      );
    }

    final out = img.Image.from(baseImage);

    for (final face in faces) {
      final contour = face.contours[FaceContourType.face];
      final points = contour?.points;
      if (points == null || points.length < 6) {
        _applyBwRectFallback(out, face.boundingBox, padFactor);
        continue;
      }

      var minX = points.first.x, maxX = points.first.x;
      var minY = points.first.y, maxY = points.first.y;
      for (final p in points) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }

      final padX = ((maxX - minX) * padFactor).round();
      final padY = ((maxY - minY) * padFactor).round();

      final left = (minX - padX).clamp(0, out.width - 1);
      final top = (minY - padY).clamp(0, out.height - 1);
      final right = (maxX + padX).clamp(left + 1, out.width);
      final bottom = (maxY + padY).clamp(top + 1, out.height);

      final cropW = right - left;
      final cropH = bottom - top;

      final crop = img.copyCrop(
        out,
        x: left,
        y: top,
        width: cropW,
        height: cropH,
      );
      final cropBw = img.grayscale(img.Image.from(crop));

      final faceH = (maxY - minY).toDouble();
      final upShift = faceH * 0.06;
      final scale = 1.08;
      double cx = 0, cy = 0;
      for (final p in points) {
        cx += p.x;
        cy += p.y;
      }
      cx /= points.length;
      cy /= points.length;

      final localPolygon = points.map((p) {
        final dx = p.x - cx;
        final dy = p.y - cy;
        final ex = cx + dx * scale;
        final ey = cy + dy * scale - upShift;
        return img.Point((ex - left).round(), (ey - top).round());
      }).toList();

      final mask = img.Image(width: cropW, height: cropH);
      img.fillPolygon(
        mask,
        vertices: localPolygon,
        color: img.ColorRgb8(255, 255, 255),
      );

      if (featherSigma > 0) {
        img.gaussianBlur(mask, radius: (featherSigma * 0.5).round());
      }
      for (var y = 0; y < cropH; y++) {
        for (var x = 0; x < cropW; x++) {
          final mColor = mask.getPixel(x, y);
          final t = mColor.r / 255.0;
          if (t == 0) continue;

          final pOrig = crop.getPixel(x, y);
          final pBw = cropBw.getPixel(x, y);

          final r = (pOrig.r + (pBw.r - pOrig.r) * t).round();
          final g = (pOrig.g + (pBw.g - pOrig.g) * t).round();
          final b = (pOrig.b + (pBw.b - pOrig.b) * t).round();

          crop.setPixelRgb(x, y, r, g, b);
        }
      }

      img.compositeImage(out, crop, dstX: left, dstY: top);
    }

    final dir = await getTemporaryDirectory();
    final resultFile = File(
      '${dir.path}/face_bw_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await resultFile.writeAsBytes(img.encodeJpg(out, quality: 92));

    return resultFile.path;
  }

  @override
  Future<File?> normalizeImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) return null;

      var normalized = img.bakeOrientation(original);

      if (normalized.width > 1600 || normalized.height > 1600) {
        final scale = 1600 / max(normalized.width, normalized.height);
        normalized = img.copyResize(
          normalized,
          width: (normalized.width * scale).round(),
          height: (normalized.height * scale).round(),
        );
      }

      final dir = await getTemporaryDirectory();
      final normalizedFile = File(
        '${dir.path}/normalized_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await normalizedFile.writeAsBytes(img.encodeJpg(normalized, quality: 90));
      return normalizedFile;
    } catch (e) {
      return null;
    }
  }

  void _applyBwRectFallback(img.Image out, dynamic rect, double padFactor) {
    final double rLeft = rect.left;
    final double rTop = rect.top;
    final double rWidth = rect.width;
    final double rHeight = rect.height;

    final padX = (rWidth * padFactor).round();
    final padY = (rHeight * padFactor).round();

    final left = (rLeft - padX).round().clamp(0, out.width - 1);
    final top = (rTop - padY).round().clamp(0, out.height - 1);
    final right = (rLeft + rWidth + padX).round().clamp(left + 1, out.width);
    final bottom = (rTop + rHeight + padY).round().clamp(top + 1, out.height);

    for (var y = top; y < bottom; y++) {
      for (var x = left; x < right; x++) {
        final p = out.getPixel(x, y);
        final gray = (0.299 * p.r + 0.587 * p.g + 0.114 * p.b).round();
        out.setPixelRgb(x, y, gray, gray, gray);
      }
    }
  }
}
