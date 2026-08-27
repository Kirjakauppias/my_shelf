import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/github_release.dart';
import '../services/app_update_checker.dart';
import '../services/installed_app_version_service.dart';
import '../services/update_check_exception.dart';

typedef ExternalUrlOpener = Future<bool> Function(Uri uri);

Future<bool> _defaultOpenUrl(Uri uri) {
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

class AppInfoDialog extends StatefulWidget {
  final InstalledAppVersionService versionService;
  final AppUpdateChecker updateChecker;
  final ExternalUrlOpener openUrl;

  AppInfoDialog({
    super.key,
    InstalledAppVersionService? versionService,
    AppUpdateChecker? updateChecker,
    ExternalUrlOpener? openUrl,
  }) : versionService = versionService ?? InstalledAppVersionService(),
       updateChecker = updateChecker ?? AppUpdateChecker(),
       openUrl = openUrl ?? _defaultOpenUrl;

  @override
  State<AppInfoDialog> createState() => _AppInfoDialogState();
}

class _AppInfoDialogState extends State<AppInfoDialog> {
  static final Uri _projectUri = Uri.parse(
    'https://github.com/Kirjakauppias/my_shelf',
  );

  static final Uri _issuesUri = Uri.parse(
    'https://github.com/Kirjakauppias/my_shelf/issues',
  );

  String? _versionLabel;
  String? _buildNumber;

  bool _loadingVersion = true;
  bool _checkingUpdate = false;

  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final version = await widget.versionService.getVersionLabel();

      final build = await widget.versionService.getBuildNumber();

      if (!mounted) {
        return;
      }

      setState(() {
        _versionLabel = version;
        _buildNumber = build;
        _loadingVersion = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingVersion = false;
        _statusMessage = 'Version tietojen lukeminen epäonnistui.';
      });
    }
  }

  Future<void> _checkForUpdates() async {
    if (_checkingUpdate) {
      return;
    }

    setState(() {
      _checkingUpdate = true;
      _statusMessage = null;
    });

    try {
      final result = await widget.updateChecker.check();

      if (!mounted) {
        return;
      }

      if (result.updateAvailable) {
        setState(() {
          _checkingUpdate = false;
        });

        await _showUpdateAvailableDialog(
          result.availableRelease!,
          currentVersion: result.currentVersion.toString(),
        );

        return;
      }

      setState(() {
        _checkingUpdate = false;
        _statusMessage = 'Käytössäsi on uusin saatavilla oleva versio.';
      });
    } on UpdateCheckException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _checkingUpdate = false;
        _statusMessage = error.message;
      });
    } on FormatException {
      if (!mounted) {
        return;
      }

      setState(() {
        _checkingUpdate = false;
        _statusMessage = 'Version tietojen käsittely epäonnistui.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _checkingUpdate = false;
        _statusMessage = 'Päivitysten tarkistus epäonnistui.';
      });
    }
  }

  Future<void> _showUpdateAvailableDialog(
    GitHubRelease release, {
    required String currentVersion,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Uusi versio saatavilla'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nykyinen versio: $currentVersion'),
              const SizedBox(height: 8),
              Text('Uusi versio: ${release.version}'),
              if (release.name != null && release.name!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(release.name!),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Myöhemmin'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final uri = Uri.parse(release.htmlUrl);

                await widget.openUrl(uri);
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Avaa julkaisusivu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openUri(Uri uri) async {
    final opened = await widget.openUrl(uri);

    if (!opened && mounted) {
      setState(() {
        _statusMessage = 'Linkin avaaminen epäonnistui.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final versionText = _loadingVersion
        ? 'Luetaan...'
        : _versionLabel == null
        ? 'Ei saatavilla'
        : _buildNumber == null || _buildNumber!.isEmpty
        ? _versionLabel!
        : '$_versionLabel ($_buildNumber)';

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.menu_book_outlined),
          SizedBox(width: 10),
          Text('Tietoja My Shelfistä'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline),
              title: const Text('Versio'),
              subtitle: Text(versionText),
            ),
            const Divider(),
            FilledButton.icon(
              onPressed: _checkingUpdate ? null : _checkForUpdates,
              icon: _checkingUpdate
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.system_update),
              label: Text(
                _checkingUpdate ? 'Tarkistetaan...' : 'Tarkista päivitykset',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                _openUri(_projectUri);
              },
              icon: const Icon(Icons.code),
              label: const Text('GitHub-projekti'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                _openUri(_issuesUri);
              },
              icon: const Icon(Icons.bug_report_outlined),
              label: const Text('Anna palautetta'),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Text(_statusMessage!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Sulje'),
        ),
      ],
    );
  }
}
