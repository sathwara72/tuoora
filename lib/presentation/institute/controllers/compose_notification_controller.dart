import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories/institute_repository.dart';
import 'package:tuoora/data/models/batch_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ComposeNotificationController extends GetxController {
  final InstituteRepository _repository;
  ComposeNotificationController(this._repository);

  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;

  final titleController = TextEditingController();
  final messageController = TextEditingController();

  final RxList<Batch> batches = <Batch>[].obs;
  final Rxn<int> selectedBatchId = Rxn<int>();

  final RxString selectedTarget = 'all_students'.obs;
  
  final RxBool sendPush = true.obs;
  final RxBool sendWhatsApp = false.obs;

  final Map<String, String> targetOptions = {
    'all_students': 'All Students',
    'all_parents': 'All Parents',
    'all_staff': 'All Staff',
    'batch_students': 'Batch Students',
    'batch_parents': 'Batch Parents',
  };

  @override
  void onInit() {
    super.onInit();
    fetchBatches();
  }

  Future<void> fetchBatches() async {
    try {
      isLoading.value = true;
      final response = await _repository.listBatches(page: 1);
      batches.assignAll(response.items);
    } catch (e) {
      debugPrint('Error fetching batches: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendNotification() async {
    final title = titleController.text.trim();
    final message = messageController.text.trim();
    final target = selectedTarget.value;

    if (title.isEmpty) {
      AppSnackBar.error('Please enter a title');
      return;
    }
    if (message.isEmpty) {
      AppSnackBar.error('Please enter a message');
      return;
    }
    if ((target == 'batch_students' || target == 'batch_parents') && selectedBatchId.value == null) {
      AppSnackBar.error('Please select a batch');
      return;
    }

    if (!sendPush.value && !sendWhatsApp.value) {
      AppSnackBar.error('Please select at least one sending method (Push or WhatsApp)');
      return;
    }

    try {
      isSending.value = true;
      
      if (sendPush.value) {
        final apiClient = Get.find<ApiClient>();
        final response = await apiClient.post(
          '/institute/notifications/send-push',
          {
            'title': title,
            'message': message,
            'target_type': target,
            'type': 'general',
            if (selectedBatchId.value != null) 'batch_id': selectedBatchId.value,
          },
        );

        if (response.status.hasError) {
          throw Exception(response.body?['message'] ?? 'Failed to send push notification');
        }
      }

      if (sendWhatsApp.value) {
        // Mobile side WhatsApp integration for sending via url launcher
        final url = Uri.parse("whatsapp://send?text=${Uri.encodeComponent('$title\n\n$message')}");
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          AppSnackBar.warning('WhatsApp is not installed on this device.');
        }
      }

      AppSnackBar.success('Notification sent successfully');
      Get.back(result: true); // Go back and refresh list
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
