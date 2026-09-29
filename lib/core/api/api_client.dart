import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/services/bug_report_service.dart';
import 'package:tuoora/core/services/institute_account_status_handler.dart';
import 'package:tuoora/core/services/server_error_handler.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/auth_repository_impl.dart';

class ApiClient extends GetConnect {
  Future<_RefreshOutcome>? _refreshFuture;
  bool _loggingOut = false;
  static const _retryHeader = 'X-Auth-Retry';

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

      // Mark this as the post-refresh retry: a 401 on it means the session is
      // really dead, and the response modifier logs the user out.
      request.headers[_retryHeader] = '1';

      final outcome = await _tryRefresh();
      if (outcome == _RefreshOutcome.rejected) {
        // The refresh token itself is invalid or expired: sign in again.
        await _forceLogout();
        return request;
      }
      if (outcome == _RefreshOutcome.unavailable) {
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
          message: response.hasError
              ? (serverMessage ?? response.statusText)
              : null,
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
          final urlStr = request.url.toString();
          if (!urlStr.contains(ApiConstants.instituteLogin) &&
              !urlStr.contains(ApiConstants.studentLogin) &&
              !urlStr.contains(ApiConstants.teacherLogin)) {
            final body = response.body;
            String status = '';
            String message = '';
            if (body is Map) {
              status = body['status']?.toString().toLowerCase() ?? '';
              message = body['message']?.toString() ?? '';
            } else if (body is String) {
              message = body;
            }
            InstituteAccountStatusHandler.to.handleForbidden(
              status: status,
              message: message,
            );
          }
        }

        // A first 401 is NOT handled here: GetConnect runs this modifier
        // before the authenticator above, which refreshes the access token
        // and retries the request. Only a 401 on that retried request (still
        // unauthorised after a refresh) means the session is dead.
        if (response.statusCode == 401 &&
            request.headers.containsKey(_retryHeader)) {
          final p = request.url.path;
          final isAuthCall =
              p.endsWith(ApiConstants.instituteLogin) ||
              p.endsWith(ApiConstants.studentLogin) ||
              p.endsWith(ApiConstants.teacherLogin) ||
              p.endsWith(ApiConstants.authRefresh);
          if (!isAuthCall) _forceLogout();
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
    var role = 'STUDENT';
    try {
      final auth = Get.find<AuthService>();
      role = auth.currentUser?.role ?? role;
      await auth.clearSession();
    } catch (_) {}
    _goToLogin(role);
    Future<void>.delayed(const Duration(seconds: 3), () {
      _loggingOut = false;
    });
  }

  /// Navigates straight to login. A post-frame callback alone is not enough:
  /// it only fires when a frame is scheduled, which an idle dashboard never
  /// does, so the user would stay on the page.
  void _goToLogin(String role) {
    void go() {
      try {
        if (Get.currentRoute != AppRoutes.login) {
          Get.offAllNamed(AppRoutes.login, arguments: role);
          AppSnackBar.warning(
            AppStrings.errSessionExpired,
            title: AppStrings.sessionExpiredTitle,
          );
        }
      } catch (e) {
        if (kDebugMode) debugPrint('ApiClient: login redirect failed: $e');
      }
    }

    final binding = WidgetsBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.idle) {
      go();
    } else {
      binding.addPostFrameCallback((_) => go());
      binding.scheduleFrame();
    }
  }
}

/// Result of trying to swap the refresh token for new tokens.
enum _RefreshOutcome { refreshed, rejected, unavailable }
