import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/url_constants.dart';
import 'package:tuoora/core/services/branding_service.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/models/whatsapp_settings_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';

class WhatsAppController extends GetxController {
  final InstituteRepositoryImpl _repository = Get.find<InstituteRepositoryImpl>();

  Razorpay? _razorpay;
  String? _activeOrderId;
  WhatsAppPackItem? _activePack;
  bool _disposed = false;

  // Controllers
  final accessTokenController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final phoneNumberIdController = TextEditingController();
  final businessAccountIdController = TextEditingController();

  final testPhoneController = TextEditingController();
  final testMessageController = TextEditingController();

  // Observable State
  final isLoading = false.obs;
  final isPurchasing = false.obs;
  final purchasingPackId = RxnInt();
  final isSendingTest = false.obs;
  final showDedicatedConfig = false.obs;

  final overviewData = Rxn<WhatsAppOverviewData>();
  final currentSettings = Rxn<WhatsAppSettings>();

  final walletBalance = 0.obs;
  final formattedBalance = '0'.obs;
  final isLowBalance = false.obs;
  final activeMode = 'tuoora_gateway'.obs;
  final isWhiteLabel = false.obs;
  final hasDedicatedWhatsApp = false.obs;
  final isActiveMeta = true.obs;

  final packs = <WhatsAppPackItem>[].obs;
  final recentLogs = <WhatsAppLogItem>[].obs;

  // Feature alert toggles
  final feesReminders = true.obs;
  final attendanceAlerts = true.obs;
  final homeworkUpdates = false.obs;
  final holidayNotices = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
    fetchOverview();
  }

  void _initRazorpay() {
    if (Platform.isAndroid || Platform.isIOS) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  Future<void> fetchOverview() async {
    try {
      isLoading.value = true;
      final data = await _repository.getWhatsAppOverview();
      overviewData.value = data;

      walletBalance.value = data.wallet.balance;
      formattedBalance.value = data.wallet.formattedBalance;
      isLowBalance.value = data.wallet.isLow;
      activeMode.value = data.mode;
      isWhiteLabel.value = data.isWhiteLabel;
      hasDedicatedWhatsApp.value = data.hasDedicatedWhatsApp;

      packs.assignAll(data.packs);
      recentLogs.assignAll(data.recentLogs);

      if (data.settings != null) {
        currentSettings.value = data.settings;
        _preFillControllers(data.settings!);
      }
    } catch (e) {
      debugPrint('Error fetching WhatsApp overview: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _preFillControllers(WhatsAppSettings settings) {
    accessTokenController.text = settings.accessToken;
    phoneNumberController.text = settings.phoneNumber;
    phoneNumberIdController.text = settings.phoneNumberId;
    businessAccountIdController.text = settings.businessAccountId;
    isActiveMeta.value = settings.isActive;
  }

  Future<void> startPurchase(WhatsAppPackItem pack) async {
    if (_disposed || purchasingPackId.value != null) return;
    if (_razorpay == null && (Platform.isAndroid || Platform.isIOS)) {
      _initRazorpay();
    }

    purchasingPackId.value = pack.id;
    _activePack = pack;

    try {
      final order = await _repository.createWhatsAppPackOrder(pack.id);
      _activeOrderId = order['order_id']?.toString();

      final options = {
        'key': UrlConstants.razorpayKeyFromOrder(order),
        'amount': order['amount'],
        'currency': order['currency'] ?? 'INR',
        'order_id': order['order_id'],
        'name': Get.isRegistered<BrandingService>() ? Get.find<BrandingService>().appName : 'Tuoora',
        'description': pack.name,
        'theme': {'color': '#FF6600'},
      };

      _razorpay?.open(options);
    } catch (e) {
      purchasingPackId.value = null;
      _activePack = null;
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackBar.error(msg.isNotEmpty ? msg : 'Unable to initiate pack purchase');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final pack = _activePack;
    if (pack == null) return;

    try {
      isLoading.value = true;
      final result = await _repository.verifyWhatsAppPackPayment(
        razorpayOrderId: response.orderId ?? _activeOrderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      await fetchOverview();
      AppSnackBar.success(result['message']?.toString() ?? 'WhatsApp pack purchased successfully!');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackBar.error(msg.isNotEmpty ? msg : 'Payment verification failed');
    } finally {
      purchasingPackId.value = null;
      _activePack = null;
      isLoading.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    purchasingPackId.value = null;
    _activePack = null;
    AppSnackBar.error(response.message ?? 'Payment was cancelled or failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    AppSnackBar.warning('External wallet selected: ${response.walletName}');
  }

  Future<void> sendTestMessage() async {
    final phone = testPhoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      AppSnackBar.warning('Please enter a valid 10-digit mobile number');
      return;
    }

    try {
      isSendingTest.value = true;
      final res = await _repository.sendWhatsAppTestMessage(
        phone: phone,
        message: testMessageController.text.trim(),
      );

      AppSnackBar.success(res['message']?.toString() ?? 'Test WhatsApp message sent successfully!');
      testPhoneController.clear();
      testMessageController.clear();
      await fetchOverview();
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackBar.error(msg.isNotEmpty ? msg : 'Failed to send test message');
    } finally {
      isSendingTest.value = false;
    }
  }

  Future<void> saveSettings() async {
    final token = accessTokenController.text.trim();
    final phoneNumber = phoneNumberController.text.trim();
    final phoneId = phoneNumberIdController.text.trim();
    final accountId = businessAccountIdController.text.trim();

    if (token.isEmpty || phoneNumber.isEmpty || phoneId.isEmpty || accountId.isEmpty) {
      AppSnackBar.warning(AppStrings.enterAllCredentials);
      return;
    }

    if (phoneNumber.length < 10) {
      AppSnackBar.warning(AppStrings.invalidPhoneNumber);
      return;
    }

    try {
      isLoading.value = true;
      final data = {
        'phone_number': phoneNumber,
        'access_token': token,
        'phone_number_id': phoneId,
        'business_account_id': accountId,
        'is_active': isActiveMeta.value ? 1 : 0,
      };

      WhatsAppSettings savedSettings;
      if (currentSettings.value != null) {
        savedSettings = await _repository.updateWhatsAppSettings(data);
      } else {
        savedSettings = await _repository.saveWhatsAppSettings(data);
      }
      
      currentSettings.value = savedSettings;
      await fetchOverview();
      AppSnackBar.success(AppStrings.settingsSaved);
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToSaveSettings);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _disposed = true;
    _razorpay?.clear();
    accessTokenController.dispose();
    phoneNumberController.dispose();
    phoneNumberIdController.dispose();
    businessAccountIdController.dispose();
    testPhoneController.dispose();
    testMessageController.dispose();
    super.onClose();
  }
}