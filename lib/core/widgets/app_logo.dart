import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/services/branding_service.dart';

/// Drop-in replacement for `Image.asset(AppImages.logoWithName, height: X)`.
/// White-label builds ship their logo as a bundled asset
/// (`assets/branding/logo.png`, copied in by tool/build_white_label.sh), so it
/// renders instantly with no network fetch. The default Tuoora build — and any
/// white-label build whose asset is missing — uses the bundled Tuoora logo.
class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  static bool get _useBrandLogo => BrandingService.instituteId > 0;

  @override
  Widget build(BuildContext context) {
    final px = MediaQuery.devicePixelRatioOf(context);
    return Image(
      image: _provider(px, height, _useBrandLogo),
      height: height,
      width: width,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) => Image(
        image: _provider(px, height, false),
        height: height,
        width: width,
        fit: fit,
      ),
    );
  }

  /// Decodes at display size rather than the asset's full resolution. Shares
  /// its [ResizeImage] key with [precache] so a precached logo is a cache hit.
  static ImageProvider _provider(
    double pixelRatio,
    double? height,
    bool brand,
  ) {
    final asset = AssetImage(
      brand ? AppImages.brandLogo : AppImages.logoWithName,
    );
    if (height == null) return asset;
    return ResizeImage(asset, height: (height * pixelRatio).round());
  }

  /// Warm the image cache for the logo sizes used on splash/auth screens.
  static Future<void> precache(BuildContext context) async {
    final px = MediaQuery.devicePixelRatioOf(context);
    await Future.wait([
      for (final h in const [64.0, 56.0, 48.0])
        precacheImage(
          _provider(px, h, _useBrandLogo),
          context,
        ).catchError((_) {}),
    ]);
  }
}
