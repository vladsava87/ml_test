import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as imgage;

class ImageHelpers {
  static Future<Uint8List?> extractThumbnail(File originalFile) async {
    final originalBytes = await originalFile.readAsBytes();
    final decodedImage = imgage.decodeImage(originalBytes);
    if (decodedImage == null) {
      return null;
    }

    final resizedImage = imgage.copyResize(decodedImage, width: 150);
    var thumbnailBytes = Uint8List.fromList(
      imgage.encodeJpg(resizedImage, quality: 75),
    );

    return thumbnailBytes;
  }
}
