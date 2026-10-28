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
  final selectedAudienceFilter = 'ALL'.obs; // 'ALL', 'Parents & Students', 'Teachers & Staff', 'Institute / Admin'
  final selectedTemplateRule = Rxn<NotificationPreferenceModule>();

  int get totalCount => modules.length;

  int get parentsStudentsCount =>
      modules.where((m) => m.audience == 'Parents & Students').length;

  int get teachersStaffCount =>
      modules.where((m) => m.audience == 'Teachers & Staff').length;

  int get instituteAdminCount =>
      modules.where((m) => m.audience == 'Institute / Admin').length;

  int get activeRulesCount =>
      modules.where((m) => m.isAnyChannelActive).length;

  List<NotificationPreferenceModule> get filteredModules {
    if (selectedAudienceFilter.value == 'ALL') return modules;
    return modules
        .where((m) => m.audience == selectedAudienceFilter.value)
        .toList();
  }

  Map<String, List<NotificationPreferenceModule>> get groupedFilteredModules {
    final map = <String, List<NotificationPreferenceModule>>{};
    for (final m in filteredModules) {
      map.putIfAbsent(m.category, () => []).add(m);
    }
    return map;
  }

  @override
  void onInit() {
    super.onInit();
    fetchPreferences();
  }

  Future<void> fetchPreferences() async {
    try {
      isLoading.value = true;
      final result = await _repository.getNotificationPreferences();
      // The server returns only the messages that are actually built (and
      // is the only place automatic messages are configured), so show
      // exactly its list. Templates come from the local defaults.
      modules.assignAll(result.isNotEmpty ? result : _fallbackRules());
    } catch (_) {
      if (modules.isEmpty) modules.assignAll(_fallbackRules());
    } finally {
      isLoading.value = false;
    }
  }

  /// Messages whose sending isn't built yet; hidden like the server does.
  static const _notBuilt = {
    'fee_promise',
    'attendance_late',
    'attendance_summary',
    'attendance_teacher_reminder',
    'exam_marks_pending',
    'admin_daily_digest',
    'admin_lead_alert',
    'admin_subscription',
  };

  /// Messages whose WhatsApp starts OFF until the owner ticks it.
  static const _whatsappOptIn = {
    'payment_receipt',
    'homework_new',
    'exam_schedule',
    'class_schedule_change',
    'birthday_wishes',
    'salary_slip',
    'teacher_timetable',
    'staff_announcements',
  };

  /// Used only when the server can't be reached.
  List<NotificationPreferenceModule> _fallbackRules() => NotificationPreferenceModule
      .defaultRules
      .where((r) => !_notBuilt.contains(r.module))
      .map(
        (r) => _whatsappOptIn.contains(r.module)
            ? r.copyWith(whatsappEnabled: false)
            : r,
      )
      .toList();

  void setFilter(String filter) {
    selectedAudienceFilter.value = filter;
  }

  void toggleMaster(String moduleKey, bool val) {
    final index = modules.indexWhere((m) => m.module == moduleKey);
    if (index != -1) {
      final item = modules[index];
      // If toggled on and no channel was active, activate all channels by default
      final activateChannels = val && (!item.whatsappEnabled && !item.pushEnabled && !item.emailEnabled);
      modules[index] = item.copyWith(
        isEnabled: val,
        whatsappEnabled: activateChannels ? true : (val ? item.whatsappEnabled : false),
        pushEnabled: activateChannels ? true : (val ? item.pushEnabled : false),
        emailEnabled: activateChannels ? true : (val ? item.emailEnabled : false),
      );
    }
  }

  void toggleWhatsapp(String moduleKey, bool val) {
    final index = modules.indexWhere((m) => m.module == moduleKey);
    if (index != -1) {
      final item = modules[index];
      modules[index] = item.copyWith(
        whatsappEnabled: val,
        isEnabled: val ? true : (item.pushEnabled || item.emailEnabled),
      );
    }
  }

  void togglePush(String moduleKey, bool val) {
    final index = modules.indexWhere((m) => m.module == moduleKey);
    if (index != -1) {
      final item = modules[index];
      modules[index] = item.copyWith(
        pushEnabled: val,
        isEnabled: val ? true : (item.whatsappEnabled || item.emailEnabled),
      );
    }
  }

  void toggleEmail(String moduleKey, bool val) {
    final index = modules.indexWhere((m) => m.module == moduleKey);
    if (index != -1) {
      final item = modules[index];
      modules[index] = item.copyWith(
        emailEnabled: val,
        isEnabled: val ? true : (item.whatsappEnabled || item.pushEnabled),
      );
    }
  }

  bool isCategoryAllEnabled(String category) {
    final catModules = modules.where((m) => m.category == category).toList();
    if (catModules.isEmpty) return false;
    return catModules.every((m) => m.isEnabled);
  }

  void toggleCategory(String category, bool val) {
    final updated = modules.map((m) {
      if (m.category == category) {
        return m.copyWith(
          isEnabled: val,
          whatsappEnabled: val,
          pushEnabled: val,
          emailEnabled: val,
        );
      }
      return m;
    }).toList();
    modules.assignAll(updated);
  }

  void enableAll() {
    final updated = modules.map((m) {
      return m.copyWith(
        isEnabled: true,
        whatsappEnabled: true,
        pushEnabled: true,
        emailEnabled: true,
      );
    }).toList();
    modules.assignAll(updated);
    AppSnackBar.success('All notification rules enabled');
  }

  void disableAll() {
    final updated = modules.map((m) {
      return m.copyWith(
        isEnabled: false,
        whatsappEnabled: false,
        pushEnabled: false,
        emailEnabled: false,
      );
    }).toList();
    modules.assignAll(updated);
    AppSnackBar.info('All notification rules disabled');
  }

  Future<void> savePreferences() async {
    try {
      isSaving.value = true;
      final payload = modules.map((m) => m.toJson()).toList();
      final updated = await _repository.updateNotificationPreferences(payload);
      if (updated.isNotEmpty) {
        // Keep updated states
        final merged = <NotificationPreferenceModule>[];
        for (final def in modules) {
          final foundIndex = updated.indexWhere((r) => r.module == def.module);
          if (foundIndex != -1) {
            final serverRule = updated[foundIndex];
            merged.add(def.copyWith(
              isEnabled: serverRule.isEnabled,
              whatsappEnabled: serverRule.whatsappEnabled,
              pushEnabled: serverRule.pushEnabled,
              emailEnabled: serverRule.emailEnabled,
            ));
          } else {
            merged.add(def);
          }
        }
        modules.assignAll(merged);
      }
      AppSnackBar.success('Notification preferences updated successfully');
    } catch (e) {
      AppSnackBar.error('Failed to save preferences. Please try again.');
    } finally {
      isSaving.value = false;
    }
  }
}
