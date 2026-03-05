import 'package:ml_test/presentation/controllers/file_processing/batch_process_controller.dart';
import 'package:ml_test/infrastructure/data/db_provider.dart';
import 'package:ml_test/infrastructure/data/providers/processed_file_table_provider.dart';
import 'package:ml_test/infrastructure/data/repositories/processed_file_repository.dart';
import 'package:ml_test/domain/interfaces/data/i_db_provider.dart';
import 'package:ml_test/domain/interfaces/data/i_processed_file_table_provider.dart';
import 'package:ml_test/domain/interfaces/data/i_processed_file_repository.dart';
import 'package:get/get.dart';

class BatchProcessBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IDbProvider>(() => DbProvider(), fenix: true);
    Get.lazyPut<IProcessedFileTableProvider>(
      () => ProcessedFileTableProvider(Get.find<IDbProvider>()),
      fenix: true,
    );
    Get.lazyPut<IProcessedFileRepository>(
      () => ProcessedFileRepository(Get.find<IProcessedFileTableProvider>()),
      fenix: true,
    );

    Get.put(BatchProcessController(Get.find<IProcessedFileRepository>()));
  }
}
