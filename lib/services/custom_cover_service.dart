import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

typedef DocumentsDirectoryProvider = Future<Directory> Function();

class CustomCoverService {
  final ImagePicker _imagePicker;
  final DocumentsDirectoryProvider _documentsDirectoryProvider;

  Directory? _cachedCoverDirectory;

  CustomCoverService({
    ImagePicker? imagePicker,
    DocumentsDirectoryProvider? documentsDirectoryProvider,
  }) : _imagePicker = imagePicker ?? ImagePicker(),
       _documentsDirectoryProvider =
           documentsDirectoryProvider ?? getApplicationDocumentsDirectory;

  /// Avaa laitteen kuvavalitsimen ja tallentaa valitun kuvan
  /// sovelluksen omaan pysyvään covers-hakemistoon.
  ///
  /// Palauttaa tallennetun tiedostonimen tai nullin,
  /// jos käyttäjä peruuttaa valinnan.
  Future<String?> pickAndSaveFromGallery({required String bookId}) async {
    final selectedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      imageQuality: 92,
      requestFullMetadata: false,
    );

    if (selectedImage == null) {
      return null;
    }

    final coverDirectory = await _getCoverDirectory();

    final safeBookId = _sanitizeBookId(bookId);
    final extension = _resolveImageExtension(selectedImage);

    // Aikaleima tekee tiedostonimestä yksilöllisen.
    // Näin Image.file ei näytä vanhaa kuvaa välimuistista,
    // kun käyttäjä vaihtaa kannen.
    final fileName =
        'cover_${safeBookId}_${DateTime.now().microsecondsSinceEpoch}'
        '$extension';

    final destinationPath = path.join(coverDirectory.path, fileName);

    await selectedImage.saveTo(destinationPath);

    return fileName;
  }

  /// Palauttaa oman kansikuvan tiedoston, jos se on edelleen olemassa.
  Future<File?> getCoverFile(String? fileName) async {
    if (fileName == null || fileName.trim().isEmpty) {
      return null;
    }

    final coverDirectory = await _getCoverDirectory();

    // basename estää tiedostonimeä osoittamasta covers-kansion ulkopuolelle.
    final safeFileName = path.basename(fileName);

    final coverFile = File(path.join(coverDirectory.path, safeFileName));

    if (!await coverFile.exists()) {
      return null;
    }

    return coverFile;
  }

  /// Poistaa sovelluksen tallentaman oman kansikuvan.
  Future<void> deleteCover(String? fileName) async {
    if (fileName == null || fileName.trim().isEmpty) {
      return;
    }

    final coverDirectory = await _getCoverDirectory();
    final safeFileName = path.basename(fileName);

    final coverFile = File(path.join(coverDirectory.path, safeFileName));

    if (await coverFile.exists()) {
      await coverFile.delete();
    }
  }

  Future<Directory> _getCoverDirectory() async {
    final cachedDirectory = _cachedCoverDirectory;

    if (cachedDirectory != null) {
      return cachedDirectory;
    }

    final documentsDirectory = await _documentsDirectoryProvider();

    final coverDirectory = Directory(
      path.join(documentsDirectory.path, 'covers'),
    );

    if (!await coverDirectory.exists()) {
      await coverDirectory.create(recursive: true);
    }

    _cachedCoverDirectory = coverDirectory;

    return coverDirectory;
  }

  String _sanitizeBookId(String bookId) {
    final sanitized = bookId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    return sanitized.isEmpty ? 'book' : sanitized;
  }

  String _resolveImageExtension(XFile image) {
    final extension = path.extension(image.path).toLowerCase();

    const supportedExtensions = {
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.heic',
      '.heif',
    };

    if (supportedExtensions.contains(extension)) {
      return extension;
    }

    switch (image.mimeType?.toLowerCase()) {
      case 'image/png':
        return '.png';

      case 'image/webp':
        return '.webp';

      case 'image/heic':
        return '.heic';

      case 'image/heif':
        return '.heif';

      case 'image/jpeg':
      default:
        return '.jpg';
    }
  }
}
