import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories/student_id_card_repository.dart';
import 'package:tuoora/presentation/student/models/student_id_card_model.dart';

class StudentIdCardController extends GetxController {
  final Rxn<StudentIdCard> idCard = Rxn<StudentIdCard>();
  final RxBool isLoading = true.obs;
  final RxBool isCapturing = false.obs;

  /// The card widget wraps itself in a RepaintBoundary keyed with this, so
  /// share/download can capture exactly what's on screen as a PNG.
  final GlobalKey cardBoundaryKey = GlobalKey();

  late StudentIdCardRepository _repository;

  @override
  void onInit() {
    super.onInit();
    _repository = StudentIdCardRepository(Get.find<ApiClient>());
    loadIdCard();
  }

  Future<void> loadIdCard() async {
    try {
      isLoading.value = true;
      idCard.value = await _repository.getIdCard();
    } catch (e) {
      AppSnackBar.error('Failed to load ID card');
    } finally {
      isLoading.value = false;
    }
  }

  Future<Uint8List?> _captureCard() async {
    final boundary =
        cardBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> shareIdCard() async {
    if (isCapturing.value) return;
    try {
      isCapturing.value = true;
      final bytes = await _captureCard();
      if (bytes == null) {
        AppSnackBar.error('Could not prepare ID card for sharing');
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, name: 'id_card.png', mimeType: 'image/png')],
          text: 'My Tuoora Student ID Card',
        ),
      );
    } catch (e) {
      AppSnackBar.error('Failed to share ID card');
    } finally {
      isCapturing.value = false;
    }
  }

  Future<void> downloadIdCard() async {
    if (isCapturing.value) return;
    try {
      isCapturing.value = true;
      final bytes = await _captureCard();
      if (bytes == null) {
        AppSnackBar.error('Could not prepare ID card for download');
        return;
      }
      await Gal.putImageBytes(bytes, name: 'tuoora_id_card');
      AppSnackBar.success('ID card saved to your gallery');
    } catch (e) {
      AppSnackBar.error('Failed to save ID card. Check photo library permission.');
    } finally {
      isCapturing.value = false;
    }
  }
}
