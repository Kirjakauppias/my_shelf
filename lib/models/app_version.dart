class AppVersion implements Comparable<AppVersion> {
  final int major;
  final int minor;
  final int patch;
  final String? preRelease;

  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.preRelease,
  });

  factory AppVersion.parse(String source) {
    final value = source.trim();

    final match = RegExp(
      r'^v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$',
    ).firstMatch(value);

    if (match == null) {
      throw FormatException('Virheellinen versionumero: $source');
    }

    return AppVersion(
      major: int.parse(match.group(1)!),
      minor: int.parse(match.group(2)!),
      patch: int.parse(match.group(3)!),
      preRelease: match.group(4),
    );
  }

  bool get isPreRelease => preRelease != null;

  @override
  int compareTo(AppVersion other) {
    var comparison = major.compareTo(other.major);

    if (comparison != 0) {
      return comparison;
    }

    comparison = minor.compareTo(other.minor);

    if (comparison != 0) {
      return comparison;
    }

    comparison = patch.compareTo(other.patch);

    if (comparison != 0) {
      return comparison;
    }

    return _comparePreRelease(preRelease, other.preRelease);
  }

  bool isNewerThan(AppVersion other) {
    return compareTo(other) > 0;
  }

  static int _comparePreRelease(String? left, String? right) {
    // Vakaa julkaisu on saman version prereleasea uudempi.
    //
    // 1.0.0-alpha < 1.0.0
    if (left == null && right == null) {
      return 0;
    }

    if (left == null) {
      return 1;
    }

    if (right == null) {
      return -1;
    }

    final leftParts = left.split('.');
    final rightParts = right.split('.');

    final length = leftParts.length < rightParts.length
        ? leftParts.length
        : rightParts.length;

    for (var index = 0; index < length; index++) {
      final comparison = _compareIdentifier(
        leftParts[index],
        rightParts[index],
      );

      if (comparison != 0) {
        return comparison;
      }
    }

    return leftParts.length.compareTo(rightParts.length);
  }

  static int _compareIdentifier(String left, String right) {
    final leftNumber = int.tryParse(left);
    final rightNumber = int.tryParse(right);

    if (leftNumber != null && rightNumber != null) {
      return leftNumber.compareTo(rightNumber);
    }

    // SemVerissä numeerinen prerelease-osa on
    // ei-numeerista osaa alempana.
    if (leftNumber != null) {
      return -1;
    }

    if (rightNumber != null) {
      return 1;
    }

    return left.compareTo(right);
  }

  @override
  bool operator ==(Object other) {
    return other is AppVersion &&
        major == other.major &&
        minor == other.minor &&
        patch == other.patch &&
        preRelease == other.preRelease;
  }

  @override
  int get hashCode {
    return Object.hash(major, minor, patch, preRelease);
  }

  @override
  String toString() {
    final base = '$major.$minor.$patch';

    if (preRelease == null) {
      return base;
    }

    return '$base-$preRelease';
  }
}
