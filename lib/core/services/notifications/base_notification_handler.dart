import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/services/notifications/notification_handler.dart';
import 'package:tuoora/core/services/notifications/notification_payload.dart';

/// Shared scaffolding for every concrete [NotificationHandler]:
///
/// - Wait for the splash → main-shell transition to finish before pushing
///   any route (otherwise GetX silently drops the push mid-animation).
/// - Resolve the current user's role for role-gated routing.
/// - Tagged debug logging so multiple handlers don't tangle in the same
///   log stream.
///
/// Concrete subclasses override [tag] (for logs) and [onReady], which is
/// called once the app is authenticated and parked on a `/student/*` or
/// `/institute/*` route. Subclasses must NOT `await Get.toNamed(...)` —
/// that future resolves when the route is *popped*, not pushed, and
/// awaiting it makes any post-push verification fire at the wrong time.
abstract class BaseNotificationHandler implements NotificationHandler {
  static const Duration _readyTimeout = Duration(seconds: 25);
  static const Duration _pollInterval = Duration(milliseconds: 200);

  /// Extra delay after [_waitForReady] returns true. Covers the gap
  /// between "Get.currentRoute reports the new route" and "the navigator's
  /// route transition animation has finished" (~300 ms for the default
  /// material transition) so our push doesn't race the splash's
  /// `Get.offAllNamed`.
  static const Duration _postReadySettle = Duration(milliseconds: 600);

  /// Short tag used as the log prefix, e.g. `ChatNotificationHandler`.
  String get tag;

  /// Subclass-specific work. Runs only after the app is ready AND the
  /// settle delay has elapsed. [role] is uppercased — `'STUDENT'`,
  /// `'INSTITUTE'`, etc.
  Future<void> onReady(NotificationPayload payload, String role);

  @override
  Future<void> handle(NotificationPayload payload) async {
    log('handle data=${payload.data}');

    final ready = await _waitForReady();
    if (!ready) {
      log('bail: timed out waiting for ready (route=${Get.currentRoute})');
      return;
    }

    await Future.delayed(_postReadySettle);

    final role = _resolveUserRole();
    if (role == null) {
      log('bail: no auth role');
      return;
    }
    log('ready route=${Get.currentRoute} role=$role');

    try {
      await onReady(payload, role);
    } catch (e, st) {
      log('onReady threw: $e\n$st');
    }
  }

  /// Polls until [AuthService] reports authenticated AND
  /// [Get.currentRoute] is inside the student or institute namespace.
  Future<bool> _waitForReady() async {
    final start = DateTime.now();
    while (DateTime.now().difference(start) < _readyTimeout) {
      final authed = Get.isRegistered<AuthService>() &&
          Get.find<AuthService>().isAuthenticated;
      final route = Get.currentRoute;
      final navigable =
          route.startsWith('/student') ||
          route.startsWith('/institute') ||
          route.startsWith('/teacher');
      if (authed && navigable) return true;
      await Future.delayed(_pollInterval);
    }
    return false;
  }

  String? _resolveUserRole() {
    if (!Get.isRegistered<AuthService>()) return null;
    return Get.find<AuthService>().currentUser?.role.toUpperCase();
  }

  @protected
  void log(String msg) {
    if (kDebugMode) debugPrint('[$tag] $msg');
  }
}
