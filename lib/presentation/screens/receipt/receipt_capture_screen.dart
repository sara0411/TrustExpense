import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/permission_helper.dart';
import '../../../data/services/image_picker_service.dart';
import 'image_preview_screen.dart';

/// Screen for capturing receipt images
class ReceiptCaptureScreen extends StatefulWidget {
  const ReceiptCaptureScreen({super.key});

  @override
  State<ReceiptCaptureScreen> createState() => _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends State<ReceiptCaptureScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  bool _isLoading = false;

  Future<void> _pickFromCamera() async {
    // Check permission
    final hasPermission = await PermissionHelper.isCameraPermissionGranted();
    
    if (!hasPermission) {
      final granted = await PermissionHelper.requestCameraPermission();
      if (!granted) {
        if (mounted) {
          _showPermissionDeniedDialog('Camera');
        }
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final File? image = await _imagePickerService.pickFromCamera();
      
      if (image != null && mounted) {
        Navigator.of(context).pop(); // Close bottom sheet
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImagePreviewScreen(imageFile: image),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    // Check permission
    final hasPermission = await PermissionHelper.isPhotosPermissionGranted();
    
    if (!hasPermission) {
      final granted = await PermissionHelper.requestPhotosPermission();
      if (!granted) {
        if (mounted) {
          _showPermissionDeniedDialog('Photos');
        }
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final File? image = await _imagePickerService.pickFromGallery();
      
      if (image != null && mounted) {
        Navigator.of(context).pop(); // Close bottom sheet
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImagePreviewScreen(imageFile: image),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPermissionDeniedDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
          'Please grant $permissionType permission to capture receipts. '
          'You can enable it in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionHelper.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Capture Receipt',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Camera option
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x1A4A90E2), // primary with 10% opacity
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AppColors.primary,
              ),
            ),
            title: const Text('Take Photo'),
            subtitle: const Text('Use camera to capture receipt'),
            trailing: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isLoading ? null : _pickFromCamera,
          ),
          const SizedBox(height: 8),

          // Gallery option
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x1AA9DFBF), // accent with 10% opacity
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.photo_library,
                color: AppColors.accent,
              ),
            ),
            title: const Text('Choose from Gallery'),
            subtitle: const Text('Select existing photo'),
            trailing: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isLoading ? null : _pickFromGallery,
          ),
          const SizedBox(height: 16),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
