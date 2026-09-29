import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// One API call kept for the "recent requests" section of a bug report.
class ApiLogEntry {
  final DateTime time;
  final String method;
  final String path;
  final int status;
  final String? message;

  ApiLogEntry({
    required this.time,
    required this.method,
    required this.path,
    required this.status,
    this.message,
  });

  @override
  String toString() {
    final base = '${time.toIso8601String()}  $method $path -> $status';
    return message == null || message!.isEmpty ? base : '$base  ($message)';
  }
}

/// Keeps a short in-memory trail of API calls (no tokens, no request bodies)
/// and turns it into an email to support when the server misbehaves.
class BugReportService extends GetxService {
  static BugReportService get to => Get.find<BugReportService>();

  static const String supportEmail = 'support@tuoora.com';
  static const int _maxEntries = 20;
  static const int _maxBodyChars = 3500;

  final List<ApiLogEntry> _entries = [];
  ApiLogEntry? _lastError;
  String? _errorRoute;

  ApiLogEntry? get lastError => _lastError;

  void record({
    required String method,
    required Uri url,
    required int status,
    String? message,
    bool isError = false,
  }) {
    // Path only: query strings can carry personal data.
    final entry = ApiLogEntry(
      time: DateTime.now(),
      method: method.toUpperCase(),
      path: url.path,
      status: status,
      message: message == null
          ? null
          : (message.length > 200 ? '${message.substring(0, 200)}…' : message),
    );
    _entries.add(entry);
    if (_entries.length > _maxEntries) _entries.removeAt(0);
    if (isError) _lastError = entry;
  }

  void markErrorScreen(String? route) => _errorRoute = route;

  Future<String> buildReport() async {
    final buffer = StringBuffer()
      ..writeln('Tuoora app error report')
      ..writeln('Time: ${DateTime.now().toIso8601String()}');

    try {
      final info = await PackageInfo.fromPlatform();
      buffer.writeln('App: ${info.appName} ${info.version} (${info.buildNumber})');
    } catch (_) {}

    try {
      final device = DeviceInfoPlugin();
      if (kIsWeb) {
        buffer.writeln('Platform: web');
      } else if (Platform.isAndroid) {
        final a = await device.androidInfo;
        buffer.writeln(
          'Device: Android ${a.version.release} (SDK ${a.version.sdkInt}), ${a.manufacturer} ${a.model}',
        );
      } else if (Platform.isIOS) {
        final i = await device.iosInfo;
        buffer.writeln('Device: iOS ${i.systemVersion}, ${i.utsname.machine}');
      }
    } catch (_) {}

    if (Get.isRegistered<AuthService>()) {
      final user = Get.find<AuthService>().currentUser;
      if (user != null) {
        buffer.writeln('User: ${user.role} #${user.id} ${user.email}');
      }
    }

    if (_errorRoute != null) buffer.writeln('Screen: $_errorRoute');

    final err = _lastError;
    if (err != null) {
      buffer
        ..writeln()
        ..writeln('Failed request: ${err.method} ${err.path}')
        ..writeln('Status: ${err.status}');
      if (err.message != null && err.message!.isNotEmpty) {
        buffer.writeln('Server said: ${err.message}');
      }
    }

    buffer
      ..writeln()
      ..writeln('Recent requests (newest last):');
    for (final e in _entries) {
      buffer.writeln('  $e');
    }

    final text = buffer.toString();
    return text.length > _maxBodyChars ? text.substring(0, _maxBodyChars) : text;
  }

  /// Opens the mail app with a ready-to-send report addressed to support.
  Future<bool> emailSupport() async {
    final body = await buildReport();
    final uri = Uri.parse(
      'mailto:$supportEmail'
      '?subject=${Uri.encodeComponent('Tuoora app error report')}'
      '&body=${Uri.encodeComponent(body)}',
    );
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
