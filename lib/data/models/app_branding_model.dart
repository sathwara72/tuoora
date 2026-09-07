class AppBranding {
  final bool whiteLabeled;
  final String? appName;
  final String? logoUrl;
  final String? primaryColor;
  final String? secondaryColor;

  const AppBranding({
    this.whiteLabeled = false,
    this.appName,
    this.logoUrl,
    this.primaryColor,
    this.secondaryColor,
  });

  static const AppBranding none = AppBranding();

  factory AppBranding.fromJson(Map<String, dynamic> json) {
    return AppBranding(
      whiteLabeled: json['white_labeled'] ?? false,
      appName: json['app_name'],
      logoUrl: json['logo_url'],
      primaryColor: json['primary_color'],
      secondaryColor: json['secondary_color'],
    );
  }

  Map<String, dynamic> toJson() => {
    'white_labeled': whiteLabeled,
    'app_name': appName,
    'logo_url': logoUrl,
    'primary_color': primaryColor,
    'secondary_color': secondaryColor,
  };
}
