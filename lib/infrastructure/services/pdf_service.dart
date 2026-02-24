import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:ml_test/domain/interfaces/services/i_pdf_service.dart';

class PdfService implements IPdfService {
  @override
  Future<String> createPdfFromImage(
    File imageFile, {
    String? extractedText,
  }) async {
    final bytes = await imageFile.readAsBytes();

    final doc = Document();
    final image = MemoryImage(bytes);

    doc.addPage(
      Page(
        build: (ctx) => Center(child: Image(image, fit: BoxFit.contain)),
      ),
    );

    if (extractedText != null && extractedText.trim().isNotEmpty) {
      doc.addPage(
        Page(
          build: (ctx) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text(extractedText),
          ),
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final out = File(
      '${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await out.writeAsBytes(await doc.save());
    return out.path;
  }
}
