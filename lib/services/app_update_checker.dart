import '../models/app_version.dart';
import '../models/github_release.dart';
import 'installed_app_version_service.dart';
import 'update_service.dart';

class AppUpdateCheckResult {
  final AppVersion currentVersion;
  final GitHubRelease? availableRelease;

  const AppUpdateCheckResult({
    required this.currentVersion,
    this.availableRelease,
  });

  bool get updateAvailable => availableRelease != null;
}

class AppUpdateChecker {
  final InstalledAppVersionService _installedVersionService;

  final UpdateService _updateService;

  AppUpdateChecker({
    InstalledAppVersionService? installedVersionService,
    UpdateService? updateService,
  }) : _installedVersionService =
           installedVersionService ?? InstalledAppVersionService(),
       _updateService = updateService ?? UpdateService();

  Future<AppUpdateCheckResult> check() async {
    final currentVersion = await _installedVersionService.getCurrentVersion();

    final availableRelease = await _updateService.checkForUpdate(
      currentVersion,
    );

    return AppUpdateCheckResult(
      currentVersion: currentVersion,
      availableRelease: availableRelease,
    );
  }
}
