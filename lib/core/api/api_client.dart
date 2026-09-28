import 'package:flutter/foundation.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/services/bug_report_service.dart';
import 'package:tuoora/core/services/institute_account_status_handler.dart';
import 'package:tuoora/core/services/server_error_handler.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/auth_repository_impl.dart';
import 'package:get/get.dart';

class ApiClient extends GetConnect {
  Future<_RefreshOutcome>? _refreshFuture;
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

      if (kDebugMode) {
        debugPrint(
          '🚀 [API REQUEST] ${request.method.toUpperCase()} ${request.url}',
        );
        debugPrint('Headers: ${request.headers}');
      }

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

      final outcome = await _tryRefresh();
      if (outcome == _RefreshOutcome.rejected) {
        // The refresh token itself is invalid or expired: sign in again.
        await _forceLogout();
        return request;
      }
      if (outcome == _RefreshOutcome.unavailable) {
        // Server or network trouble while refreshing: keep the session and
        // let this request fail normally instead of logging the user out.
        return request;
      }
      request.headers['Authorization'] = 'Bearer ${authService.token}';
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      if (kDebugMode) {
        debugPrint(
          '📥 [API RESPONSE] ${request.method.toUpperCase()} ${request.url}',
        );
        debugPrint('Status Code: ${response.statusCode}');
      }

      if (Get.isRegistered<BugReportService>()) {
        String? serverMessage;
        final b = response.body;
        if (response.hasError && b is Map) {
          serverMessage = (b['message'] ?? b['error'])?.toString();
        }
        BugReportService.to.record(
          method: request.method,
          url: request.url,
          status: response.statusCode ?? 0,
          message: response.hasError ? (serverMessage ?? response.statusText) : null,
          isError: response.hasError && (response.statusCode ?? 0) >= 500,
        );
      }

      if (response.hasError) {
        if (kDebugMode) {
          debugPrint('❌ [API ERROR]');
          debugPrint('URL: ${request.url}');
          debugPrint('Status: ${response.statusCode} ${response.statusText}');
          if (response.body is String || response.body is Map) {
            debugPrint('Body: ${response.body}');
          } else {
            debugPrint('Body: [Binary Data or Unknown Format]');
          }
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

        // A 401 is NOT handled here. GetConnect runs this modifier before the
        // authenticator above, which refreshes the access token and retries
        // the request. Logging out here would wipe the session before the
        // refresh token could ever be used.

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

      if (kDebugMode) {
        debugPrint('--------------------------------------------------');
      }
      return response;
    });

    super.onInit();
  }

  Future<_RefreshOutcome> _tryRefresh() {
    final existing = _refreshFuture;
    if (existing != null) return existing;
    final fut = _doRefresh();
    _refreshFuture = fut;
    fut.whenComplete(() => _refreshFuture = null);
    return fut;
  }

  Future<_RefreshOutcome> _doRefresh() async {
    if (!Get.isRegistered<AuthRepositoryImpl>()) {
      return _RefreshOutcome.unavailable;
    }
    final auth = Get.find<AuthService>();
    final refreshToken = auth.refreshToken;
    if (refreshToken.isEmpty) return _RefreshOutcome.rejected;

    try {
      final repo = Get.find<AuthRepositoryImpl>();
      final fresh = await repo.refreshAccessToken(refreshToken);
      if (fresh == null) return _RefreshOutcome.rejected;
      await auth.updateTokens(
        accessToken: fresh.accessToken,
        refreshToken: fresh.refreshToken,
      );
      return _RefreshOutcome.refreshed;
    } catch (_) {
      return _RefreshOutcome.unavailable;
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

/// Result of trying to swap the refresh token for new tokens.
enum _RefreshOutcome { refreshed, rejected, unavailable }
