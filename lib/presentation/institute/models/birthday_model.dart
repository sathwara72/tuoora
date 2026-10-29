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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      profileImageUrl: json['profile_image_url']?.toString(),
      dob: json['dob']?.toString() ?? '',
      isBirthdayToday: json['is_birthday_today'] == true,
      batchId: int.tryParse(json['batch_id']?.toString() ?? ''),
      batchName: json['batch_name']?.toString(),
    );
  }

  DateTime? get dobDate => DateTime.tryParse(dob);

  /// The next birthday on or after today (today when [isBirthdayToday]).
  DateTime? get nextBirthday {
    final d = dobDate;
    if (d == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (isBirthdayToday) return today;
    var next = DateTime(now.year, d.month, d.day);
    if (next.isBefore(today)) next = DateTime(now.year + 1, d.month, d.day);
    return next;
  }

  /// 0 = today, 1 = tomorrow, ...
  int get daysUntil {
    final next = nextBirthday;
    if (next == null) return isBirthdayToday ? 0 : 999;
    final now = DateTime.now();
    return next.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  /// Age reached on [nextBirthday], or null without a valid date of birth.
  int? get turningAge {
    final d = dobDate;
    final next = nextBirthday;
    if (d == null || next == null) return null;
    final age = next.year - d.year;
    return age > 0 ? age : null;
  }

  /// "Today" / "Tomorrow" / "In N days".
  String get whenLabel {
    final days = daysUntil;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    return 'In $days days';
  }
}
