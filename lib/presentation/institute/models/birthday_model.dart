class BirthdayModel {
  final int id;
  final String name;
  final String? profileImageUrl;
  final String dob;
  final bool isBirthdayToday;
  final int? batchId;
  final String? batchName;

  BirthdayModel({
    required this.id,
    required this.name,
    this.profileImageUrl,
    required this.dob,
    required this.isBirthdayToday,
    this.batchId,
    this.batchName,
  });

  factory BirthdayModel.fromJson(Map<String, dynamic> json) {
    return BirthdayModel(
      id: json['id'],
      name: json['name'] ?? '',
      profileImageUrl: json['profile_image_url'],
      dob: json['dob']?.toString() ?? '',
      isBirthdayToday: json['is_birthday_today'] ?? false,
      batchId: json['batch_id'],
      batchName: json['batch_name'],
    );
  }
}
