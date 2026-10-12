import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/utils/url_launcher_utils.dart';

/// Checks for a newer app version and offers the update.
///
/// * Android: Google Play in-app updates (forced for priority >= 4, otherwise
///   an "Update" dialog that starts a flexible download). If Play reports
///   nothing (e.g. a sideloaded build) the backend `/app-versions` value is
///   compared instead and the dialog opens the Play Store page.
/// * iOS: the App Store lookup for this bundle id; the dialog opens the store.
///
/// Runs at launch and again when the app returns to the foreground.
class AppUpdateService extends GetxService with WidgetsBindingObserver {
  static AppUpdateService get to => Get.find<AppUpdateService>();

  static const _resumeCooldown = Duration(hours: 1);

  bool _checking = false;
  bool _dialogOpen = false;
  DateTime? _lastCheck;
  String? _dismissedVersion;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final last = _lastCheck;
    if (last != null && DateTime.now().difference(last) < _resumeCooldown) {
      return;
    }
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (_checking || _dialogOpen) return;
    _checking = true;
    _lastCheck = DateTime.now();
    try {
      if (Platform.isAndroid) {
        await _checkAndroid();
      } else {
        await _checkIos();
      }
    } catch (_) {
      // Offline or store unreachable: never bother the user about it.
    } finally {
      _checking = false;
    }
  }

  // ---------------------------------------------------------------- Android

  Future<void> _checkAndroid() async {
    final AppUpdateInfo info;
    try {
      info = await InAppUpdate.checkForUpdate();
    } catch (_) {
      await _checkBackendVersion();
      return;
    }
    // A flexible update finished downloading earlier but was never installed.
    if (info.installStatus == InstallStatus.downloaded) {
      _showRestartPrompt();
      return;
    }
    if (info.updateAvailability != UpdateAvailability.updateAvailable) {
      await _checkBackendVersion();
      return;
    }

    if (info.updatePriority >= 4 && info.immediateUpdateAllowed) {
      await InAppUpdate.performImmediateUpdate();
      return;
    }

    final versionKey = 'play-${info.availableVersionCode}';
    if (_dismissedVersion == versionKey) return;
    final accepted = await _showUpdateDialog(versionKey: versionKey);
    if (!accepted) return;

    if (info.flexibleUpdateAllowed) {
      final result = await InAppUpdate.startFlexibleUpdate();
      if (result == AppUpdateResult.success) _showRestartPrompt();
    } else if (info.immediateUpdateAllowed) {
      await InAppUpdate.performImmediateUpdate();
    }
  }

  /// Fallback when Play does not know about an update: compare against the
  /// version the backend publishes.
  Future<void> _checkBackendVersion() async {
    final local = (await PackageInfo.fromPlatform());
    final latest = await _backendLatestVersion();
    if (latest == null || !_isNewer(latest, local.version)) return;
    if (_dismissedVersion == latest) return;
    final accepted = await _showUpdateDialog(
      version: latest,
      versionKey: latest,
    );
    if (accepted) {
      await UrlLauncherUtils.openExternal(
        'https://play.google.com/store/apps/details?id=${local.packageName}',
      );
    }
  }

  Future<String?> _backendLatestVersion() async {
    final client = Get.isRegistered<ApiClient>()
        ? Get.find<ApiClient>()
        : ApiClient();
    final response = await client
        .get(ApiConstants.appVersions)
        .timeout(const Duration(seconds: 6));
    final data = response.body is Map ? response.body['data'] : null;
    if (response.hasError || data is! Map) return null;
    final isStudent =
        Get.isRegistered<AuthService>() &&
        Get.find<AuthService>().currentUser?.role == 'STUDENT';
    final v = isStudent ? data['student_app_version'] : data['app_version'];
    final s = v?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }

  // -------------------------------------------------------------------- iOS

  Future<void> _checkIos() async {
    final local = await PackageInfo.fromPlatform();
    final res = await GetConnect(timeout: const Duration(seconds: 8)).get(
      'https://itunes.apple.com/lookup?bundleId=${local.packageName}',
    );
    final body = res.body;
    if (res.hasError || body is! Map) return;
    final results = body['results'];
    if (results is! List || results.isEmpty) return;
    final app = results.first;
    final latest = app['version']?.toString();
    final storeUrl = app['trackViewUrl']?.toString();
    if (latest == null || storeUrl == null) return;
    if (!_isNewer(latest, local.version)) return;
    if (_dismissedVersion == latest) return;

    final accepted = await _showUpdateDialog(
      version: latest,
      versionKey: latest,
    );
    if (accepted) await UrlLauncherUtils.openExternal(storeUrl);
  }

  // ----------------------------------------------------------------- shared

  /// Numeric dotted-version compare ("1.10.0" is newer than "1.2.0").
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

  /// Shows the dialog once the splash screen has handed over (a route change
  /// would otherwise close it). Returns true if the user tapped Update.
  Future<bool> _showUpdateDialog({
    String? version,
    required String versionKey,
  }) async {
    for (var i = 0; i < 30 && Get.currentRoute == AppRoutes.splash; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    if (Get.context == null) return false;

    _dialogOpen = true;
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(
            Icons.system_update_rounded,
            color: AppColors.primaryBrand,
            size: 32,
          ),
          title: const Text(AppStrings.updateAvailableTitle),
          content: Text(AppStrings.updateAvailableMessage(version)),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text(AppStrings.updateLaterButton),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBrand,
              ),
              onPressed: () => Get.back(result: true),
              child: const Text(AppStrings.updateNowButton),
            ),
          ],
        ),
      );
      if (result != true) _dismissedVersion = versionKey;
      return result == true;
    } finally {
      _dialogOpen = false;
    }
  }

  void _showRestartPrompt() {
    Get.snackbar(
      AppStrings.updateReadyTitle,
      AppStrings.updateReadyMessage,
      backgroundColor: AppColors.primaryBrand,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.system_update_rounded, color: AppColors.white),
      duration: const Duration(seconds: 8),
      mainButton: TextButton(
        onPressed: () async {
          try {
            await InAppUpdate.completeFlexibleUpdate();
          } catch (_) {}
        },
        child: const Text(
          AppStrings.updateRestartButton,
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
