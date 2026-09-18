import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_version.dart';

typedef PackageInfoLoader = Future<PackageInfo> Function();

class InstalledAppVersionService {
  final PackageInfoLoader _loadPackageInfo;

  InstalledAppVersionService({
    PackageInfoLoader loadPackageInfo = PackageInfo.fromPlatform,
  }) : _loadPackageInfo = loadPackageInfo;

  Future<AppVersion> getCurrentVersion() async {
    final packageInfo = await _loadPackageInfo();

    return AppVersion.parse(packageInfo.version);
  }

  Future<String> getVersionLabel() async {
    final packageInfo = await _loadPackageInfo();

    return packageInfo.version;
  }

  Future<String> getBuildNumber() async {
    final packageInfo = await _loadPackageInfo();

    return packageInfo.buildNumber;
  }
}
