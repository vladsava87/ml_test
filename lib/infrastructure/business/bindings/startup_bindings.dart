import 'package:ml_test/infrastructure/business/bindings/database_bindings.dart';
import 'package:ml_test/infrastructure/services/batch_process_service.dart';
import 'package:ml_test/infrastructure/services/image_ml_service.dart';
import 'package:ml_test/infrastructure/services/image_process_service.dart';
import 'package:ml_test/infrastructure/services/process_documents_service.dart';
import 'package:ml_test/infrastructure/services/text_ml_service.dart';
import 'package:ml_test/infrastructure/services/pdf_service.dart';
import 'package:ml_test/infrastructure/services/app_permissions_service.dart';
import 'package:ml_test/domain/interfaces/services/i_batch_process_service.dart';
import 'package:ml_test/domain/interfaces/services/i_image_ml_service.dart';
import 'package:ml_test/domain/interfaces/services/i_image_process_service.dart';
import 'package:ml_test/domain/interfaces/services/i_process_documents_service.dart';
import 'package:ml_test/domain/interfaces/services/i_text_ml_service.dart';
import 'package:ml_test/domain/interfaces/services/i_pdf_service.dart';
import 'package:ml_test/domain/interfaces/services/i_app_permissions_service.dart';
import 'package:get/get.dart';

class StatupBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ITextMlService>(() => TextMlService(), fenix: true);
    Get.lazyPut<IImageMlService>(() => ImageMlService(), fenix: true);
    Get.lazyPut<IImageProcessService>(() => ImageProcessService(), fenix: true);
    Get.lazyPut<IProcessDocumentsService>(
      () => ProcessDocumentsService(),
      fenix: true,
    );
    Get.lazyPut<IBatchProcessService>(() => BatchProcessService(), fenix: true);
    Get.lazyPut<IPdfService>(() => PdfService(), fenix: true);
    Get.lazyPut<IAppPermissionsService>(
      () => AppPermissionsService(),
      fenix: true,
    );
    DatabaseBindings().dependencies();
  }
}
