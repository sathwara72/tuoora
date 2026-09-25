import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/toggle_switch.dart';
import 'package:tuoora/presentation/institute/controllers/compose_notification_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/data/models/batch_model.dart';

class ComposeNotificationScreen extends GetView<ComposeNotificationController> {
  const ComposeNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const InstituteAppBar(
                  title: 'Compose Notification',
                  isRoot: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPaddingTop,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send Broadcast',
                          style: AppTextStyles.outfit(
                            fontSize: AppSpacing.s28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        AppSpacing.v8,
                        Text(
                          'Notify students, parents, or staff instantly via Push Notifications or WhatsApp.',
                          style: AppTextStyles.outfit(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.blueSapphire,
                          ),
                        ),
                        AppSpacing.v32,
                        _buildTargetSelection(),
                        AppSpacing.v24,
                        _buildBatchSelection(),
                        AppSpacing.v24,
                        _buildMessageForm(),
                        AppSpacing.v32,
                        _buildSendingOptions(),
                        AppSpacing.v48,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildBottomBar(),
            Obx(
              () => controller.isSending.value
                  ? Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const CommonLoading(color: AppColors.white),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT AUDIENCE',
          style: AppTextStyles.outfit(
            fontSize: AppSpacing.s12,
            fontWeight: FontWeight.w600,
            color: AppColors.fieldLabel,
            letterSpacing: 0.5,
          ),
        ),
        AppSpacing.v12,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.fieldBorder, width: 1.0),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: controller.selectedTarget.value,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                ),
                items: controller.targetOptions.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedTarget.value = val;
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchSelection() {
    return Obx(() {
      final target = controller.selectedTarget.value;
      if (target != 'batch_students' && target != 'batch_parents') {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'SELECT BATCH',
                style: AppTextStyles.outfit(
                  fontSize: AppSpacing.s12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fieldLabel,
                  letterSpacing: 0.5,
                ),
              ),
              if (controller.isLoading.value) ...[
                AppSpacing.h8,
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryBrand,
                  ),
                ),
              ],
            ],
          ),
          AppSpacing.v12,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.fieldBorder, width: 1.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                isExpanded: true,
                value: controller.selectedBatchId.value,
                hint: Text(
                  'Choose a batch',
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                ),
                items: controller.batches.map((batch) {
                  return DropdownMenuItem<int?>(
                    value: batch.id,
                    child: Text(
                      batch.name,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  controller.selectedBatchId.value = val;
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMessageForm() {
    return Container(
      padding: AppSpacing.all20,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInputField(
            label: 'NOTIFICATION TITLE *',
            controller: controller.titleController,
            hint: 'e.g. Holiday Notice',
          ),
          AppSpacing.v20,
          Text(
            'MESSAGE *',
            style: AppTextStyles.outfit(
              fontSize: AppSpacing.s12,
              fontWeight: FontWeight.w600,
              color: AppColors.fieldLabel,
              letterSpacing: 0.5,
            ),
          ),
          AppSpacing.v8,
          Container(
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(AppSpacing.s12),
              border: Border.all(color: AppColors.fieldBorder, width: 1.0),
            ),
            child: TextField(
              controller: controller.messageController,
              maxLines: 5,
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                hintStyle: AppTextStyles.outfit(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                contentPadding: AppSpacing.all16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.send_to_mobile_rounded,
              color: AppColors.primaryBrand,
              size: AppSpacing.s24,
            ),
            AppSpacing.h12,
            Text(
              'Sending Options',
              style: AppTextStyles.outfit(
                fontSize: AppSpacing.s20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        AppSpacing.v24,
        Container(
          padding: AppSpacing.y8,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.s24),
            border: Border.all(color: AppColors.background),
          ),
          child: Column(
            children: [
              Obx(
                () => _buildToggleItem(
                  Icons.notifications_active_rounded,
                  'App Push Notification',
                  'Send via Tuoora App',
                  controller.sendPush.value,
                  (v) => controller.sendPush.value = v,
                ),
              ),
              const Divider(
                height: AppSpacing.s2,
                indent: AppSpacing.s88,
                color: AppColors.background,
              ),
              Obx(
                () => _buildToggleItem(
                  Icons.message_rounded,
                  'WhatsApp',
                  'Send via WhatsApp app',
                  controller.sendWhatsApp.value,
                  (v) => controller.sendWhatsApp.value = v,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: AppSpacing.all20,
      child: Row(
        children: [
          Container(
            padding: AppSpacing.all12,
            decoration: BoxDecoration(
              color: AppColors.primaryBrandLight,
              borderRadius: BorderRadius.circular(AppSpacing.s14),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBrand,
              size: AppSpacing.s24,
            ),
          ),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.outfit(
                    fontSize: AppSpacing.s16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.outfit(
                    fontSize: AppSpacing.s12,
                    color: AppColors.blueSapphire,
                  ),
                ),
              ],
            ),
          ),
          ToggleSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: AppSpacing.screenPaddingTop.copyWith(top: 16, bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Send Notification',
                onPressed: controller.sendNotification,
                icon: Icons.send_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
