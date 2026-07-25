import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/services/custom_cover_service.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory temporaryDirectory;
  late CustomCoverService service;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'my_shelf_cover_test_',
    );

    service = CustomCoverService(
      documentsDirectoryProvider: () async {
        return temporaryDirectory;
      },
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('getCoverFile palauttaa nullin, kun tiedostoa ei ole', () async {
    final file = await service.getCoverFile('missing.jpg');

    expect(file, isNull);
  });

  test('getCoverFile palauttaa olemassa olevan kansikuvan', () async {
    final coversDirectory = Directory(
      path.join(temporaryDirectory.path, 'covers'),
    );

    await coversDirectory.create(recursive: true);

    final coverFile = File(path.join(coversDirectory.path, 'cover.jpg'));

    await coverFile.writeAsBytes([1, 2, 3]);

    final result = await service.getCoverFile('cover.jpg');

    expect(result, isNotNull);
    expect(await result!.exists(), isTrue);
    expect(result.path, coverFile.path);
  });

  test('deleteCover poistaa tallennetun kansikuvan', () async {
    final coversDirectory = Directory(
      path.join(temporaryDirectory.path, 'covers'),
    );

    await coversDirectory.create(recursive: true);

    final coverFile = File(path.join(coversDirectory.path, 'cover.jpg'));

    await coverFile.writeAsBytes([1, 2, 3]);

    expect(await coverFile.exists(), isTrue);

    await service.deleteCover('cover.jpg');

    expect(await coverFile.exists(), isFalse);
  });
}
