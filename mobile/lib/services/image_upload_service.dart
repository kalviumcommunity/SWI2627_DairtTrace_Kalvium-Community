
import 'package:image_picker/image_picker.dart';

class ImageUploadException implements Exception {
  const ImageUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ImageUploadService {
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  static const Set<String> allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  Future<void> validateImage(XFile image) async {
    final fileName = image.path.isNotEmpty ? image.path : image.name;
    final extension = fileName.split('/').last.split(r'\').last;
    final dotIndex = extension.lastIndexOf('.');

    if (dotIndex <= 0 || dotIndex == extension.length - 1) {
      throw const ImageUploadException(
        'The selected file must have a valid image extension.',
      );
    }

    final fileExtension = extension.substring(dotIndex + 1).toLowerCase();

    if (!allowedExtensions.contains(fileExtension)) {
      throw const ImageUploadException(
        'Unsupported image type. Choose JPG, JPEG, PNG, or WEBP.',
      );
    }

    final fileSize = await image.length();

    if (fileSize == 0) {
      throw const ImageUploadException('The selected image is empty.');
    }

    if (fileSize > maxFileSizeBytes) {
      throw const ImageUploadException(
        'Image size must not exceed 5 MB.',
      );
    }
  }

  Future<Never> uploadImage(XFile image) async {
    await validateImage(image);

    throw StateError(
      'Image storage is not configured. '
      'Connect an approved storage provider before uploading.',
    );
  }
}
