import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionHelper {
  /// Request Camera Permission
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      debugPrint('✅ Camera permission granted');
      return true;
    } else if (status.isDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Camera Permission Required',
          'Camera access is needed to take photos. Please grant permission in settings.',
        );
      }
      debugPrint('❌ Camera permission denied');
      return false;
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(context, 'Camera');
      }
      debugPrint('❌ Camera permission permanently denied');
      return false;
    }

    return false;
  }

  /// Request Gallery Permission
  static Future<bool> requestGalleryPermission(BuildContext context) async {
    PermissionStatus status;

    // Check if already granted
    if (await Permission.photos.isGranted) {
      debugPrint('✅ Gallery permission already granted');
      return true;
    }

    // Request for Android 13+ (API 33+)
    status = await Permission.photos.request();

    // Fallback for Android 12 and below
    if (status.isDenied || status.isPermanentlyDenied) {
      debugPrint('📱 Trying storage permission (Android 12 and below)');
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      debugPrint('✅ Gallery permission granted');
      return true;
    } else if (status.isDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Gallery Permission Required',
          'Gallery access is needed to select photos. Please grant permission in settings.',
        );
      }
      debugPrint('❌ Gallery permission denied');
      return false;
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(context, 'Gallery');
      }
      debugPrint('❌ Gallery permission permanently denied');
      return false;
    }

    return false;
  }

  /// Request Notification Permission
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      debugPrint('✅ Notification permission granted');
      return true;
    } else if (status.isDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Notification Permission Required',
          'Notification access is needed to send reminders. Please grant permission in settings.',
        );
      }
      debugPrint('❌ Notification permission denied');
      return false;
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(context, 'Notification');
      }
      debugPrint('❌ Notification permission permanently denied');
      return false;
    }

    return false;
  }

  /// Show Permission Denied Dialog
  static void _showPermissionDialog(
      BuildContext context,
      String title,
      String message,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5784EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show Settings Dialog for Permanently Denied Permissions
  static void _showSettingsDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.settings, color: Color(0xFF5784EB), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$permissionName Permission',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '$permissionName permission is permanently denied.\n\n'
              'Please enable it manually from:\n'
              'Settings → Apps → Mindly → Permissions → $permissionName',
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5784EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Check if Camera Permission is Granted
  static Future<bool> isCameraGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Check if Gallery Permission is Granted
  static Future<bool> isGalleryGranted() async {
    return await Permission.photos.isGranted || await Permission.storage.isGranted;
  }

  /// Check if Notification Permission is Granted
  static Future<bool> isNotificationGranted() async {
    return await Permission.notification.isGranted;
  }

  /// Request Multiple Permissions at Once
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
      List<Permission> permissions,
      ) async {
    return await permissions.request();
  }
}