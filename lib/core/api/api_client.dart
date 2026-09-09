import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/services/institute_account_status_handler.dart';
import 'package:tuoora/core/services/server_error_handler.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/auth_repository_impl.dart';
import 'package:get/get.dart';

class ApiClient extends GetConnect {
  Future<bool>? _refreshFuture;
  bool _loggingOut = false;

  bool get isLoggingOut => _loggingOut;

  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.timeout = const Duration(seconds: 20);

    // Add default headers
    // Detailed Request Logging
    httpClient.addRequestModifier<dynamic>((request) {
      final authService = Get.find<AuthService>();

      // Only set application/json if no Accept header is already present
      if (!request.headers.containsKey('Accept')) {
        request.headers['Accept'] = 'application/json';
      }

      if (authService.isAuthenticated) {
        request.headers['Authorization'] = 'Bearer ${authService.token}';
      }

      print('🚀 [API REQUEST] ${request.method.toUpperCase()} ${request.url}');
      print('Headers: ${request.headers}');

      return request;
    });

    httpClient.addAuthenticator<dynamic>((request) async {
      final path = request.url.path;

      // Do not attempt to authenticate or force logout if the request is a login request
      if (path.endsWith(ApiConstants.instituteLogin) ||
          path.endsWith(ApiConstants.studentLogin) ||
          path.endsWith(ApiConstants.teacherLogin)) {
        return request;
      }

      if (path.endsWith(ApiConstants.authRefresh) ||
          path.endsWith('${ApiConstants.authRefresh}/')) {
        await _forceLogout();
        return request;
      }

      final authService = Get.find<AuthService>();
      if (authService.refreshToken.isEmpty) {
        await _forceLogout();
        return request;
      }

      final ok = await _tryRefresh();
      if (!ok) {
        await _forceLogout();
        return request;
      }
      request.headers['Authorization'] = 'Bearer ${authService.token}';
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      print('📥 [API RESPONSE] ${request.method.toUpperCase()} ${request.url}');
      print('Status Code: ${response.statusCode}');

      if (response.hasError) {
        print('❌ [API ERROR]');
        print('URL: ${request.url}');
        print('Status: ${response.statusCode} ${response.statusText}');
        if (response.body is String || response.body is Map) {
          print('Body: ${response.body}');
        } else {
          print('Body: [Binary Data or Unknown Format]');
        }

        if (response.statusCode == 403 &&
            Get.isRegistered<InstituteAccountStatusHandler>()) {
          final body = response.body;
          if (body is Map) {
            final status = body['status']?.toString().toLowerCase() ?? '';
            final message = body['message']?.toString() ?? '';
            if (status.isNotEmpty) {
              InstituteAccountStatusHandler.to.handleForbidden(
                status: status,
                message: message,
              );
            }
          }
        }

        if (response.statusCode == 401) {
          final urlStr = request.url.toString();
          if (!urlStr.contains(ApiConstants.instituteLogin) &&
              !urlStr.contains(ApiConstants.studentLogin) &&
              !urlStr.contains(ApiConstants.teacherLogin)) {
            _forceLogout();
          }
        }

        final code = response.statusCode ?? 0;
        if (code >= 500 && code < 600) {
          if (Get.isRegistered<ServerErrorHandler>()) {
            ServerErrorHandler.to.showError();
          }
        }
      } else {
        if (Get.isRegistered<ServerErrorHandler>()) {
          ServerErrorHandler.to.dismiss();
        }
      }

      print('--------------------------------------------------');
      return response;
    });

    super.onInit();
  }

  Future<bool> _tryRefresh() {
    final existing = _refreshFuture;
    if (existing != null) return existing;
    final fut = _doRefresh();
    _refreshFuture = fut;
    fut.whenComplete(() => _refreshFuture = null);
    return fut;
  }

  Future<bool> _doRefresh() async {
    if (!Get.isRegistered<AuthRepositoryImpl>()) return false;
    final auth = Get.find<AuthService>();
    final refreshToken = auth.refreshToken;
    if (refreshToken.isEmpty) return false;

    try {
      final repo = Get.find<AuthRepositoryImpl>();
      final fresh = await repo.refreshAccessToken(refreshToken);
      if (fresh == null) return false;
      await auth.updateTokens(
        accessToken: fresh.accessToken,
        refreshToken: fresh.refreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _forceLogout() async {
    if (_loggingOut) return;
    _loggingOut = true;
    try {
      final auth = Get.find<AuthService>();
      final role = auth.currentUser?.role ?? 'INSTITUTE';
      await auth.clearSession();
      Get.offAllNamed(AppRoutes.login, arguments: role);
      AppSnackBar.warning(
        AppStrings.errSessionExpired,
        title: AppStrings.sessionExpiredTitle,
      );
    } catch (_) {
      try {
        Get.offAllNamed(AppRoutes.login);
      } catch (_) {}
    } finally {
      Future<void>.delayed(const Duration(seconds: 3), () {
        _loggingOut = false;
      });
    }
  }
}
