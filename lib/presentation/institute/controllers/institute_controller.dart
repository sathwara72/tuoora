import 'package:tuoora/core/constants/app_permissions.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/utils/currency_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/data/models/student_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/student_repository_impl.dart';
import 'package:tuoora/presentation/institute/models/fee_record.dart';
import 'package:tuoora/core/services/download_service.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/widgets/pdf_viewer_popup.dart';

class InstituteController extends GetxController {
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  late PageController pageController;

  final StudentRepositoryImpl _studentRepository =
      Get.find<StudentRepositoryImpl>();
  final InstituteRepositoryImpl _instituteRepository =
      Get.find<InstituteRepositoryImpl>();
  final selectedFilter = AppStrings.instFilterAll.obs;
  final students = <Student>[].obs;
  final isLoadingStudents = false.obs;

  // Pagination & Search
  final searchQuery = ''.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final isLoadMore = false.obs;

  // Fees State
  final feeRecords = <FeeRecord>[].obs;
  final isLoadingFees = false.obs;
  final currentMonthTotal = 0.0.obs;
  final totalCollected = 0.0.obs;
  final totalPending = 0.0.obs;
  final pendingStudentsCount = 0.obs;

  /// Whether to show the Collected / Pending amounts. Hidden (title only,
  /// like the web) for sub-access users without `fees.totals`.
  final serverAllowsFeeTotals = true.obs;
  bool get canViewFeeTotals =>
      serverAllowsFeeTotals.value && Get.find<AuthService>().can(AppPermissions.feesTotals);
  final pendingStudents = <PendingFeeStudent>[].obs;
  final isLoadingPendingFees = false.obs;
  final selectedFeeTab = 'collected'.obs; // 'collected' or 'pending'
  final isSendingReminders = false.obs;
  final sendingReminderStudentIds = <int>{}.obs;
  bool isSendingReminderTo(int id) => sendingReminderStudentIds.contains(id);
  final feesCurrentPage = 1.obs;
  final feesHasMore = true.obs;

  final downloadingReceiptIds = <int>{}.obs;
  bool isDownloadingReceipt(int id) => downloadingReceiptIds.contains(id);

  /// `whatsapp` / `email` while that receipt share is being sent.
  final sharingReceiptChannel = RxnString();

  /// Sends the receipt to the student/parent on [channel] (`whatsapp` or
  /// `email`). Nothing is sent automatically on payment; only this does.
  Future<void> shareFeeReceipt(FeeRecord record, String channel) async {
    if (sharingReceiptChannel.value != null) return;
    // Prefer the payment id: the server matches payment ids first, so a fee
    // id could hit an unrelated payment with the same number.
    final id = record.transactionPaymentId ?? record.id;
    try {
      sharingReceiptChannel.value = channel;
      final message = await _instituteRepository.shareReceipt(
        id,
        channel: channel,
      );
      AppSnackBar.success(message);
    } catch (e) {
      AppSnackBar.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      sharingReceiptChannel.value = null;
    }
  }

  final isDeletingTransaction = false.obs;

