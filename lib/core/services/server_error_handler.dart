import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/services/bug_report_service.dart';
import 'package:tuoora/core/widgets/server_error_view.dart';

class ServerErrorHandler extends GetxService {
  static ServerErrorHandler get to => Get.find<ServerErrorHandler>();

  bool _isShowing = false;
  String? _routeAtError;
  dynamic _argsAtError;

  final isRetrying = false.obs;
  final retryFailed = false.obs;

  void showError({String? message}) {
    if (_isShowing || (Get.isDialogOpen ?? false)) return;
    _isShowing = true;
    retryFailed.value = false;

    // Remember where the user was so "Try Again" can reload that screen.
    _routeAtError = Get.currentRoute;
    _argsAtError = Get.arguments;
    if (Get.isRegistered<BugReportService>()) {
      BugReportService.to.markErrorScreen(_routeAtError);
    }

    Get.dialog(
      PopScope(
        canPop: false,
        child: ServerErrorView(message: message, handler: this),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.9),
    );
  }

  /// Checks that the server answers again, then closes the popup and reloads
  /// the screen the error happened on. Stays open (with a hint) if the server
  /// is still failing.
  Future<void> retry() async {
    if (isRetrying.value) return;
    isRetrying.value = true;
    retryFailed.value = false;
    try {
      final res = await Get.find<ApiClient>().get(ApiConstants.appVersions);
      final code = res.statusCode ?? 0;
      if (code > 0 && code < 500) {
        final route = _routeAtError;
        final args = _argsAtError;
        dismiss();
        await Future<void>.delayed(const Duration(milliseconds: 150));
        if (route != null &&
            route.isNotEmpty &&
            route != AppRoutes.splash &&
            route != AppRoutes.login &&
            route != AppRoutes.roleSelection) {
          Get.offNamed(route, arguments: args);
        }
      } else {
        retryFailed.value = true;
      }
    } catch (_) {
      retryFailed.value = true;
    } finally {
      isRetrying.value = false;
    }
  }

  void dismiss() {
    if (_isShowing) {
      _isShowing = false;
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }
}
