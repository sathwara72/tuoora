class StudentBirthday {
  final int id;
  final String name;
  final String? profileImageUrl;
  final String dob;
  final bool isBirthdayToday;
  final bool isMe;

  StudentBirthday({
    required this.id,
    required this.name,
    this.profileImageUrl,
    required this.dob,
    required this.isBirthdayToday,
    required this.isMe,
  });

  factory StudentBirthday.fromJson(Map<String, dynamic> json) {
    return StudentBirthday(
      id: json['id'],
      name: json['name'] ?? '',
      profileImageUrl: json['profile_image_url'],
      dob: json['dob']?.toString() ?? '',
      isBirthdayToday: json['is_birthday_today'] ?? false,
      isMe: json['is_me'] ?? false,
    );
  }
}
