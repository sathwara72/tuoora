import 'dart:io' show Platform;

import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/url_constants.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/presentation/institute/models/add_on_model.dart';

/// Generic purchase flow for flag/quota kind add-ons. White Label
/// (kind=custom) is never routed through here — it keeps its own dedicated
/// [WhiteLabelController] and screen; this controller just lists it
/// alongside everything else and deep-links out to that screen instead.
class AddOnsController extends GetxController {
  final InstituteRepositoryImpl _repository;

  AddOnsController(this._repository);

  final RxList<AddOnModel> addOns = <AddOnModel>[].obs;
  final RxBool isLoading = true.obs;

  /// id of the add-on currently mid-purchase, so only that card shows a
  /// loading state — null when nothing is in flight.
  final Rxn<String> purchasingId = Rxn<String>();

  Razorpay? _razorpay;
  bool _disposed = false;
  String? _activeAddOnId;
  String? _activeOrderId;

  String? _prefillName;
  String? _prefillPhone;
  bool _prefillLoaded = false;

  @override
  void onInit() {
    super.onInit();
    fetchAddOns();

    if (Platform.isAndroid) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  Future<void> fetchAddOns() async {
    try {
      isLoading.value = true;
      final data = await _repository.getAddOns();
      addOns.assignAll(data);
    } catch (e) {
      AppSnackBar.error('Failed to load add-ons');
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

  Future<void> startPurchase(AddOnModel addOn) async {
    if (_disposed || purchasingId.value != null || _razorpay == null) return;

    _activeAddOnId = addOn.id;
    purchasingId.value = addOn.id;

    try {
      final order = await _repository.createAddOnOrder(addOn.id);
      _activeOrderId = order['order_id']?.toString();

      await _loadPrefillIfNeeded();

      final options = {
        'key': UrlConstants.razorpayKeyId,
        'amount': order['amount'],
        'currency': order['currency'] ?? 'INR',
        'order_id': order['order_id'],
        'name': 'Tuoora',
        'description': addOn.title,
        'theme': {'color': '#F97316'},
        'prefill': {
          if (_prefillName != null) 'name': _prefillName!,
          if (_prefillPhone != null) 'contact': _prefillPhone!,
        },
      };

      _razorpay?.open(options);
    } catch (e) {
      if (!_disposed) purchasingId.value = null;
      final msg = e.toString().replaceFirst('Exception: ', '');
      AppSnackBar.error(msg.isNotEmpty ? msg : AppStrings.iapPlanUnavailable);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final addOnId = _activeAddOnId;
    if (addOnId == null) return;

    try {
      await _repository.verifyAddOnPayment(
        addOnId: addOnId,
        razorpayOrderId: response.orderId ?? _activeOrderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );
      if (!_disposed) {
        AppSnackBar.success('Add-on activated!');
        await fetchAddOns();
      }
    } catch (_) {
      if (!_disposed) AppSnackBar.error(AppStrings.iapActivationFailed);
    } finally {
      if (!_disposed) purchasingId.value = null;
      _activeAddOnId = null;
      _activeOrderId = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!_disposed && response.code != Razorpay.PAYMENT_CANCELLED) {
      AppSnackBar.error(response.message ?? AppStrings.iapPurchaseFailed);
    }
    if (!_disposed) purchasingId.value = null;
    _activeAddOnId = null;
    _activeOrderId = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!_disposed) purchasingId.value = null;
  }

  @override
  void onClose() {
    _disposed = true;
    _razorpay?.clear();
    super.onClose();
  }
}
