import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/data/repositories_impl/auth_repository_impl.dart';

class _FakeAuth extends GetxService implements AuthService {
  String _token;
  String _refresh;
  int clearCalls = 0;

  _FakeAuth(this._token, this._refresh);

  @override
  String get token => _token;
  @override
  String get refreshToken => _refresh;
  @override
  bool get isAuthenticated => _token.isNotEmpty;

  @override
  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _token = accessToken;
    if (refreshToken != null && refreshToken.isNotEmpty) _refresh = refreshToken;
  }

  @override
  Future<void> clearSession() async {
    clearCalls++;
    _token = '';
    _refresh = '';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Local backend: `/me` accepts only the fresh access token; `/auth/refresh`
/// answers with [refreshStatus].
class _Backend {
  late HttpServer server;
  int refreshStatus = 200;
  int refreshCalls = 0;
  int meCalls = 0;

  Future<void> start() async {
    server = await HttpServer.bind('127.0.0.1', 0);
    server.listen((req) async {
      final res = req.response..headers.contentType = ContentType.json;
      if (req.uri.path.endsWith('/auth/refresh')) {
        refreshCalls++;
        res.statusCode = refreshStatus;
        res.write(jsonEncode(refreshStatus == 200
            ? {
                'status': 'success',
                'data': {
                  'access_token': 'NEW_ACCESS',
                  'refresh_token': 'NEW_REFRESH',
                },
              }
            : {'status': 'error', 'message': 'nope'}));
      } else if (req.uri.path.endsWith('/me')) {
        meCalls++;
        final ok = req.headers.value('authorization') == 'Bearer NEW_ACCESS';
        res.statusCode = ok ? 200 : 401;
        res.write(jsonEncode({'status': ok ? 'success' : 'error'}));
      } else {
        res.statusCode = 404;
      }
      await res.close();
    });
  }

  String get base => 'http://127.0.0.1:${server.port}';
}

void main() {
  late _Backend backend;
  late _FakeAuth auth;
  late ApiClient client;

  Future<void> setUpClient({String refresh = 'OLD_REFRESH'}) async {
    Get.reset();
    backend = _Backend();
    await backend.start();
    auth = _FakeAuth('OLD_ACCESS', refresh);
    Get.put<AuthService>(auth);
    client = Get.put(ApiClient());
    client.httpClient.baseUrl = backend.base;
    Get.put<AuthRepositoryImpl>(AuthRepository(client));
  }

  tearDown(() async {
    await backend.server.close(force: true);
    Get.reset();
  });

  test('expired access token is refreshed and the request retried, no logout',
      () async {
    await setUpClient();

    final res = await client.get('/me');

    expect(res.statusCode, 200);
    expect(backend.refreshCalls, 1);
    expect(auth.token, 'NEW_ACCESS');
    expect(auth.refreshToken, 'NEW_REFRESH');
    expect(auth.clearCalls, 0);
  });

  test('parallel 401s share one refresh', () async {
    await setUpClient();

    final results = await Future.wait([
      client.get('/me'),
      client.get('/me'),
      client.get('/me'),
    ]);

    expect(results.every((r) => r.statusCode == 200), isTrue);
    expect(backend.refreshCalls, 1);
    expect(auth.clearCalls, 0);
  });

  test('a rejected refresh token ends the session', () async {
    await setUpClient();
    backend.refreshStatus = 401;

    await client.get('/me');

    expect(auth.clearCalls, greaterThanOrEqualTo(1));
  });

  test('a server error while refreshing keeps the session', () async {
    await setUpClient();
    backend.refreshStatus = 500;

    await client.get('/me');

    expect(auth.clearCalls, 0);
    expect(auth.refreshToken, 'OLD_REFRESH');
  });
}
