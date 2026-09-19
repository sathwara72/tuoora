import 'package:tuoora/core/enums/app_enums.dart';

class ResourceModel {
  final String id;
  final String subject;
  final String description;
  final String fileName;
  final ResourceType type;
  final DateTime uploadedAt;
  final String batchId;
  final String? fileUrl;
  final String? downloadUrl;
  final String? youtubeUrl;

  ResourceModel({
    required this.id,
    required this.subject,
    required this.description,
    required this.fileName,
    required this.type,
    required this.uploadedAt,
    required this.batchId,
    this.fileUrl,
    this.downloadUrl,
    this.youtubeUrl,
  });

  String get displayFileName {
    if (type == ResourceType.youtube && (youtubeUrl ?? '').isNotEmpty) {
      return youtubeUrl!;
    }
    if (fileName.isEmpty) return 'Unnamed File';

    // Get the actual file name from the path
    final nameOnly = fileName.split('/').last;

    // Remove leading timestamp pattern like "1777554757_"
    String cleanName = nameOnly.replaceFirst(RegExp(r'^\d+_'), '');

    // Convert snake_case or kebab-case to Title Case (Proper Name)
    return cleanName
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    ResourceType parseType(String type) {
      if (type.contains('image')) return ResourceType.image;
      if (type.contains('video')) return ResourceType.video;
      return ResourceType.document;
    }

    return ResourceModel(
      id: json['id'].toString(),
      subject: json['title'] ?? '',
      description: json['description'] ?? '',
      fileName: json['file_path'] ?? '',
      type:
          (json['resource_type'] == 'youtube' ||
              json['resource_type'] == 'link')
          ? ResourceType.youtube
          : parseType(json['file_type'] ?? 'document'),
      uploadedAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      batchId: json['batch_id']?.toString() ?? '',
      fileUrl: json['file_url'],
      downloadUrl: json['download_url'],
      youtubeUrl: json['link_url'] ?? json['youtube_url'],
    );
  }
}
