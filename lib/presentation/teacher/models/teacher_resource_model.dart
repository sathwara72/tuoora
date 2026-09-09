class TeacherResource {
  final int id;
  final int batchId;
  final String title;
  final String? description;
  final String? subject;
  final String? fileName;
  final String? fileUrl;
  final String? fileType;
  final String? fileSize;
  final String? createdAt;

  const TeacherResource({
    required this.id,
    required this.batchId,
    required this.title,
    this.description,
    this.subject,
    this.fileName,
    this.fileUrl,
    this.fileType,
    this.fileSize,
    this.createdAt,
  });

  bool get isPdf =>
      (fileType?.toLowerCase().contains('pdf') ?? false) ||
      (fileName?.toLowerCase().endsWith('.pdf') ?? false) ||
      (fileUrl?.toLowerCase().endsWith('.pdf') ?? false);

  bool get isImage =>
      (fileType?.toLowerCase().contains('image') ?? false) ||
      (fileName?.toLowerCase().endsWith('.jpg') ?? false) ||
      (fileName?.toLowerCase().endsWith('.jpeg') ?? false) ||
      (fileName?.toLowerCase().endsWith('.png') ?? false) ||
      (fileUrl?.toLowerCase().endsWith('.jpg') ?? false) ||
      (fileUrl?.toLowerCase().endsWith('.png') ?? false);

  bool get isVideo =>
      (fileType?.toLowerCase().contains('video') ?? false) ||
      (fileName?.toLowerCase().endsWith('.mp4') ?? false) ||
      (fileUrl?.toLowerCase().endsWith('.mp4') ?? false);

  factory TeacherResource.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, {int fallback = 0}) {
      if (val == null) return fallback;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? fallback;
    }

    return TeacherResource(
      id: parseInt(json['id']),
      batchId: parseInt(json['batch_id']),
      title: json['title']?.toString() ?? json['subject']?.toString() ?? 'Untitled Resource',
      description: json['description']?.toString(),
      subject: json['subject']?.toString(),
      fileName: json['file_name']?.toString() ??
          json['file_path']?.toString().split('/').last,
      fileUrl: json['file_url']?.toString() ?? json['file_path']?.toString() ?? json['download_url']?.toString(),
      fileType: json['file_type']?.toString() ?? json['type']?.toString() ?? 'document',
      fileSize: json['file_size']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_id': batchId,
      'title': title,
      'description': description,
      'subject': subject,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'created_at': createdAt,
    };
  }
}
