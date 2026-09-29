// Route sweep: logs in as one role and opens every route for that role,
// collecting Flutter exceptions / layout overflows. API failures are logged by
// ApiClient itself ("[API ERROR]"), so run with output captured and grep it.
//
//   flutter test integration_test/route_sweep_test.dart -d <simulator> \
//     --dart-define=SWEEP_ROLE=INSTITUTE \
//     --dart-define=SWEEP_EMAIL=... --dart-define=SWEEP_PASSWORD=...
//
// Credentials are passed on the command line only — never commit them.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tuoora/config/app_pages.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/services/push_notification_service.dart';
import 'package:tuoora/data/models/user_model.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/main.dart' as app;

const _role = String.fromEnvironment('SWEEP_ROLE');
const _email = String.fromEnvironment('SWEEP_EMAIL');
const _password = String.fromEnvironment('SWEEP_PASSWORD');
// Optional: comma-separated route chains to visit instead of every route. A
// chain 'a>b' opens a then b on top of it (like tapping through the app).
const _only = String.fromEnvironment('SWEEP_ONLY');

// Auth flows, hardware-dependent screens and payment screens: not useful (or
// not safe) to open blindly.
const _skip = [
  'signup',
  'otp',
  'forgot-password',
  'reset-password',
  'profile-setup',
  'qr-scan',
  'pay-fees',
];

void _log(String m) => debugPrint('[SWEEP] $m');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('route sweep $_role', (tester) async {
    expect(_role, isNotEmpty, reason: 'pass --dart-define=SWEEP_ROLE');

    final errors = <String>[];
    void record(String source, Object error, StackTrace? stack) {
      final head = error.toString().split('\n').take(3).join(' | ');
      final where = (stack?.toString().split('\n') ?? const <String>[])
          .where((l) => l.contains('package:tuoora'))
          .take(3)
          .join(' <- ');
      errors.add('$source: $head  @ $where');
    }

    // main() is `void main() async`, so wait for its last service instead.
    app.main();
    for (var i = 0;
        i < 120 && !Get.isRegistered<PushNotificationService>();
        i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(Get.isRegistered<PushNotificationService>(), isTrue,
        reason: 'app did not finish starting up');
    await tester.pump(const Duration(seconds: 2));

    final originalOnError = FlutterError.onError;
    final originalDispatcherOnError = PlatformDispatcher.instance.onError;
    FlutterError.onError = (d) {
      record('FlutterError', d.exception, d.stack);
      // Overflows only say "by N pixels" on the first line; the widget that
      // caused it is further down.
      if (d.exceptionAsString().contains('overflowed')) {
        _log('    [DETAIL] ${d.toDiagnosticsNode().toStringDeep().split('\n').take(24).join('\n')}');
      }
    };
    PlatformDispatcher.instance.onError = (e, st) {
      record('Async', e, st);
      return true;
    };

    try {
      // ---- log in through the real repository, same as LoginController ----
      final repo = AuthRepository(Get.find<ApiClient>());
      final User user;
      switch (_role) {
        case 'INSTITUTE':
          user = await repo.loginInstitute(
            _email,
            _password,
            device: 'route-sweep',
            os: 'ios',
          );
        case 'TEACHER':
          user = await repo.loginTeacher(_email, _password);
        case 'STUDENT':
          user = await repo.loginStudent(_email, _password);
        default:
          fail('Unknown SWEEP_ROLE $_role');
      }
      await Get.find<AuthService>().saveSession(
        user,
        loggedIn: true,
        role: _role,
      );
      _log('logged in as $_role');

      // Land on the dashboard like the real app does after login: its binding
      // registers the shared controllers/repositories other routes rely on, and
      // it becomes the root the sweep returns to.
      Get.offAllNamed(switch (_role) {
        'INSTITUTE' => AppRoutes.instituteDashboard,
        'TEACHER' => AppRoutes.teacherDashboard,
        _ => AppRoutes.studentDashboard,
      });
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      final prefix = '/${_role.toLowerCase()}/';
      final routes = _only.isNotEmpty
          ? _only.split(',')
          : AppPages.pages
                .map((p) => p.name)
                .where((n) => n.startsWith(prefix))
                .where((n) => !_skip.any(n.contains))
                .toList();
      _log('routes to visit: ${routes.length}');

      final results = <String, List<String>>{};
      for (final route in routes) {
        errors.clear();
        _log('--> $route');
        for (final step in route.split('>')) {
          try {
            unawaited(Get.toNamed(step));
          } catch (e, st) {
            record('Navigate', e, st);
          }
          for (var i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 500));
          }
        }
        results[route] = List.of(errors);
        _log('<-- $route errors=${errors.length}');
        for (final e in errors) {
          // Detail screens opened without their Get.arguments fail with a null
          // cast; that is the harness, not an app bug.
          final noArgs = e.contains("'Null' is not a subtype") ||
              e.contains('was called on null');
          _log('    ${noArgs ? '[NEEDS-ARGS] ' : ''}$e');
        }
        // Back to the root route so the next screen opens on a clean stack, and
        // drop leftover snackbars so one broken overlay can't cascade.
        Get.until((r) => r.isFirst);
        try {
          Get.closeAllSnackbars();
        } catch (_) {}
        await tester.pump(const Duration(milliseconds: 800));
      }

      final bad = results.entries.where((e) => e.value.isNotEmpty).toList();
      _log('==== SUMMARY $_role: ${routes.length} routes, '
          '${bad.length} with errors ====');
      for (final e in bad) {
        _log('${e.key}: ${e.value.length} error(s)');
      }
    } finally {
      FlutterError.onError = originalOnError;
      PlatformDispatcher.instance.onError = originalDispatcherOnError;
    }
    binding.reportData = {'role': _role};
  }, timeout: const Timeout(Duration(minutes: 30)));
}
