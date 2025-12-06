import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/errors/exceptions.dart';

/// Service for picking images from camera or gallery
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress to 85% quality
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        return null; // User cancelled
      }

      return File(image.path);
    } catch (e) {
      throw AppStorageException(
        message: 'Failed to capture image: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress to 85% quality
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        return null; // User cancelled
      }

      return File(image.path);
    } catch (e) {
      throw AppStorageException(
        message: 'Failed to select image: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Pick multiple images from gallery (for future use)
  Future<List<File>> pickMultipleFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      throw AppStorageException(
        message: 'Failed to select images: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
