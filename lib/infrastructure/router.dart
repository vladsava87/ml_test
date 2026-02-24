import 'package:ml_test/infrastructure/business/bindings/batch_process_bindings.dart';
import 'package:ml_test/infrastructure/business/bindings/camera_bindings.dart';
import 'package:ml_test/infrastructure/business/bindings/file_process_bindings.dart';
import 'package:ml_test/infrastructure/business/bindings/history_bindings.dart';
import 'package:ml_test/infrastructure/business/bindings/image_result_bindings.dart';
import 'package:ml_test/infrastructure/business/bindings/main_bindings.dart';
import 'package:ml_test/infrastructure/business/bindings/startup_bindings.dart';
import 'package:ml_test/presentation/pages/file_processing/batch_process_page.dart';
import 'package:ml_test/presentation/pages/camera_page.dart';
import 'package:ml_test/presentation/pages/file_processing/file_process_page.dart';
import 'package:ml_test/presentation/pages/history_page.dart';
import 'package:ml_test/presentation/pages/home_page.dart';
import 'package:ml_test/presentation/pages/results/batch_summary_page.dart';
import 'package:ml_test/presentation/pages/results/document_result_page.dart';
import 'package:ml_test/presentation/pages/results/image_result_page.dart';
import 'package:ml_test/presentation/pages/startup_page.dart';
import 'package:get/get.dart';

class AppRouter {
  static const startup = '/startup';
  static const home = '/home';
  static const camera = '/camera';
  static const history = '/history';
  static const fileProcess = '/file_process';
  static const batchProcess = '/batch_process';
  static const batchSummary = '/batch_summary';
  static const documentResult = '/document_result';
  static const imageResult = '/image_result';

  static const initial = startup;
  static final routes = [
    GetPage(
      name: startup,
      page: () => const StartupPage(),
      binding: StatupBindings(),
    ),
    GetPage(name: home, page: () => const HomePage(), binding: MainBindings()),
    GetPage(name: camera, page: () => CameraPage(), binding: CameraBindings()),
    GetPage(
      name: fileProcess,
      page: () => const FileProcessPage(),
      binding: FileProcessBindings(),
    ),
    GetPage(
      name: batchProcess,
      page: () => const BatchProcessPage(),
      binding: BatchProcessBindings(),
    ),
    GetPage(name: batchSummary, page: () => const BatchSummaryPage()),
    GetPage(name: documentResult, page: () => const DocumentResultPage()),
    GetPage(
      name: imageResult,
      page: () => const ImageResultPage(),
      binding: ImageResultBindings(),
    ),
    GetPage(
      name: history,
      page: () => const HistoryPage(),
      binding: HistoryBindings(),
    ),
  ];
}
