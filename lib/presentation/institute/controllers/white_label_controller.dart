import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/url_constants.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/models/white_label_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';

class WhiteLabelController extends GetxController {
  final InstituteRepositoryImpl _repository;

  WhiteLabelController(this._repository);

  final isLoading = true.obs;
  final isPurchasing = false.obs;
  final isSubmittingBranding = false.obs;

  final status = Rx<WhiteLabelStatus?>(null);

  final appNameController = TextEditingController();
  final logoLocalPath = Rx<String?>(null);
  final selectedPrimaryColor = Rx<String?>(null);
  final selectedSecondaryColor = Rx<String?>(null);

  Razorpay? _razorpay;
  bool _disposed = false;
  String? _activeOrderId;

  String? _prefillName;
  String? _prefillPhone;
  bool _prefillLoaded = false;

  @override
  void onInit() {
    super.onInit();
    fetchStatus();

    if (Platform.isAndroid) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  Future<void> fetchStatus() async {
    try {
      isLoading.value = true;
      final data = await _repository.getWhiteLabelStatus();
      status.value = data;
      final record = data.record;
      if (record != null) {
        appNameController.text = record.appName ?? '';
        selectedPrimaryColor.value = record.primaryColor;
        selectedSecondaryColor.value = record.secondaryColor;
      }
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadPrefillIfNeeded() async {
    if (_prefillLoaded) return;
    try {
      final profile = await _repository.getProfile();
      _prefillName = profile.name.isNotEmpty ? profile.name : null;
      _prefillPhone = profile.phone.isNotEmpty ? profile.phone : null;
      _prefillLoaded = true;
    } catch (_) {}
  }

  Future<void> startPurchase() async {
    if (_disposed || isPurchasing.value || _razorpay == null) return;

    final addon = status.value?.addon;
    isPurchasing.value = true;

    try {
      final order = await _repository.createWhiteLabelOrder();
      _activeOrderId = order['order_id']?.toString();

      await _loadPrefillIfNeeded();

      final options = {
        'key': UrlConstants.razorpayKeyId,
        'amount': order['amount'],
        'currency': order['currency'] ?? 'INR',
        'order_id': order['order_id'],
        'name': 'Tuoora',
        'description': addon?.title ?? 'Mobile App White Label',
        'theme': {'color': '#F97316'},
        'prefill': {
          if (_prefillName != null) 'name': _prefillName!,
          if (_prefillPhone != null) 'contact': _prefillPhone!,
        },
      };

      _razorpay?.open(options);
    } catch (e) {
      if (!_disposed) isPurchasing.value = false;
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackBar.error(msg.isNotEmpty ? msg : AppStrings.iapPlanUnavailable);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final record = await _repository.verifyWhiteLabelPayment(
        razorpayOrderId: response.orderId ?? _activeOrderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );
      if (!_disposed) {
        status.value = WhiteLabelStatus(
          purchased: true,
          record: record,
          addon: status.value?.addon ??
              const WhiteLabelAddon(
                title: 'Mobile App White Label',
                description: '',
                price: 0,
                formattedPrice: '',
                billingType: 'One Time',
                enabled: true,
              ),
        );
        AppSnackBar.success('White Label add-on activated! Submit your branding below.');
      }
    } catch (_) {
      if (!_disposed) AppSnackBar.error(AppStrings.iapActivationFailed);
    } finally {
      if (!_disposed) isPurchasing.value = false;
      _activeOrderId = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!_disposed && response.code != Razorpay.PAYMENT_CANCELLED) {
      AppSnackBar.error(response.message ?? AppStrings.iapPurchaseFailed);
    }
    if (!_disposed) isPurchasing.value = false;
    _activeOrderId = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!_disposed) isPurchasing.value = false;
  }

  Future<void> pickLogo() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      logoLocalPath.value = picked.path;
    } catch (e) {
      AppSnackBar.error('Could not pick image: $e');
    }
  }

  void selectPrimaryColor(String hex) => selectedPrimaryColor.value = hex;

  void selectSecondaryColor(String hex) => selectedSecondaryColor.value = hex;

  Future<void> submitBranding() async {
    final name = appNameController.text.trim();
    if (name.isEmpty) {
      AppSnackBar.error('Please enter an app display name');
      return;
    }

    try {
      isSubmittingBranding.value = true;
      final record = await _repository.submitWhiteLabelBranding(
        appName: name,
        logoPath: logoLocalPath.value,
        primaryColor: selectedPrimaryColor.value,
        secondaryColor: selectedSecondaryColor.value,
      );
      status.value = status.value == null
          ? null
          : WhiteLabelStatus(
              purchased: true,
              record: record,
              addon: status.value!.addon,
            );
      logoLocalPath.value = null;
      AppSnackBar.success('Branding submitted. Our team will confirm before publishing your app.');
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSubmittingBranding.value = false;
    }
  }

  @override
  void onClose() {
    _disposed = true;
    _razorpay?.clear();
    appNameController.dispose();
    super.onClose();
  }
}
