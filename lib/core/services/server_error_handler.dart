import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/widgets/server_error_view.dart';

class ServerErrorHandler extends GetxService {
  static ServerErrorHandler get to => Get.find<ServerErrorHandler>();

  bool _isShowing = false;

  void showError({String? message}) {
    if (_isShowing || (Get.isDialogOpen ?? false)) return;
    _isShowing = true;

    Get.dialog(
      PopScope(
        canPop: false,
        child: ServerErrorView(message: message, onRetry: dismiss),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.9),
    );
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
