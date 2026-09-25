import 'package:flutter/foundation.dart';
import 'package:tuoora/data/models/user_model.dart';
import 'package:tuoora/data/models/subscription_model.dart';
import 'package:tuoora/core/services/push_notification_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  final _storage = GetStorage();
  final _currentUser = Rxn<User>();
  final _token = ''.obs;
  final _refreshToken = ''.obs;
  final _subscription = Rxn<Subscription>();

  User? get currentUser => _currentUser.value;
  String get token => _token.value;
  String get refreshToken => _refreshToken.value;
  bool get isAuthenticated => _token.isNotEmpty;

  Subscription? get subscription => _subscription.value;

  Future<AuthService> init() async {
    await GetStorage.init();
    _loadSession();
    return this;
  }

  bool get shouldStayAuthenticated =>
      _storage.read('stay_authenticated') ?? false;
  bool get isLoggedIn => _storage.read('logged_in') ?? false;

  void _loadSession() {
    try {
      final userData = _storage.read('user');
      final savedToken = _storage.read('token');
      final savedRefresh = _storage.read('refresh_token') ?? '';

      if (kDebugMode) {
        print('AuthService: Loading session. Token: $savedToken');
      }

      if (userData != null && savedToken != null) {
        _token.value = savedToken;
        _refreshToken.value = savedRefresh;
        final role = userData['role'] ?? 'INSTITUTE';
        _currentUser.value = User.fromJson(
          userData,
          savedToken,
          role,
          accessToken: savedToken,
          refreshToken: savedRefresh,
        );
        final subData = _storage.read('subscription');
        if (subData != null) {
          _subscription.value = Subscription.fromJson(
            Map<String, dynamic>.from(subData),
          );
        }
        if (kDebugMode) {
          print('AuthService: Session loaded for role: $role');
        }
      } else {
        if (kDebugMode) {
          print('AuthService: No session found.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Error loading session: $e');
      }
    }
  }

  Future<void> saveSession(
    User user, {
    bool stayAuthenticated = false,
    bool loggedIn = false,
    String? email,
    String? password,
    String? role,
  }) async {
    _currentUser.value = user;
    _token.value = user.accessToken;
    _refreshToken.value = user.refreshToken;
    await _storage.write('user', user.toJson());
    await _storage.write('token', user.accessToken);
    await _storage.write('refresh_token', user.refreshToken);
    await _storage.write('stay_authenticated', stayAuthenticated);
    await _storage.write('logged_in', loggedIn);

    final effectiveRole = role ?? user.role;
    final emailKey = _emailKey(effectiveRole);
    final passwordKey = _passwordKey(effectiveRole);
    if (stayAuthenticated) {
      await _storage.write(emailKey, email ?? user.email);
      if (password != null) {
        await _storage.write(passwordKey, password);
      } else {
        await _storage.remove(passwordKey);
      }
    } else {
      await _storage.remove(emailKey);
      await _storage.remove(passwordKey);
    }
  }

  Future<void> setSubscription(Subscription? subscription) async {
    _subscription.value = subscription;
    if (subscription == null) {
      await _storage.remove('subscription');
    } else {
      await _storage.write('subscription', subscription.toJson());
    }
  }

  String? rememberedEmailFor(String role) => _storage.read(_emailKey(role));
  String? rememberedPasswordFor(String role) =>
      _storage.read(_passwordKey(role));

  String _emailKey(String role) => 'remembered_email_${role.toUpperCase()}';
  String _passwordKey(String role) =>
      'remembered_password_${role.toUpperCase()}';

  Future<void> clearSession() async {
    _currentUser.value = null;
    _token.value = '';
    _refreshToken.value = '';
    _subscription.value = null;

    try {
      if (Get.isRegistered<PushNotificationService>()) {
        await Get.find<PushNotificationService>().deleteToken();
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Failed to delete FCM token: $e');
      }
    }

    await _storage.remove('user');
    await _storage.remove('token');
    await _storage.remove('refresh_token');
    await _storage.remove('logged_in');
    await _storage.remove('subscription');

    if (kDebugMode) {
      print(
        'AuthService: Session cleared (user and token removed). Preferences preserved.',
      );
    }
  }

  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _token.value = accessToken;
    await _storage.write('token', accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _refreshToken.value = refreshToken;
      await _storage.write('refresh_token', refreshToken);
    }
    final user = _currentUser.value;
    if (user != null) {
      final updated = user.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      _currentUser.value = updated;
      await _storage.write('user', updated.toJson());
    }
  }
}
