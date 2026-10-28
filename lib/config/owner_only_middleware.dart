import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/services/auth_service.dart';

/// Keeps sub-access users out of owner-only screens (Profile, Access Share,
/// Subscription and the other account settings), however they are reached.
class OwnerOnlyMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthService>()) return null;
    if (!Get.find<AuthService>().isSubAccess) return null;
    return const RouteSettings(name: AppRoutes.instituteDashboard);
  }
}
