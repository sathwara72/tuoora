class ClassTeacher {
  final int id;
  final String fullName;
  final String? profileImage;

  ClassTeacher({required this.id, required this.fullName, this.profileImage});

  factory ClassTeacher.fromJson(Map<String, dynamic> json) {
    return ClassTeacher(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
    );
  }
}

class SchoolClassModel {
  final int id;
  final int batchId;
  final String name;
  final String? description;
  final String status;
  final List<ClassTeacher> teachers;

  SchoolClassModel({
    required this.id,
    required this.batchId,
    required this.name,
    this.description,
    this.status = 'active',
    this.teachers = const [],
  });

  factory SchoolClassModel.fromJson(Map<String, dynamic> json) {
    return SchoolClassModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      batchId: int.tryParse(json['batch_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'active',
      teachers: (json['teachers'] as List? ?? [])
          .map((t) => ClassTeacher.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
