import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/models/student_dashboard_model.dart';
import 'package:tuoora/data/repositories/student_dashboard_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tuoora/presentation/student/models/assignment_model.dart';
import 'package:tuoora/presentation/student/models/student_timetable_model.dart';
import 'package:tuoora/presentation/student/widgets/birthday_wish_dialog.dart';
import 'package:tuoora/data/repositories/student_timetable_repository.dart';

class DashboardAssignmentDisplay {
  final Assignment assignment;
  final String title;
  final String subject;
  final String dueLabel;
  final String status;

  const DashboardAssignmentDisplay({
    required this.assignment,
    required this.title,
    required this.subject,
    required this.dueLabel,
    required this.status,
  });

  bool get isSubmitted => status.toLowerCase() == 'submitted';
}

class StudentDashboardController extends GetxController {
  static const _weekdayA = <String>[
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  final RxBool isLoading = true.obs;
  final Rxn<StudentDashboardData> dashboardData = Rxn<StudentDashboardData>();
  
  final RxList<StudentTimetableSlot> timetableSlots = <StudentTimetableSlot>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  late final StudentDashboardRepository _repository;
  late final StudentTimetableRepository _timetableRepo;

  @override
  void onInit() {
    super.onInit();
    final apiClient = Get.find<ApiClient>();
    _repository = StudentDashboardRepository(apiClient);
    _timetableRepo = StudentTimetableRepository(apiClient);
    fetchDashboard();
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  List<StudentTimetableSlot> get classesForSelectedDate {
    final dayStr = _weekdayA[selectedDate.value.weekday - 1].toLowerCase();
    final dayMap = {
      'mon': 'monday',
      'tue': 'tuesday',
      'wed': 'wednesday',
      'thu': 'thursday',
      'fri': 'friday',
      'sat': 'saturday',
      'sun': 'sunday',
    };
    final fullDayStr = dayMap[dayStr] ?? 'monday';

    final filtered = timetableSlots
        .where((s) => s.dayOfWeek.toLowerCase() == fullDayStr)
        .toList();
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      final futures = await Future.wait([
        _repository.getDashboardData(),
        _timetableRepo.getTimetable(day: 'all').catchError((_) => <StudentTimetableSlot>[]),
      ]);
      final data = futures[0] as StudentDashboardData;
      timetableSlots.assignAll(futures[1] as List<StudentTimetableSlot>);
      dashboardData.value = data;

      _checkAndShowBirthdayWish(data);
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToLoadDashboardData);
    } finally {
      isLoading.value = false;
    }
  }

  void _checkAndShowBirthdayWish(StudentDashboardData data) {
    if (!data.isBirthdayToday) return;

    final box = GetStorage();
    final lastShownDate = box.read<String>('last_birthday_wish_date');
    final todayStr = DateTime.now().toIso8601String().split('T').first;

    if (lastShownDate != todayStr) {
      box.write('last_birthday_wish_date', todayStr);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        BirthdayWishDialog.show(name: data.studentName.split(' ').first);
      });
    }
  }

  String get studentFirstName {
    final name = dashboardData.value?.studentName ?? '';
    return name;
  }

  String get studentInitials {
    final name = dashboardData.value?.studentName ?? '';
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'AS';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  List<DashboardAssignmentDisplay> get dashboardAssignments {
    final items = dashboardData.value?.todayAssignments ?? const [];
    return items
        .take(2)
        .map(
          (a) => DashboardAssignmentDisplay(
            assignment: a,
            title: a.title,
            subject: a.subjectLabel,
            dueLabel: a.dueLabel,
            status: a.badge == AssignmentBadge.done ? 'Submitted' : 'Pending',
          ),
        )
        .toList();
  }

  int get pendingAssignmentsCount {
    final items = dashboardData.value?.todayAssignments ?? const [];
    return items.where((a) => a.badge != AssignmentBadge.done).length;
  }
}
