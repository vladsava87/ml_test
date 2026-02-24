import 'package:permission_handler/permission_handler.dart';

abstract class IAppPermissionsService {
  Future<bool> requestCameraPermission();
  Future<PermissionStatus> checkCameraPermission();
}
