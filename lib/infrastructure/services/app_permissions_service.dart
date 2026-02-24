import 'package:permission_handler/permission_handler.dart';
import 'package:ml_test/domain/interfaces/services/i_app_permissions_service.dart';

class AppPermissionsService implements IAppPermissionsService {
  @override
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }
    return false;
  }

  @override
  Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }
}
