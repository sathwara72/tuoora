class UrlConstants {
  static const String urlPrivacyPolicy = 'https://tuoora.com/privacy-policy';
  static const String urlTermsConditions =
      'https://tuoora.com/terms-conditions';
  static const String urlHelpSupport = 'https://tuoora.com/faq';
  static const String urlInstituteSubscription =
      'https://tuoora.com/institute/subscription';
  static const String urlInstituteWhiteLabel =
      'https://tuoora.com/institute/plans';

  /// Razorpay Key ID returned by the server's create-order API. Checkout must
  /// use the same key the order was created with (test vs live), so never
  /// fall back to a locally bundled key.
  static String razorpayKeyFromOrder(Map<String, dynamic> order) {
    final key = (order['razorpay_key'] ?? order['key'])?.toString() ?? '';
    if (key.isEmpty) {
      throw Exception('Payment gateway is not configured. Please contact support.');
    }
    return key;
  }

  /// Root domain — used to resolve server-relative URLs like /admin/storage/...
  static const String baseOrigin = 'https://tuoora.com';

  /// Converts a server-relative path (e.g. /admin/storage/img.jpg) to a full
  /// URL. Absolute URLs (http/https) are returned unchanged.
  static String resolveUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$baseOrigin$path';
  }
}
