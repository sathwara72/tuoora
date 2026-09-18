class StudentResourcesResponse {
  final List<String> subjects;
  final List<StudentResourceModel> resources;

  StudentResourcesResponse({required this.subjects, required this.resources});

  factory StudentResourcesResponse.fromJson(Map<String, dynamic> json) {
    return StudentResourcesResponse(
      subjects: List<String>.from(json['subjects'] ?? []),
      resources:
          (json['resources'] as List?)
              ?.map((e) => StudentResourceModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class StudentResourceModel {
  final int id;
  final String title;
  final String description;
  final String subject;
  final String batchName;
  final String resourceType;
  final String? youtubeUrl;
  final String fileType;
  final String fileSize;
  final String fileUrl;
  final String date;
  final String downloadUrl;
  final String timeLabel;

  bool get isYoutube => resourceType == 'youtube';

  StudentResourceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.batchName,
    required this.resourceType,
    this.youtubeUrl,
    required this.fileType,
    required this.fileSize,
    required this.fileUrl,
    required this.date,
    required this.downloadUrl,
    required this.timeLabel,
  });

  factory StudentResourceModel.fromJson(Map<String, dynamic> json) {
    return StudentResourceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      batchName: json['batch_name'] ?? '',
      resourceType: json['resource_type'] ?? 'file',
      youtubeUrl: json['youtube_url'],
      fileType: json['file_type'] ?? '',
      fileSize: json['file_size'] ?? '',
      fileUrl: json['file_url'] ?? '',
      date: json['date'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      timeLabel: json['time_label'] ?? '',
    );
  }
}
