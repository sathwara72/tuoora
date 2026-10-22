import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/toggle_switch.dart';
import 'package:tuoora/data/models/whatsapp_settings_model.dart';
import 'package:tuoora/presentation/institute/controllers/whatsapp_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class InstituteWhatsAppScreen extends GetView<WhatsAppController> {
  const InstituteWhatsAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const InstituteAppBar(
                  title: 'WhatsApp Management',
                  isRoot: false,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.fetchOverview(),
                    color: AppColors.instBrandOrange,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModeBanner(),
                          AppSpacing.v16,
                          _buildWalletCard(),
                          AppSpacing.v20,
                          _buildPacksSection(),
                          AppSpacing.v20,
                          _buildSendTestCard(),
                          AppSpacing.v20,
                          _buildRecentLogsSection(),
                          AppSpacing.v20,
                          _buildDedicatedMetaSection(),
                          AppSpacing.v20,
                          _buildAutomatedAlertsSection(),
                          AppSpacing.v32,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => controller.isLoading.value
                  ? Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: const CommonLoading(color: AppColors.white),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Active Mode Banner (Tuoora Gateway vs Dedicated School WhatsApp)
  // ---------------------------------------------------------------------------
  Widget _buildModeBanner() {
    return Obx(() {
      final isDedicated = controller.hasDedicatedWhatsApp.value;
      final modeTitle = isDedicated
          ? 'Dedicated School WhatsApp Active'
          : 'Automated WhatsApp Messaging Active';
      final modeBadge = isDedicated ? 'Direct Meta Billing' : 'Tuoora Official Gateway';
      final modeDesc = isDedicated
          ? 'All reminders & receipts are sent from your school\'s registered Meta WhatsApp number.'
          : 'Reminders & receipts are delivered via Tuoora\'s Meta-verified official number using wallet credits.';

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDedicated ? AppColors.violetSoft : AppColors.successBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDedicated ? AppColors.violet.withValues(alpha: 0.2) : AppColors.successGreen.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDedicated ? AppColors.violet : AppColors.successGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          modeTitle,
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isDedicated ? AppColors.violet.withValues(alpha: 0.15) : AppColors.successGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          modeBadge,
                          style: AppTextStyles.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isDedicated ? AppColors.violet : AppColors.greenText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    modeDesc,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 2. Wallet Balance Card (Gradient Brand Card)
  // ---------------------------------------------------------------------------
  Widget _buildWalletCard() {
    return Obx(() {
      final isDedicated = controller.hasDedicatedWhatsApp.value;
      if (isDedicated) {
        return const SizedBox.shrink();
      }

      final balance = controller.walletBalance.value;
      final isLow = controller.isLowBalance.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6600), Color(0xFFF59E0B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6600).withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'WHATSAPP WALLET',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isLow ? 'LOW CREDITS' : 'ACTIVE',
                    style: AppTextStyles.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$balance',
                  style: AppTextStyles.outfit(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Messages Left',
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            if (isLow) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Credits are low (<20). Top up now to avoid interrupted reminders.',
                        style: AppTextStyles.outfit(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 3. Message Packs Top-Up Section
  // ---------------------------------------------------------------------------
  Widget _buildPacksSection() {
    return Obx(() {
      if (controller.hasDedicatedWhatsApp.value) {
        return const SizedBox.shrink();
      }

      final packs = controller.packs;
      if (packs.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Up Message Credits',
                style: AppTextStyles.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${packs.length} Packs',
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.instBrandOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Instant recharge with automated Razorpay checkout.',
            style: AppTextStyles.outfit(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final pack = packs[index];
              return _buildPackCard(pack);
            },
          ),
        ],
      );
    });
  }

  Widget _buildPackCard(WhatsAppPackItem pack) {
    return Obx(() {
      final isBuying = controller.purchasingPackId.value == pack.id;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.fieldBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBrandLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.mark_chat_unread_rounded,
                color: AppColors.instBrandOrange,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.name,
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${pack.formattedCredits} Messages',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${pack.costPerMessage}/msg)',
                        style: AppTextStyles.outfit(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: isBuying ? null : () => controller.startPurchase(pack),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.instBrandOrange,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isBuying
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      pack.priceFormatted,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 4. Live Test Message Card
  // ---------------------------------------------------------------------------
  Widget _buildSendTestCard() {
    return Obx(() {
      if (!controller.isWhiteLabel.value) return const SizedBox.shrink();
      return _buildSendTestCardContent();
    });
  }

  Widget _buildSendTestCardContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: AppColors.successGreen,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send WhatsApp Test Message',
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Verify live API delivery to your phone',
                    style: AppTextStyles.outfit(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInputLabel('Recipient Mobile Number'),
          const SizedBox(height: 6),
          _buildTextField(
            hint: 'e.g. 9876543210',
            controller: controller.testPhoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          _buildInputLabel('Test Message (Optional)'),
          const SizedBox(height: 6),
          _buildTextField(
            hint: 'Leave empty for default greeting test...',
            controller: controller.testMessageController,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 14),
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: controller.isSendingTest.value ? null : () => controller.sendTestMessage(),
                icon: controller.isSendingTest.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 16),
                label: Text(
                  controller.isSendingTest.value ? 'Sending...' : 'Send Live Test',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Recent Delivery Logs (Card view matching web mobile UI)
  // ---------------------------------------------------------------------------
  Widget _buildRecentLogsSection() {
    return Obx(() {
      final logs = controller.recentLogs;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent WhatsApp Delivery Logs',
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Audit trail of outbound WhatsApp messages',
                      style: AppTextStyles.outfit(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${logs.length} Total',
                  style: AppTextStyles.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No WhatsApp messages sent yet.\nAutomated reminders will appear here.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length > 8 ? 8 : logs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final isSent = log.isSent;

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.fieldBorder.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                log.recipientName,
                                style: AppTextStyles.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSent ? AppColors.successBg : AppColors.errorBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isSent ? 'SENT' : 'FAILED',
                                style: AppTextStyles.outfit(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: isSent ? AppColors.successGreen : AppColors.errorRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (log.parentName != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            'Parent: ${log.parentName}',
                            style: AppTextStyles.outfit(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 5),
                        Text(
                          log.message,
                          style: AppTextStyles.outfit(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              log.metaMessageId != null && log.metaMessageId!.isNotEmpty
                                  ? 'ID: ${log.metaMessageId}'
                                  : 'No Meta ID',
                              style: AppTextStyles.outfit(
                                fontSize: 9,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            Text(
                              log.sentAt ?? '—',
                              style: AppTextStyles.outfit(
                                fontSize: 9,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 6. Dedicated School Meta Configuration (White-Label Expandable)
  // ---------------------------------------------------------------------------
  Widget _buildDedicatedMetaSection() {
    return Obx(() {
      if (!controller.isWhiteLabel.value) return const SizedBox.shrink();
      final isExpanded = controller.showDedicatedConfig.value;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.showDedicatedConfig.toggle(),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.violetSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.settings_suggest_rounded,
                        color: AppColors.violet,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dedicated School WhatsApp Settings',
                            style: AppTextStyles.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Connect your custom Meta Cloud API credentials',
                            style: AppTextStyles.outfit(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1, color: AppColors.fieldBorder),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(AppStrings.instPhoneLabel),
                    const SizedBox(height: 6),
                    _buildTextField(
                      hint: '919876543210 (with country code)',
                      controller: controller.phoneNumberController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel(AppStrings.instPhoneNumberId),
                    const SizedBox(height: 6),
                    _buildTextField(
                      hint: 'e.g. 104593829103948',
                      controller: controller.phoneNumberIdController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel(AppStrings.instBusinessAccountId),
                    const SizedBox(height: 6),
                    _buildTextField(
                      hint: 'e.g. 102938475619283',
                      controller: controller.businessAccountIdController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel(AppStrings.instAccessToken),
                    const SizedBox(height: 6),
                    _buildTextField(
                      hint: 'EAAG...',
                      controller: controller.accessTokenController,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enable Automated Sending',
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        ToggleSwitch(
                          value: controller.isActiveMeta.value,
                          onChanged: (val) => controller.isActiveMeta.value = val,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: controller.currentSettings.value != null
                          ? 'Save API Credentials'
                          : AppStrings.instVerifyApiBtn,
                      icon: Icons.verified_user_rounded,
                      onPressed: () => controller.saveSettings(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // 7. Automated Notification Toggles
  // ---------------------------------------------------------------------------
  Widget _buildAutomatedAlertsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notification_add_rounded,
                color: AppColors.instBrandOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.instAutomatedAlerts,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(
            () => _buildToggleItem(
              Icons.account_balance_wallet_rounded,
              AppStrings.instFeesReminders,
              AppStrings.instFeesRemindersDesc,
              controller.feesReminders.value,
              (v) => controller.feesReminders.value = v,
            ),
          ),
          const Divider(height: 16, color: AppColors.fieldBorder),
          Obx(
            () => _buildToggleItem(
              Icons.person_outline_rounded,
              AppStrings.instAttendanceAlerts,
              AppStrings.instAttendanceAlertsDesc,
              controller.attendanceAlerts.value,
              (v) => controller.attendanceAlerts.value = v,
            ),
          ),
          const Divider(height: 16, color: AppColors.fieldBorder),
          Obx(
            () => _buildToggleItem(
              Icons.auto_stories_rounded,
              AppStrings.instHomeworkUpdates,
              AppStrings.instHomeworkUpdatesDesc,
              controller.homeworkUpdates.value,
              (v) => controller.homeworkUpdates.value = v,
            ),
          ),
          const Divider(height: 16, color: AppColors.fieldBorder),
          Obx(
            () => _buildToggleItem(
              Icons.campaign_rounded,
              AppStrings.instHolidayNotices,
              AppStrings.instHolidayNoticesDesc,
              controller.holidayNotices.value,
              (v) => controller.holidayNotices.value = v,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBrandLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.instBrandOrange, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.outfit(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ToggleSwitch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.fieldLabel,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.fieldBorder.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.outfit(
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.outfit(
            fontSize: 12.5,
            color: AppColors.fieldLabel,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}