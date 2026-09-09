import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/utils/url_launcher_utils.dart';

/// Renders `App version X.Y.Z` (with build number when available) pulled
/// from the bundled platform manifests via `package_info_plus`, then checks
/// the admin-configured "latest version" from the backend (`/app-versions`,
/// set via the admin panel) and shows an "Update available" pill when this
/// build is older. The backend call is best-effort: offline or a slow/failed
/// response just leaves the update pill hidden, never blocks or misleads.
class AppVersionLabel extends StatelessWidget {
  final TextAlign? textAlign;

  /// Compares against the backend's `student_app_version` instead of its
  /// `app_version` — the admin panel tracks the two separately even though
  /// today they ship from the same Flutter codebase.
  final bool isStudentApp;

  const AppVersionLabel({super.key, this.textAlign, this.isStudentApp = false});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_VersionCheck>(
      future: _check(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final result = snapshot.data!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'App version ${result.currentDisplay}',
              textAlign: textAlign ?? TextAlign.center,
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
              ),
            ),
            if (result.updateAvailable) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _openStore(result.packageName),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrandLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.system_update_rounded,
                        size: 14,
                        color: AppColors.primaryBrand,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Update available (v${result.latestVersion})',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<_VersionCheck> _check() async {
    final info = await PackageInfo.fromPlatform();
    final build = info.buildNumber.isNotEmpty ? '+${info.buildNumber}' : '';

    String? latest;
    try {
      final client = Get.isRegistered<ApiClient>()
          ? Get.find<ApiClient>()
          : ApiClient();
      final response = await client
          .get(ApiConstants.appVersions)
          .timeout(const Duration(seconds: 6));
      if (!response.status.hasError && response.body != null) {
        final data = response.body['data'];
        if (data != null) {
          latest = isStudentApp
              ? data['student_app_version']?.toString()
              : data['app_version']?.toString();
        }
      }
    } catch (_) {
      // Offline, timeout, or backend hiccup — just show the local version.
    }

    return _VersionCheck(
      currentDisplay: '${info.version}$build',
      latestVersion: latest ?? info.version,
      updateAvailable: latest != null && _isNewer(latest, info.version),
      packageName: info.packageName,
    );
  }

  /// Numeric dotted-version compare (e.g. "1.2.0" vs "1.10.0" — a plain
  /// string compare would wrongly call 1.2.0 the newer one).
  bool _isNewer(String remote, String local) {
    final r = remote.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final l = local.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final len = r.length > l.length ? r.length : l.length;
    for (var i = 0; i < len; i++) {
      final rv = i < r.length ? r[i] : 0;
      final lv = i < l.length ? l[i] : 0;
      if (rv != lv) return rv > lv;
    }
    return false;
  }

  Future<void> _openStore(String packageName) {
    return UrlLauncherUtils.openExternal(
      'https://play.google.com/store/apps/details?id=$packageName',
    );
  }
}

class _VersionCheck {
  final String currentDisplay;
  final String latestVersion;
  final bool updateAvailable;
  final String packageName;

  _VersionCheck({
    required this.currentDisplay,
    required this.latestVersion,
    required this.updateAvailable,
    required this.packageName,
  });
}
