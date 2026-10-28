import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/presentation/teacher/models/teacher_notification_model.dart';

class TeacherNotificationsController extends GetxController {
  final ApiClient _apiClient;

  TeacherNotificationsController(this._apiClient);

  final notifications = <TeacherNotification>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = RxnString();
  int _page = 1;
  int _lastPage = 1;

  bool get hasMore => _page < _lastPage;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    try {
      isLoading.value = true;
      error.value = null;
      _page = 1;
      notifications.assignAll(await _load(1));
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore.value || isLoading.value) return;
    try {
      isLoadingMore.value = true;
      final items = await _load(_page + 1);
      _page++;
      notifications.addAll(items);
    } catch (_) {
      // Keep what is already shown; the next scroll retries.
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<List<TeacherNotification>> _load(int page) async {
    final response = await _apiClient.get(
      ApiConstants.teacherNotifications,
      query: {'page': page.toString()},
    );
    if (response.status.hasError) {
      final body = response.body;
      throw Exception(
        (body is Map ? body['message'] : null) ??
            'Could not load notifications',
      );
    }
    final body = response.body as Map;
    unreadCount.value =
        int.tryParse(body['unread_count']?.toString() ?? '') ?? 0;
    _lastPage = int.tryParse(body['last_page']?.toString() ?? '') ?? 1;
    final data = body['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => TeacherNotification.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<void> open(TeacherNotification n) async {
    if (!n.isRead) _markRead(n);
    if (n.isSalarySlip) {
      Get.toNamed(AppRoutes.teacherSalaries);
    } else if (n.isSchedule) {
      Get.toNamed(AppRoutes.teacherTimetable);
    }
  }

  Future<void> _markRead(TeacherNotification n) async {
    final i = notifications.indexWhere((x) => x.id == n.id);
    if (i != -1) notifications[i] = n.copyWith(isRead: true);
    if (unreadCount.value > 0) unreadCount.value--;
    try {
      await _apiClient.post(ApiConstants.teacherNotificationRead(n.id), {});
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    if (unreadCount.value == 0) return;
    try {
      final response = await _apiClient.post(
        ApiConstants.teacherNotificationsMarkAllRead,
        {},
      );
      if (response.status.hasError) {
        throw Exception('Could not mark notifications as read');
      }
      notifications.assignAll(
        notifications.map((n) => n.copyWith(isRead: true)),
      );
      unreadCount.value = 0;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
