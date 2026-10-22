
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/services/image_upload_service.dart';

void main() {
  late ImageUploadService service;

  setUp(() {
    service = ImageUploadService();
  });

  
  XFile testImage({
    String name = 'milk-photo.jpg',
    int size = 100,
  }) {
    return XFile.fromData(
      Uint8List(size),
      name: name,
      path: name,
      mimeType: 'image/jpeg',
    );
  }


  group('Image validation', () {
    test('accepts a non-empty JPG image under 5 MB', () async {
      await expectLater(
        service.validateImage(testImage()),
        completes,
      );
    });

    test('accepts supported image extensions regardless of case', () async {
      await expectLater(
        service.validateImage(testImage(name: 'photo.PNG')),
        completes,
      );
    });

    test('rejects unsupported file extensions', () async {
      await expectLater(
        service.validateImage(testImage(name: 'document.pdf')),
        throwsA(isA<ImageUploadException>()),
      );
    });

    test('rejects a filename without an extension', () async {
      await expectLater(
        service.validateImage(testImage(name: 'photo')),
        throwsA(isA<ImageUploadException>()),
      );
    });

    test('rejects empty files', () async {
      await expectLater(
        service.validateImage(testImage(size: 0)),
        throwsA(isA<ImageUploadException>()),
      );
    });

    test('rejects files larger than 5 MB', () async {
      await expectLater(
        service.validateImage(
          testImage(size: ImageUploadService.maxFileSizeBytes + 1),
        ),
        throwsA(isA<ImageUploadException>()),
      );
    });
  });

  group('Upload behavior before storage setup', () {
    test('does not pretend an upload succeeded', () async {
      await expectLater(
        service.uploadImage(testImage()),
        throwsA(isA<StateError>()),
      );
    });

    test('validates the image before attempting upload', () async {
      await expectLater(
        service.uploadImage(testImage(name: 'document.pdf')),
        throwsA(isA<ImageUploadException>()),
      );
    });
  });
}
