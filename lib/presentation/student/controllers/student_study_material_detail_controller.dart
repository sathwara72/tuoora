import 'package:get/get.dart';
import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/presentation/student/models/assignment_model.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/data/models/student_resource_model.dart';
import 'package:tuoora/presentation/student/controllers/attachment_preview_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentStudyMaterialDetailController extends GetxController {
  late final StudentResourceModel material;
  late final List<AssignmentAttachment> attachments;

  bool get isYoutube => material.isYoutube;

  @override
  void onInit() {
    super.onInit();
    material = Get.arguments as StudentResourceModel;

    // Convert the single file into an AssignmentAttachment so we can reuse the tile.
    // YouTube-link resources don't have a downloadable file, so they skip this
    // entirely and are rendered/opened separately (see openYoutube()).
    attachments = isYoutube
        ? []
        : [
            AssignmentAttachment(
              id: material.id.toString(),
              name: material.fileUrl.split('/').last,
              sizeLabel: material.fileSize,
              kind: _getKind(material.fileType),
              url: material.fileUrl,
            ),
          ];
  }

  Future<void> openYoutube() async {
    final url = material.youtubeUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppSnackBar.error('Could not open YouTube link');
    }
  }

  AssignmentAttachmentKind _getKind(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('video')) return AssignmentAttachmentKind.video;
    if (lowerType.contains('image')) return AssignmentAttachmentKind.image;
    if (lowerType.contains('audio')) return AssignmentAttachmentKind.audio;
    return AssignmentAttachmentKind.document;
  }

  void openAttachment(AssignmentAttachment attachment) {
    Get.toNamed(
      AppRoutes.studentAttachmentPreview,
      arguments: AttachmentPreviewArgs(
        attachment: attachment,
        sourceType: AttachmentSourceType.resource,
        sourceId: material.id.toString(),
      ),
    );
  }
}
