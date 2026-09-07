import 'package:flutter_dotenv/flutter_dotenv.dart';

class UrlConstants {
  static const String urlPrivacyPolicy = 'https://tuoora.com/privacy-policy';
  static const String urlTermsConditions =
      'https://tuoora.com/terms-conditions';
  static const String urlHelpSupport = 'https://tuoora.com/faq';
  static const String urlInstituteSubscription =
      'https://tuoora.com/institute/subscription';
  static const String urlInstituteWhiteLabel =
      'https://tuoora.com/institute/plans';

  /// Razorpay Key ID loaded from .env — never hard-code this value.
  static String get razorpayKeyId =>
      dotenv.env['RAZORPAY_KEY_ID'] ?? '';

  /// Root domain — used to resolve server-relative URLs like /admin/storage/...
  static const String baseOrigin = 'https://tuoora.com';

  /// Converts a server-relative path (e.g. /admin/storage/img.jpg) to a full
  /// URL. Absolute URLs (http/https) are returned unchanged.
  static String resolveUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$baseOrigin$path';
  }
}
