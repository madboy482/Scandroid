import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  // Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  // Check if camera permission is granted
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }
  
  // Request storage permission
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
  
  // Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted;
  }
  
  // Request all required permissions
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await [
      Permission.camera,
      Permission.storage,
    ].request();
  }
}