  /// Deletes the payment behind [record], then reloads the fees list and the
  /// pending dues. Returns true when the transaction is gone.
  Future<bool> deleteTransaction(FeeRecord record) async {
    final paymentId = record.transactionPaymentId;
    if (paymentId == null || isDeletingTransaction.value) return false;
    try {
      isDeletingTransaction.value = true;
      final message = await _instituteRepository.deletePayment(paymentId);
      AppSnackBar.success(message);
      fetchFees(reset: true);
      fetchPendingFees();
      return true;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      isDeletingTransaction.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _setInitialIndex();
    pageController = PageController(initialPage: _currentIndex.value);
    debounce(
      searchQuery,
      (_) => fetchStudents(reset: true),
      time: const Duration(milliseconds: 500),
    );
    fetchStudents();
    fetchFees();
  }

  Future<void> fetchFees({bool reset = false}) async {
    if (reset) {
      feesCurrentPage.value = 1;
      feesHasMore.value = true;
    }

    if (isLoadingFees.value || (!feesHasMore.value && !reset)) return;

    try {
      isLoadingFees.value = true;
      final result = await _instituteRepository.listFees(
        page: feesCurrentPage.value,
      );

      if (reset) {
        feeRecords.assignAll(result.items);
      } else {
        feeRecords.addAll(result.items);
      }

      currentMonthTotal.value = result.currentMonthTotal;
      totalCollected.value = result.totalCollected;
      totalPending.value = result.totalPending;
      pendingStudentsCount.value = result.pendingStudentsCount;
      serverAllowsFeeTotals.value = result.canViewTotals;

      if (result.items.isEmpty || result.items.length < 10) {
        feesHasMore.value = false;
      } else {
        feesCurrentPage.value++;
      }
    } catch (e, st) {
      debugPrint('fetchFees failed: $e\n$st');
      AppSnackBar.error(AppStrings.errFailedLoadFees);
    } finally {
      isLoadingFees.value = false;
    }
  }

  Future<void> fetchPendingFees({String? search, int? batchId}) async {
    try {
      isLoadingPendingFees.value = true;
      final result = await _instituteRepository.getPendingFees(
        search: search,
        batchId: batchId,
      );
      pendingStudents.assignAll(result.items);
      totalPending.value = result.totalPending;
      pendingStudentsCount.value = result.pendingStudentsCount;
      serverAllowsFeeTotals.value = result.canViewTotals;
    } catch (e, st) {
      debugPrint('fetchPendingFees failed: $e\n$st');
      AppSnackBar.error('Failed to load pending fees');
    } finally {
      isLoadingPendingFees.value = false;
    }
  }

  Future<void> sendFeeReminderToStudent(
    int studentId,
    String studentName,
  ) async {
    if (sendingReminderStudentIds.contains(studentId)) return;
    try {
      sendingReminderStudentIds.add(studentId);
      final res = await _instituteRepository.sendFeeReminders(
        studentId: studentId,
      );
      AppSnackBar.success(res['message']?.toString() ?? 'Reminder sent to ');
    } catch (e) {
      AppSnackBar.error('Failed to send reminder');
    } finally {
      sendingReminderStudentIds.remove(studentId);
    }
  }

  Future<void> sendFeeReminderToAll({int? batchId}) async {
    if (pendingStudents.isEmpty) {
      AppSnackBar.info('No students with pending fees found');
      return;
    }
    try {
      isSendingReminders.value = true;
      final res = await _instituteRepository.sendFeeReminders(batchId: batchId);
      AppSnackBar.success(
        res['message']?.toString() ??
            'Fee reminders sent successfully to all pending students!',
      );
      await fetchPendingFees(batchId: batchId);
    } catch (e) {
      AppSnackBar.error('Failed to send reminders');
    } finally {
      isSendingReminders.value = false;
    }
  }

  Future<void> refreshFees() async {
    if (selectedFeeTab.value == 'pending') {
      await fetchPendingFees();
    } else {
      await fetchFees(reset: true);
    }
  }

  Future<void> downloadFeeReport() async {
    final fileName = 'Fee_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await Get.find<DownloadService>().download(
      label: 'Preparing financial report…',
      fileName: fileName,
      successMessage: AppStrings.reportDownloadedSuccess,
      fetch: () => _instituteRepository.exportFees(),
    );
  }

