import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:my_shelf/services/app_update_checker.dart';
import 'package:my_shelf/services/installed_app_version_service.dart';
import 'package:my_shelf/services/update_service.dart';
import 'package:my_shelf/widgets/app_info_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  testWidgets('näyttää asennetun version ja build-numeron', (tester) async {
    await tester.pumpWidget(
      _testApp(version: '0.13.0-alpha', buildNumber: '14', releases: const []),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Avaa'));

    await tester.pumpAndSettle();

    expect(find.text('0.13.0-alpha (14)'), findsOneWidget);

    expect(find.text('Tarkista päivitykset'), findsOneWidget);
  });

  testWidgets('ilmoittaa kun uudempaa versiota ei ole', (tester) async {
    await tester.pumpWidget(
      _testApp(
        version: '0.13.0-alpha',
        buildNumber: '14',
        releases: [_releaseJson(tag: 'v0.13.0-alpha')],
      ),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Avaa'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tarkista päivitykset'));

    await tester.pumpAndSettle();

    expect(
      find.text('Käytössäsi on uusin saatavilla oleva versio.'),
      findsOneWidget,
    );
  });

  testWidgets('näyttää uudemman GitHub-julkaisun', (tester) async {
    await tester.pumpWidget(
      _testApp(
        version: '0.13.0-alpha',
        buildNumber: '14',
        releases: [_releaseJson(tag: 'v0.14.0-alpha')],
      ),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Avaa'));

    await tester.pumpAndSettle();

    await tester.tap(find.text('Tarkista päivitykset'));

    await tester.pumpAndSettle();

    expect(find.text('Uusi versio saatavilla'), findsOneWidget);

    expect(find.text('Nykyinen versio: 0.13.0-alpha'), findsOneWidget);

    expect(find.text('Uusi versio: 0.14.0-alpha'), findsOneWidget);

    expect(find.text('Avaa julkaisusivu'), findsOneWidget);
  });

  testWidgets('avaa uuden version julkaisusivun', (tester) async {
    Uri? openedUri;

    await tester.pumpWidget(
      _testApp(
        version: '0.13.0-alpha',
        buildNumber: '14',
        releases: [_releaseJson(tag: 'v0.14.0-alpha')],
        openUrl: (uri) async {
          openedUri = uri;
          return true;
        },
      ),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Avaa'));

    await tester.pumpAndSettle();

    await tester.tap(find.text('Tarkista päivitykset'));

    await tester.pumpAndSettle();

    await tester.tap(find.text('Avaa julkaisusivu'));

    await tester.pump();

    expect(
      openedUri,
      Uri.parse(
        'https://github.com/'
        'Kirjakauppias/my_shelf/'
        'releases/tag/v0.14.0-alpha',
      ),
    );
  });
}

Widget _testApp({
  required String version,
  required String buildNumber,
  required List<Map<String, dynamic>> releases,
  ExternalUrlOpener? openUrl,
}) {
  final installedVersionService = InstalledAppVersionService(
    loadPackageInfo: () async {
      return PackageInfo(
        appName: 'My Shelf',
        packageName: 'com.example.my_shelf',
        version: version,
        buildNumber: buildNumber,
        buildSignature: '',
        installerStore: null,
      );
    },
  );

  final updateService = UpdateService(
    get: (uri, {headers}) async {
      return http.Response(
        jsonEncode(releases),
        200,
        headers: const {'content-type': 'application/json'},
      );
    },
  );

  final checker = AppUpdateChecker(
    installedVersionService: installedVersionService,
    updateService: updateService,
  );

  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) {
                    return AppInfoDialog(
                      versionService: installedVersionService,
                      updateChecker: checker,
                      openUrl: openUrl,
                    );
                  },
                );
              },
              child: const Text('Avaa'),
            ),
          );
        },
      ),
    ),
  );
}

Map<String, dynamic> _releaseJson({required String tag}) {
  return {
    'tag_name': tag,
    'name': 'My Shelf $tag',
    'html_url':
        'https://github.com/'
        'Kirjakauppias/my_shelf/'
        'releases/tag/$tag',
    'prerelease': true,
    'draft': false,
  };
}
