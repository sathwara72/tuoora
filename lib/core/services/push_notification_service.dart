import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/services/notifications/notification_router.dart';

/// Top-level background message handler.
/// Required by FCM — must be a top-level (or static) function so the OS can
/// spawn an isolated Dart isolate when the app is killed.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('[FCM-bg] ${message.messageId} data=${message.data}');
  }

  // If the backend sent a data-only FCM message (no top-level `notification` block),
  // Android won't display a tray notification unless we show it locally here.
  if (message.notification == null && message.data.isNotEmpty) {
    try {
      final title = (message.data['title'] ??
              message.data['heading'] ??
              message.data['subject'] ??
              '')
          .toString()
          .trim();
      final body = (message.data['body'] ??
              message.data['message'] ??
              message.data['description'] ??
              message.data['content'] ??
              '')
          .toString()
          .trim();

      if (title.isNotEmpty || body.isNotEmpty) {
        final local = FlutterLocalNotificationsPlugin();
        const androidInit = AndroidInitializationSettings('ic_notification');
        const iosInit = DarwinInitializationSettings();
        await local.initialize(const InitializationSettings(
          android: androidInit,
          iOS: iosInit,
        ));

        const channel = AndroidNotificationChannel(
          'tuoora_default_channel',
          'Tuoora Notifications',
          description: 'Default channel for Tuoora push notifications',
          importance: Importance.high,
        );
        await local
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        await local.show(
          message.hashCode,
          title.isNotEmpty ? title : 'Tuoora',
          body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'tuoora_default_channel',
              'Tuoora Notifications',
              channelDescription:
                  'Default channel for Tuoora push notifications',
              icon: 'ic_notification',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    } catch (e) {
      if (kDebugMode) print('[FCM-bg] error showing local notification: $e');
    }
  }
}

class PushNotificationService extends GetxService {
  static PushNotificationService get to => Get.find<PushNotificationService>();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final GetStorage _storage = GetStorage();

  static const String _tokenStorageKey = 'fcm_token';
  static const String _syncedTokenStorageKey = 'fcm_token_synced';

  /// Fingerprint (data-payload + title + body) of the most recent
  /// `getInitialMessage()` we've already routed. Persisted across kills.
  ///
  /// On Android, `getInitialMessage()` returns the activity's launch-intent
  /// message every cold start until a *new* notification overwrites it —
  /// the OS does NOT clear it when the user opens the app normally from
  /// the launcher. We can't rely on `messageId` either (it's sometimes
  /// null or re-wrapped). Hashing the actual payload is the only stable
  /// signal that "we've already handled this exact tap".
  static const String _consumedInitialFingerprintKey =
      'fcm_consumed_initial_fingerprint';
  static const String _androidChannelId = 'tuoora_default_channel';
  static const String _androidChannelName = 'Tuoora Notifications';
  static const String _androidChannelDesc =
      'Default channel for Tuoora push notifications';

  final RxnString _fcmToken = RxnString();
  String? get fcmToken => _fcmToken.value;

  /// Emits every incoming message (foreground, background-tap, terminated-tap).
  /// Subscribe from your controllers/screens to react (navigate, refresh, etc).
  final RxnString _lastMessageJson = RxnString();
  RxnString get onMessage => _lastMessageJson;

  Future<PushNotificationService> init() async {
    await _setupLocalNotifications();
    await _requestPermissions();
    await _configureForegroundPresentation();
    await _registerListeners();
    await _refreshToken();
    await _checkInitialMessage();
    return this;
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('ic_notification');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        _lastMessageJson.value = payload;
        // The payload we wrote earlier was the JSON-encoded data map.
        // Decode and hand it to the router so the user lands on the same
        // screen they would from a system-tray tap.
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map<String, dynamic>) {
            _routePayload(decoded);
          }
        } catch (e) {
          if (kDebugMode) print('[FCM] local-tap payload decode failed: $e');
        }
      },
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDesc,
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (kDebugMode) {
        print('[FCM] permission status: ${settings.authorizationStatus}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FCM] requestPermission skipped: $e');
      }
    }
  }

  Future<void> _configureForegroundPresentation() async {
    // iOS: show the OS banner even when the app is in the foreground.
    // We still mirror via flutter_local_notifications on Android because FCM
    // does NOT show a system notification for foreground messages.
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _registerListeners() async {
    // Token refresh — happens when the OS rotates the token.
    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken.value = newToken;
      _storage.write(_tokenStorageKey, newToken);
      if (kDebugMode) print('[FCM] token refreshed: $newToken');
      _sendTokenToServer(newToken);
    });

    // Foreground messages.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // User tapped a notification while app was in background (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
  }

  Future<void> _refreshToken() async {
    try {
      // On iOS we must wait for the APNs token before requesting the FCM token.
      if (Platform.isIOS) {
        final apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          if (kDebugMode) print('[FCM] APNs token not available yet');
        }
      }
      final token = await _fcm.getToken();
      _fcmToken.value = token;
      if (token != null) {
        await _storage.write(_tokenStorageKey, token);
        await _sendTokenToServer(token);
      }
      if (kDebugMode) print('[FCM] token: $token');
    } catch (e) {
      if (kDebugMode) print('[FCM] getToken failed: $e');
    }
  }

  /// POSTs the FCM token to the backend so push messages can be targeted at
  /// this device. No-op when the user isn't authenticated or when the token
  /// matches the last value successfully synced.
  Future<void> _sendTokenToServer(String token) async {
    if (token.isEmpty) return;

    final auth = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>()
        : null;
    if (auth == null || !auth.isAuthenticated) {
      if (kDebugMode) print('[FCM] skip sync — not authenticated');
      return;
    }

    final lastSynced = _storage.read<String>(_syncedTokenStorageKey);
    if (lastSynced == token) {
      if (kDebugMode) print('[FCM] token already synced');
      return;
    }

    try {
      final api = Get.find<ApiClient>();
      final response = await api.post(ApiConstants.fcmToken, {
        'fcm_token': token,
      });
      if (response.status.hasError) {
        if (kDebugMode) {
          print('[FCM] sync failed: ${response.statusCode} ${response.body}');
        }
        return;
      }
      await _storage.write(_syncedTokenStorageKey, token);
      if (kDebugMode) print('[FCM] token synced to server');
    } catch (e) {
      if (kDebugMode) print('[FCM] sync error: $e');
    }
  }

  /// Push the cached FCM token to the backend now. Call this right after a
  /// successful login so the server can target this device.
  Future<void> syncToken() async {
    final token = _fcmToken.value ?? await _fcm.getToken();
    if (token == null) return;
    _fcmToken.value = token;
    await _sendTokenToServer(token);
  }

  Future<void> _checkInitialMessage() async {
    // If the app was launched by tapping a notification (terminated state).
    final initial = await _fcm.getInitialMessage();
    if (initial == null) return;

    // De-duplicate by payload fingerprint, not by messageId — see comment
    // on [_consumedInitialFingerprintKey] for why.
    final fingerprint = _fingerprintOf(initial);
    final lastConsumed = _storage.read<String>(_consumedInitialFingerprintKey);
    if (kDebugMode) {
      print(
        '[FCM] initial message id=${initial.messageId} '
        'fingerprint=$fingerprint lastConsumed=$lastConsumed',
      );
    }
    if (lastConsumed == fingerprint) {
      if (kDebugMode) {
        print('[FCM] skipping cached launch-intent message');
      }
      return;
    }

    await _storage.write(_consumedInitialFingerprintKey, fingerprint);
    _onMessageOpened(initial);
  }

  /// Produces a stable fingerprint for a [RemoteMessage] from its
  /// user-visible payload. Two messages with the same data + title + body
  /// hash to the same value regardless of `messageId` (which Android can
  /// re-wrap or omit when re-handing the same cached launch intent).
  String _fingerprintOf(RemoteMessage m) {
    final parts = <String>[
      jsonEncode(m.data),
      m.notification?.title ?? '',
      m.notification?.body ?? '',
    ];
    return parts.join('|');
  }

  void _onForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('[FCM-fg] ${message.messageId} data=${message.data}');
    }
    _lastMessageJson.value = jsonEncode(message.data);

    final notification = message.notification;
    final android = message.notification?.android;
    String? title = notification?.title;
    String? body = notification?.body;

    // Fall back to data payload if notification block was omitted by backend
    if (title == null || title.isEmpty) {
      final t = message.data['title'] ??
          message.data['heading'] ??
          message.data['subject'];
      if (t != null) title = t.toString().trim();
    }
    if (body == null || body.isEmpty) {
      final b = message.data['body'] ??
          message.data['message'] ??
          message.data['description'] ??
          message.data['content'];
      if (b != null) body = b.toString().trim();
    }

    if ((title != null && title.isNotEmpty) || (body != null && body.isNotEmpty)) {
      if (Platform.isAndroid || Platform.isIOS) {
        _local.show(
          notification?.hashCode ?? message.hashCode,
          title ?? 'Tuoora',
          body ?? '',
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              channelDescription: _androidChannelDesc,
              icon: android?.smallIcon ?? 'ic_notification',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    }
  }

  void _onMessageOpened(RemoteMessage message) {
    if (kDebugMode) {
      print('[FCM-tap] ${message.messageId} data=${message.data}');
    }
    _lastMessageJson.value = jsonEncode(message.data);
    _routePayload(message.data);
  }

  /// Hands the FCM `data` map to [NotificationRouter]. Safe to call even
  /// when the router isn't registered yet (e.g. very early init) — we just
  /// drop the tap in that case.
  void _routePayload(Map<String, dynamic> data) {
    if (!Get.isRegistered<NotificationRouter>()) {
      if (kDebugMode) print('[FCM] router not ready, dropping tap');
      return;
    }
    Get.find<NotificationRouter>().route(data);
  }

  /// Subscribe to a topic (broadcast channel) — server sends to topic name.
  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) =>
      _fcm.unsubscribeFromTopic(topic);

  /// Force a fresh token (e.g. on login). Returns the new token.
  Future<String?> refreshToken() async {
    await _refreshToken();
    return fcmToken;
  }

  /// Delete the FCM registration (e.g. on logout). The next getToken() will
  /// issue a new one.
  Future<void> deleteToken() async {
    await _fcm.deleteToken();
    _fcmToken.value = null;
    await _storage.remove(_tokenStorageKey);
    await _storage.remove(_syncedTokenStorageKey);
  }

  /// Show an immediate local notification (e.g. for download completion).
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    try {
      await _local.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannelId,
            _androidChannelName,
            channelDescription: _androidChannelDesc,
            icon: 'ic_notification',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) print('[FCM] showLocalNotification error: $e');
    }
  }
}
