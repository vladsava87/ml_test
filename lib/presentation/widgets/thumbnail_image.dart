import 'package:ml_test/domain/enums/e_image_type.dart';
import 'package:ml_test/domain/models/processed_file_model.dart';
import 'package:ml_test/presentation/constants/icon_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ThumbnailImageWidget extends StatelessWidget {
  final ProcessedFileModel item;

  const ThumbnailImageWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.type == EImageType.document) {
      return SvgPicture.asset(IconConstants.pdfIcon, width: 75, height: 75);
    }

    return item.thumbnailBytes != null
        ? Image.memory(
            item.thumbnailBytes!,
            width: 75,
            height: 75,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          )
        : const Icon(Icons.image);
  }
}
