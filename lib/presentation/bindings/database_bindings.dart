import 'package:ml_test/infrastructure/data/db_provider.dart';
import 'package:ml_test/domain/interfaces/data/i_db_provider.dart';
import 'package:get/get.dart';

class DatabaseBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IDbProvider>(() => DbProvider(), fenix: true);
  }
}
