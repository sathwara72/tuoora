import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_pages.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/widgets/dotted_background.dart';
import 'package:tuoora/core/services/app_update_service.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/services/branding_service.dart';
import 'package:tuoora/core/services/institute_account_status_handler.dart';
import 'package:tuoora/core/services/server_error_handler.dart';
import 'package:tuoora/core/services/media_cache_service.dart';
import 'package:tuoora/core/services/notifications/notification_router.dart';
import 'package:tuoora/core/services/push_notification_service.dart';
import 'package:tuoora/firebase_options.dart';
import 'package:get_storage/get_storage.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await GetStorage.init();
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    } else if (Platform.isIOS || Platform.isMacOS) {
      WebViewPlatform.instance = WebKitWebViewPlatform();
    }
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  Get.put(ApiClient());
  Get.put(MediaCacheService());
  Get.put(InstituteAccountStatusHandler());
  Get.put(ServerErrorHandler());
  Get.put(AppUpdateService());
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => BrandingService().init());
  await Get.putAsync(() => NotificationRouter().init());
  await Get.putAsync(() => PushNotificationService().init());

  runApp(const FeeEasyApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AppUpdateService.to.checkForUpdate();
  });
}

class FeeEasyApp extends StatelessWidget {
  const FeeEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appName = Get.isRegistered<BrandingService>()
        ? Get.find<BrandingService>().appName
        : AppStrings.appName;
    return GetMaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      builder: (context, child) {
        return DottedBackground(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
