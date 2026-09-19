import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';

/// Full-screen QR scanner used to mark a student present by scanning
/// their digital ID card QR from `TeacherMarkAttendanceScreen`. Pops with
/// the raw scanned string as the result once a code is detected.
class TeacherQrScanScreen extends StatefulWidget {
  const TeacherQrScanScreen({super.key});

  @override
  State<TeacherQrScanScreen> createState() => _TeacherQrScanScreenState();
}

class _TeacherQrScanScreenState extends State<TeacherQrScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;
    _handled = true;
    Get.back(result: value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          _buildOverlay(),
          _buildTopBar(context),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryBrand, width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _iconButton(Icons.arrow_back_ios_new_rounded, () => Get.back()),
            const Spacer(),
            Text(
              'Scan Student ID Card',
              style: AppTextStyles.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                final torchOn = state.torchState == TorchState.on;
                return _iconButton(
                  torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  () => _controller.toggleTorch(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
