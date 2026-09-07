import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/app_network_image.dart';
import 'package:tuoora/presentation/institute/controllers/birthday_controller.dart';
import 'package:tuoora/presentation/institute/models/birthday_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class BirthdaysScreen extends GetView<BirthdayController> {
  const BirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(
              title: AppStrings.labelBirthdays,
              isRoot: false,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: controller.fetchBirthdays,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBrand,
                      ),
                    );
                  }

                  if (controller.birthdays.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        AppEmptyView(
                          icon: Icons.cake_outlined,
                          title: 'No upcoming birthdays',
                          message: 'Nothing in the next 30 days.',
                        ),
                      ],
                    );
                  }

                  final today = controller.today;
                  final upcoming = controller.upcoming;

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.x16.add(AppSpacing.y16),
                    children: [
                      if (today.isNotEmpty) ...[
                        _sectionHeader('Today 🎉'),
                        AppSpacing.v8,
                        ...today.map(_buildCard),
                        AppSpacing.v20,
                      ],
                      if (upcoming.isNotEmpty) ...[
                        _sectionHeader('Upcoming'),
                        AppSpacing.v8,
                        ...upcoming.map(_buildCard),
                      ],
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Text(
      label,
      style: AppTextStyles.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildCard(BirthdayModel b) {
    final isToday = b.isBirthdayToday;
    String dateLabel = '';
    try {
      dateLabel = DateFormat('d MMM').format(DateTime.parse(b.dob));
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: AppSpacing.all12,
      decoration: BoxDecoration(
        color: isToday ? AppColors.primaryBrandLight : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isToday
              ? AppColors.primaryBrand.withValues(alpha: 0.3)
              : AppColors.fieldBorder,
        ),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 44,
              height: 44,
              child: (b.profileImageUrl != null && b.profileImageUrl!.isNotEmpty)
                  ? AppNetworkImage(url: b.profileImageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.primaryBrandLight,
                      child: Center(
                        child: Text(
                          b.name.isNotEmpty ? b.name[0].toUpperCase() : '?',
                          style: AppTextStyles.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBrand,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.name,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (b.batchName != null)
                  Text(
                    b.batchName!,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (isToday)
            Obx(() {
              final sending = controller.sendingWishFor.contains(b.id);
              return TextButton(
                onPressed: sending ? null : () => controller.sendWish(b),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryBrand,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.s8),
                  ),
                ),
                child: sending
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        'Send Wish',
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
              );
            })
          else
            Text(
              dateLabel,
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}
