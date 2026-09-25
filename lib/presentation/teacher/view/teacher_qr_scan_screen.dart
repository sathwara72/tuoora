import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_mark_attendance_controller.dart';

/// Full-screen QR/Barcode scanner used to mark student attendance.
/// Supports both continuous multi-student scanning (when called from TeacherMarkAttendanceScreen)
/// and single-scan return.
class TeacherQrScanScreen extends StatefulWidget {
  const TeacherQrScanScreen({super.key});

  @override
  State<TeacherQrScanScreen> createState() => _TeacherQrScanScreenState();
}

class _TeacherQrScanScreenState extends State<TeacherQrScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  bool _isProcessing = false;
  String? _lastScannedCode;
  DateTime? _lastScannedTime;
  String? _statusMessage;
  bool _isSuccess = false;
  int _scannedCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.trim().isEmpty) return;
    final trimmedValue = value.trim();

    final markController = Get.isRegistered<TeacherMarkAttendanceController>()
        ? Get.find<TeacherMarkAttendanceController>()
        : null;

    if (markController != null) {
      final now = DateTime.now();
      if (_isProcessing) return;
      if (_lastScannedCode == trimmedValue &&
          _lastScannedTime != null &&
          now.difference(_lastScannedTime!).inSeconds < 3) {
        return;
      }

      _lastScannedCode = trimmedValue;
      _lastScannedTime = now;

      setState(() {
        _isProcessing = true;
        _statusMessage = 'Checking student...';
        _isSuccess = false;
      });

      try {
        final result = await markController.markByQrDirect(trimmedValue);
        HapticFeedback.mediumImpact();
        if (mounted) {
          setState(() {
            _scannedCount++;
            _statusMessage = '✓  marked Present';
            _isSuccess = true;
          });
        }
      } catch (e) {
        HapticFeedback.heavyImpact();
        if (mounted) {
          setState(() {
            _statusMessage = e.toString().replaceFirst('Exception: ', '');
            _isSuccess = false;
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } else {
      if (_handled) return;
      _handled = true;
      Get.back(result: trimmedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markController = Get.isRegistered<TeacherMarkAttendanceController>()
        ? Get.find<TeacherMarkAttendanceController>()
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          _buildOverlay(),
          _buildTopBar(context),
          _buildBottomCard(context, markController != null),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isSuccess
                    ? const Color(0xFF10B981)
                    : (_statusMessage != null && !_isSuccess && !_isProcessing
                        ? const Color(0xFFEF4444)
                        : AppColors.primaryBrand),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Align QR or Barcode inside box',
              style: AppTextStyles.outfit(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ),
        ],
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

  Widget _buildBottomCard(BuildContext context, bool isContinuous) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_statusMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? const Color(0xFF10B981).withValues(alpha: 0.95)
                      : (_isProcessing
                          ? Colors.black87
                          : const Color(0xFFEF4444).withValues(alpha: 0.95)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isSuccess
                          ? Icons.check_circle_rounded
                          : (_isProcessing
                              ? Icons.hourglass_top_rounded
                              : Icons.error_outline_rounded),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _statusMessage!,
                        style: AppTextStyles.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isContinuous
                              ? 'Scan Student ID (QR/Barcode)'
                              : 'Point camera at Student ID',
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (isContinuous) ...[
                          const SizedBox(height: 2),
                          Text(
                            _scannedCount == 0
                                ? 'Keep scanning to mark attendance'
                                : '$_scannedCount student${_scannedCount == 1 ? '' : 's'} marked present',
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              color: _scannedCount == 0
                                  ? Colors.white70
                                  : const Color(0xFF34D399),
                              fontWeight: _scannedCount == 0
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: Text(
                      isContinuous ? 'Done' : 'Cancel',
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
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
