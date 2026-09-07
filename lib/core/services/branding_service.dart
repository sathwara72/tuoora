import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/data/models/app_branding_model.dart';

/// Resolves this build's white-label branding (logo + display name) at
/// launch.
///
/// This app is compiled per-institute — one build = one institute, baked in
/// at BUILD TIME via `--dart-define=INSTITUTE_ID=...` (see
/// tool/build_white_label.sh). Brand *colors* are baked at build time too
/// (see AppColors.primaryBrand), since they're read from hundreds of call
/// sites including `const` ones. Logo and display name, by contrast, are
/// fetched at RUNTIME from the baked-in institute_id, so an institute can
/// update either without needing a new app-store submission — the small
/// number of call sites (~10) can afford to read a service instead of a
/// compile-time constant.
///
/// Must never block startup or crash on a slow/offline network: reads the
/// last-known-good cache first (instant), then refreshes from the network
/// in the background of `init()` with a short timeout, silently keeping the
/// cached (or default, non-white-label) value on any failure.
class BrandingService extends GetxService {
  /// 0 = the default shared Tuoora build (not white-labeled).
  static const int instituteId = int.fromEnvironment(
    'INSTITUTE_ID',
    defaultValue: 0,
  );

  static const _cacheKey = 'app_branding_cache';

  final GetStorage _storage = GetStorage();
  AppBranding _branding = AppBranding.none;

  AppBranding get branding => _branding;
  bool get isWhiteLabeled => _branding.whiteLabeled;

  String get appName {
    final name = _branding.appName;
    return (name != null && name.trim().isNotEmpty) ? name : AppStrings.appName;
  }

  String? get logoUrl => _branding.logoUrl;

  Future<BrandingService> init() async {
    _loadFromCache();

    if (instituteId <= 0) return this;

    try {
      final client = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
      final response = await client
          .get(
            ApiConstants.appBranding,
            query: {'institute_id': instituteId.toString()},
          )
          .timeout(const Duration(seconds: 6));

      if (response.status.hasError || response.body == null) return this;

      final data = response.body['data'];
      if (data == null) return this;

      final fetched = AppBranding.fromJson(Map<String, dynamic>.from(data));
      _branding = fetched;
      await _storage.write(_cacheKey, fetched.toJson());
    } catch (_) {
      // Offline, timeout, or a bad response — keep the cached/default value.
    }

    return this;
  }

  void _loadFromCache() {
    final cached = _storage.read(_cacheKey);
    if (cached == null) return;
    try {
      _branding = AppBranding.fromJson(Map<String, dynamic>.from(cached));
    } catch (_) {
      _branding = AppBranding.none;
    }
  }
}