  Future<void> downloadFeeReceipt(int feeId) async {
    if (downloadingReceiptIds.contains(feeId)) return;
    downloadingReceiptIds.add(feeId);
    downloadingReceiptIds.refresh();
    final fileName =
        'Receipt_${feeId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    try {
      final path = await Get.find<DownloadService>().download(
        label: 'Preparing receipt…',
        fileName: fileName,
        successMessage: AppStrings.receiptDownloadedSuccess,
        fetch: () => _instituteRepository.downloadFeeReceipt(feeId),
      );
      if (path != null) {
        PdfViewerPopup.show(path: path);
      }
    } finally {
      downloadingReceiptIds.remove(feeId);
      downloadingReceiptIds.refresh();
    }
  }

  /// Shares the receipt PDF through the phone's share sheet (WhatsApp,
  /// Gmail, ...), so the owner can send it from their own WhatsApp.
  Future<void> shareReceiptPdf(FeeRecord record) async {
    if (sharingReceiptChannel.value != null) return;
    try {
      sharingReceiptChannel.value = 'pdf';
      final bytes = await _instituteRepository.downloadFeeReceipt(record.id);
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(bytes),
              name: 'Receipt_${receiptNumber(record)}.pdf',
              mimeType: 'application/pdf',
            ),
          ],
          text: receiptShareText(record),
        ),
      );
    } catch (_) {
      AppSnackBar.error('Could not prepare the receipt to share');
    } finally {
      sharingReceiptChannel.value = null;
    }
  }

  /// Opens a WhatsApp chat with the student (WhatsApp number, else phone)
  /// with the receipt details typed in. With no number, WhatsApp asks which
  /// chat to send it to.
  Future<void> openReceiptOnWhatsApp(FeeRecord record) async {
    final student = record.student;
    var digits = (student?.whatsappPhone ?? student?.phone ?? '').replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (digits.length == 10) digits = '91$digits';
    final text = Uri.encodeComponent(receiptShareText(record));
    final uri = Uri.parse(
      digits.isEmpty
          ? 'https://wa.me/?text=$text'
          : 'https://wa.me/$digits?text=$text',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) AppSnackBar.warning('WhatsApp is not installed on this device.');
    } catch (_) {
      AppSnackBar.warning('WhatsApp is not installed on this device.');
    }
  }

  String receiptNumber(FeeRecord r) => 'REC-${r.id.toString().padLeft(4, '0')}';

  String receiptShareText(FeeRecord r) {
    String institute = '';
    if (Get.isRegistered<AuthService>()) {
      institute = Get.find<AuthService>().currentUser?.instituteName ?? '';
    }
    return [
      'Fee Receipt ${receiptNumber(r)}',
      if (r.student != null) 'Student: ${r.student!.name}',
      'Amount Paid: ${formatRupees(r.transactionAmount)}',
      'Paid Date: ${DateFormat('dd MMM yyyy').format(r.transactionPaidAt)}',
      'Method: ${r.transactionMethod}',
      '',
      'Thank you${institute.isNotEmpty ? ',\n$institute' : '.'}',
    ].join('\n');
  }

  int _studentsRequestId = 0;

  Future<void> fetchStudents({bool reset = false}) async {
    if (reset) {
      currentPage.value = 1;
      hasMore.value = true;
    }

    if (!reset &&
        (isLoadingStudents.value || isLoadMore.value || !hasMore.value)) {
      return;
    }

    final requestId = ++_studentsRequestId;
    try {
      if (reset || students.isEmpty) {
        isLoadingStudents.value = true;
      } else {
        isLoadMore.value = true;
      }

      final result = await _studentRepository.listStudents(
        search: searchQuery.value,
        page: currentPage.value,
      );

      // A newer search or refresh has replaced the list; drop this response.
      if (requestId != _studentsRequestId) return;

      if (reset) {
        students.assignAll(result);
      } else {
        // Page offsets shift when students are added, so skip rows already shown.
        final loadedIds = students.map((s) => s.id).toSet();
        students.addAll(result.where((s) => loadedIds.add(s.id)));
      }

      if (result.isEmpty || result.length < 10) {
        hasMore.value = false;
      } else {
        currentPage.value++;
      }
    } catch (e) {
      if (requestId == _studentsRequestId) {
        AppSnackBar.error(AppStrings.failedToLoadStudents);
      }
    } finally {
      if (requestId == _studentsRequestId) {
        isLoadingStudents.value = false;
        isLoadMore.value = false;
      }
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void loadMoreStudents() {
    if (hasMore.value && !isLoadingStudents.value && !isLoadMore.value) {
      fetchStudents();
    }
  }

  void _setInitialIndex() {
    final route = Get.currentRoute;
    if (route == AppRoutes.instituteStudents) {
      _currentIndex.value = 1;
    } else if (route == AppRoutes.instituteBatches) {
      _currentIndex.value = 2;
    } else if (route == AppRoutes.instituteFees) {
      _currentIndex.value = 3;
    } else if (route == AppRoutes.instituteProfile) {
      _currentIndex.value = 4;
    } else {
      _currentIndex.value = 0;
    }
  }

  void changePage(int index) {
    if (_currentIndex.value == index) return;

    _currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void setIndex(int index) {
    _currentIndex.value = index;
    if (pageController.hasClients) {
      pageController.jumpToPage(index);
    }
  }

  void addStudent(Student student) {
    students.insert(0, student);
    students.refresh();
  }

  void updateStudent(Student student) {
    final index = students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      students[index] = student;
      students.refresh();
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
