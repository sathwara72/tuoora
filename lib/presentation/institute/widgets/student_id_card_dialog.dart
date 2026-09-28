import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/constants/url_constants.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/widgets/app_network_image.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/models/student_model.dart';
import 'package:tuoora/presentation/institute/controllers/institute_profile_controller.dart';

/// The student's ID card in a popup: photo, key details and a verification QR
/// code, with download and share.
class StudentIdCardDialog extends StatefulWidget {
  final Student student;

  const StudentIdCardDialog({super.key, required this.student});

  static void show(Student student) {
    Get.dialog(
      StudentIdCardDialog(student: student),
      barrierColor: Colors.black.withValues(alpha: 0.6),
    );
  }

  @override
  State<StudentIdCardDialog> createState() => _StudentIdCardDialogState();
}

class _StudentIdCardDialogState extends State<StudentIdCardDialog> {
  final GlobalKey _boundaryKey = GlobalKey();
  String? _qrPayload;
  bool _busy = false;

  late String? _logoUrl = _resolveLogo();
  late String _instituteName = _resolveInstituteName();

  @override
  void initState() {
    super.initState();
    _loadQr();
  }

  String _resolveInstituteName() {
    if (Get.isRegistered<InstituteProfileController>()) {
      final v = Get.find<InstituteProfileController>().instituteName.value
          .trim();
      if (v.isNotEmpty) return v;
    }
    if (Get.isRegistered<AuthService>()) {
      final v = Get.find<AuthService>().currentUser?.instituteName?.trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return 'Institute';
  }

  String? _resolveLogo() {
    String? logo;
    if (Get.isRegistered<InstituteProfileController>()) {
      final c = Get.find<InstituteProfileController>();
      logo = c.profile.value?.logoUrl ?? c.profileImagePath.value;
    }
    if ((logo == null || logo.isEmpty) && Get.isRegistered<AuthService>()) {
      logo = Get.find<AuthService>().currentUser?.logo;
    }
    if (logo == null || logo.isEmpty || !_isRemote(logo)) return null;
    return UrlConstants.resolveUrl(logo);
  }

  /// Local picks (a photo just chosen on this phone) can't be shown here.
  bool _isRemote(String v) => v.startsWith('http') || v.startsWith('/');

  /// Uses the server's payload so scans verify; falls back to the same shape
  /// built locally if the request fails.
  Future<void> _loadQr() async {
    String? payload;
    try {
      final res = await Get.find<ApiClient>().get(
        '${ApiConstants.instituteStudents}/${widget.student.id}/id-card',
      );
      if (!res.hasError) {
        final data = res.body?['data'];
        payload = data?['qr_payload']?.toString();

        // The server knows the institute's logo and name for sure.
        final inst = data?['institute'];
        if (inst is Map) {
          final logo = (inst['logo_url'] ?? inst['logo'])?.toString();
          final name = inst['institute_name']?.toString().trim();
          if (mounted) {
            setState(() {
              if (logo != null && logo.isNotEmpty && _isRemote(logo)) {
                _logoUrl = UrlConstants.resolveUrl(logo);
              }
              if (name != null && name.isNotEmpty) _instituteName = name;
            });
          }
        }
      }
    } catch (_) {}

    payload ??= jsonEncode({
      'type': 'student_id_verification',
      'hash': widget.student.idHash,
      'name': widget.student.name,
      'institute': _instituteName,
    });

    if (mounted) setState(() => _qrPayload = payload);
  }

  Future<Uint8List?> _capture() async {
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        AppSnackBar.error('Could not prepare the ID card');
        return;
      }
      await Gal.putImageBytes(
        bytes,
        name: 'id_card_${widget.student.enrollmentId}',
      );
      AppSnackBar.success('ID card saved to your gallery');
    } catch (_) {
      AppSnackBar.error('Failed to save ID card. Check photo library permission.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        AppSnackBar.error('Could not prepare the ID card');
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(bytes, name: 'id_card.png', mimeType: 'image/png'),
          ],
          text: '${widget.student.name} - ID Card',
        ),
      );
    } catch (_) {
      AppSnackBar.error('Failed to share ID card');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 20),
                  ),
                ),
              ),
              RepaintBoundary(key: _boundaryKey, child: _buildCard()),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _download,
                      icon: _busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download_rounded, size: 18),
                      label: Text(_busy ? 'Preparing...' : 'Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _share,
                      icon: const Icon(Icons.ios_share_rounded, size: 18),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final s = widget.student;
    final rows = <(String, String)>[
      ('ID No', s.enrollmentId),
      if (s.dob.trim().isNotEmpty) ('DOB', s.dob),
      if (s.phone.trim().isNotEmpty) ('Phone', s.phone),
      if (s.email.trim().isNotEmpty) ('Email', s.email),
      if ((s.guardianName ?? '').trim().isNotEmpty) ('Parent', s.guardianName!),
      if (s.fullAddress.isNotEmpty) ('Address', s.fullAddress),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            const SizedBox(height: 16),
            _avatar(s),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                s.name.isEmpty ? '—' : s.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.outfit(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (s.currentBatchName != 'Not Assigned') ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrandLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  s.currentBatchName,
                  style: AppTextStyles.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBrand,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            for (int i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.fieldBorder),
              _row(rows[i].$1, rows[i].$2),
            ],
            const SizedBox(height: 16),
            _qr(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      color: AppColors.primaryBrand,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        children: [
          if (_logoUrl case final logo?) ...[
            ClipOval(
              child: SizedBox(
                width: 38,
                height: 38,
                child: AppNetworkImage(url: logo, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            _instituteName.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            AppStrings.studentIdentityCard,
            style: AppTextStyles.outfit(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(Student s) {
    final url = s.imageUrl;
    final hasPhoto =
        url.isNotEmpty && url.startsWith('http') && !url.contains('ui-avatars.com');
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryBrand, width: 3),
      ),
      child: ClipOval(
        child: hasPhoto
            ? AppNetworkImage(url: url, fit: BoxFit.cover)
            : Container(
                color: AppColors.primaryBrandLight,
                alignment: Alignment.center,
                child: Text(
                  s.name.trim().isEmpty ? '?' : s.name.trim()[0].toUpperCase(),
                  style: AppTextStyles.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBrand,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.fieldLabel,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qr() {
    final payload = _qrPayload;
    return Column(
      children: [
        Container(
          width: 156,
          height: 156,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: payload == null
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : QrImageView(
                  data: payload,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.textPrimary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          'Scan to verify',
          style: AppTextStyles.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}
