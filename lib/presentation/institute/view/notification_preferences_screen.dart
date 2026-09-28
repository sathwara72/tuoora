import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/data/models/notification_preference_model.dart';
import 'package:tuoora/presentation/institute/controllers/notification_preferences_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class NotificationPreferencesScreen
    extends GetView<NotificationPreferencesController> {
  const NotificationPreferencesScreen({super.key});

  /// Width of each channel column, shared by the header and every row so the
  /// switches line up exactly under their labels.
  static const double _channelWidth = 64;

  static const Color _whatsappColor = Color(0xFF10B981);
  static const Color _pushColor = Color(0xFF3B82F6);
  static const Color _emailColor = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(
              title: 'Notification Preferences',
              isRoot: false,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.modules.isEmpty) {
                  return const CommonLoading();
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchPreferences(),
                  color: AppColors.primaryBrand,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: _buildMatrixCard(),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderRow(),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.modules.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) =>
                  _buildModuleRow(controller.modules[index], index),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Obx(
              () => SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : () => controller.savePreferences(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrand,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Preferences',
                          style: AppTextStyles.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => Text(
                '${controller.activeCount} modules active',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          _channelHeader(
            label: 'WhatsApp',
            color: _whatsappColor,
            leading: SvgPicture.asset(
              AppImages.icWhatsapp,
              width: 14,
              height: 14,
            ),
          ),
          _channelHeader(
            label: 'Push',
            color: _pushColor,
            icon: Icons.smartphone_rounded,
          ),
          _channelHeader(
            label: 'Email',
            color: _emailColor,
            icon: Icons.mail_rounded,
          ),
        ],
      ),
    );
  }

  Widget _channelHeader({
    required String label,
    required Color color,
    Widget? leading,
    IconData? icon,
  }) {
    return SizedBox(
      width: _channelWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading ?? Icon(icon, size: 15, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleRow(NotificationPreferenceModule item, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      child: Row(
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.outfit(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          _channelSwitch(
            value: item.whatsappEnabled,
            color: _whatsappColor,
            onChanged: (v) => controller.toggleWhatsapp(index, v),
          ),
          _channelSwitch(
            value: item.pushEnabled,
            color: _pushColor,
            onChanged: (v) => controller.togglePush(index, v),
          ),
          _channelSwitch(
            value: item.emailEnabled,
            color: _emailColor,
            onChanged: (v) => controller.toggleEmail(index, v),
          ),
        ],
      ),
    );
  }

  Widget _channelSwitch({
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      width: _channelWidth,
      child: Center(
        child: Transform.scale(
          scale: 0.85,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: color,
            activeThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE2E8F0),
            inactiveThumbColor: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
      ),
    );
  }
}
