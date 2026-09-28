import 'package:get/get.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/models/notification_preference_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';

class NotificationPreferencesController extends GetxController {
  final InstituteRepositoryImpl _repository;

  NotificationPreferencesController(this._repository);

  final isLoading = false.obs;
  final isSaving = false.obs;
  final modules = <NotificationPreferenceModule>[].obs;

  int get activeCount => modules
      .where((m) => m.whatsappEnabled || m.pushEnabled || m.emailEnabled)
      .length;

  @override
  void onInit() {
    super.onInit();
    fetchPreferences();
  }

  Future<void> fetchPreferences() async {
    try {
      isLoading.value = true;
      final result = await _repository.getNotificationPreferences();
      if (result.isNotEmpty) {
        modules.assignAll(result);
      } else {
        modules.assignAll(_defaultModules);
      }
    } catch (_) {
      if (modules.isEmpty) {
        modules.assignAll(_defaultModules);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void toggleWhatsapp(int index, bool val) {
    if (index >= 0 && index < modules.length) {
      modules[index] = modules[index].copyWith(whatsappEnabled: val);
    }
  }

  void togglePush(int index, bool val) {
    if (index >= 0 && index < modules.length) {
      modules[index] = modules[index].copyWith(pushEnabled: val);
    }
  }

  void toggleEmail(int index, bool val) {
    if (index >= 0 && index < modules.length) {
      modules[index] = modules[index].copyWith(emailEnabled: val);
    }
  }

  Future<void> savePreferences() async {
    try {
      isSaving.value = true;
      final payload = modules.map((m) => m.toJson()).toList();
      final updated = await _repository.updateNotificationPreferences(payload);
      if (updated.isNotEmpty) {
        modules.assignAll(updated);
      }
      AppSnackBar.success('Notification preferences updated successfully');
    } catch (e) {
      AppSnackBar.error('Failed to save preferences. Please try again.');
    } finally {
      isSaving.value = false;
    }
  }

  static final List<NotificationPreferenceModule> _defaultModules = [
    NotificationPreferenceModule(
      module: 'fee_reminder',
      name: 'Fee Payment Reminders',
      desc: 'Auto-dispatched before / on due date or via manual reminder button',
      icon: '💰',
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
    ),
    NotificationPreferenceModule(
      module: 'payment_receipt',
      name: 'Fee Payment Receipts',
      desc:
          'Immediate receipt notification when installment or payment is logged',
      icon: '📄',
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
    ),
    NotificationPreferenceModule(
      module: 'attendance_absent',
      name: 'Attendance Absent Alerts',
      desc: 'Immediate alert to parents when student is marked absent',
      icon: '📋',
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
    ),
    NotificationPreferenceModule(
      module: 'exam_results',
      name: 'Exam Results & Marks',
      desc: 'Score card & percentage notifications when test is scored',
      icon: '📝',
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
    ),
    NotificationPreferenceModule(
      module: 'broadcast_announcement',
      name: 'General Notices & Broadcasts',
      desc: 'Holiday, schedule changes, and mass campus circulars',
      icon: '📢',
      whatsappEnabled: true,
      pushEnabled: true,
      emailEnabled: true,
    ),
  ];
}
