import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/birthday_controller.dart';

/// Compact "today's birthdays" banner for the institute dashboard —
/// mirrors [SubscriptionBanner]'s pattern of collapsing to nothing when
/// there's nothing to show, so it doesn't take up dead space most days.
class TodaysBirthdayCard extends StatelessWidget {
  const TodaysBirthdayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BirthdayController>();

    return Obx(() {
      final today = controller.today;
      if (today.isEmpty) return const SizedBox.shrink();

      final names = today.map((b) => b.name.split(' ').first).toList();
      final summary = names.length <= 2
          ? names.join(' & ')
          : '${names.take(2).join(', ')} +${names.length - 2} more';

      return GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.instituteBirthdays),
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s16,
            AppSpacing.s16,
            0,
          ),
          padding: AppSpacing.all16,
          decoration: BoxDecoration(
            color: AppColors.primaryBrandLight,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.primaryBrand.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: AppSpacing.all8,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.s8),
                ),
                child: const Icon(
                  Icons.cake_rounded,
                  color: AppColors.primaryBrand,
                  size: AppSpacing.s20,
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      today.length == 1
                          ? "Today's Birthday 🎉"
                          : "Today's Birthdays 🎉",
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                    AppSpacing.v4,
                    Text(
                      summary,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryBrand,
              ),
            ],
          ),
        ),
      );
    });
  }
}
