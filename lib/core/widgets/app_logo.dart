import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/services/branding_service.dart';

/// Drop-in replacement for `Image.asset(AppImages.logoWithName, height: X)`.
/// Shows the institute's white-label logo (fetched by [BrandingService]) when
/// one is available, falling back to the bundled default Tuoora logo
/// otherwise — including while the network image is still loading or if it
/// fails to load, so a flaky connection never leaves a blank space where the
/// logo should be.
class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;

  const AppLogo({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final logoUrl = Get.isRegistered<BrandingService>()
        ? Get.find<BrandingService>().logoUrl
        : null;

    if (logoUrl == null || logoUrl.isEmpty) {
      return _defaultLogo();
    }

    return CachedNetworkImage(
      imageUrl: logoUrl,
      height: height,
      width: width,
      fit: BoxFit.contain,
      placeholder: (context, url) => _defaultLogo(),
      errorWidget: (context, url, error) => _defaultLogo(),
    );
  }

  Widget _defaultLogo() {
    return Image.asset(
      AppImages.logoWithName,
      height: height,
      width: width,
    );
  }
}
