/// Kind determines how a purchased add-on behaves. `flag`/`quota` are
/// handled generically by [AddOnsScreen] + the generic purchase endpoints.
/// `custom` (e.g. White Label) deep-links to its own dedicated screen —
/// this model still carries its pricing/listing, just not its purchase flow.
enum AddOnKind { flag, quota, custom }

AddOnKind _parseKind(String? raw) {
  switch (raw) {
    case 'quota':
      return AddOnKind.quota;
    case 'custom':
      return AddOnKind.custom;
    default:
      return AddOnKind.flag;
  }
}

class AddOnModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String formattedPrice;
  final String billingType;
  final bool enabled;
  final List<String> features;
  final AddOnKind kind;
  final bool purchased;

  const AddOnModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.formattedPrice,
    required this.billingType,
    required this.enabled,
    required this.features,
    required this.kind,
    required this.purchased,
  });

  factory AddOnModel.fromJson(Map<String, dynamic> json) {
    return AddOnModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse('${json['price']}') ?? 0,
      formattedPrice: json['formatted_price'] ?? '',
      billingType: json['billing_type'] ?? 'One Time',
      enabled: json['enabled'] ?? false,
      features: (json['features'] as List?)?.map((f) => f.toString()).toList() ?? [],
      kind: _parseKind(json['kind']),
      purchased: json['purchased'] ?? false,
    );
  }
}
