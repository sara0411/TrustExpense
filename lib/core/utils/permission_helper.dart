import 'package:permission_handler/permission_handler.dart';

/// Utility class for handling app permissions
class PermissionHelper {
  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request photo library permission
  static Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Check if photo library permission is granted
  static Future<bool> isPhotosPermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  /// Check if permission is permanently denied
  static Future<bool> isCameraPermissionDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Check if photo permission is permanently denied
  static Future<bool> isPhotosPermissionDenied() async {
    final status = await Permission.photos.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
