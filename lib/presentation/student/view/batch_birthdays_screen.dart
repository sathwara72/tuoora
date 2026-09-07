import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/app_network_image.dart';
import 'package:tuoora/presentation/student/controllers/student_birthday_controller.dart';
import 'package:tuoora/presentation/student/models/student_birthday_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

class BatchBirthdaysScreen extends GetView<StudentBirthdayController> {
  const BatchBirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const StudentAppBar(
              title: AppStrings.labelBirthdays,
              showDefaultActions: false,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: controller.loadBirthdays,
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
                          message: 'Nothing in the next 30 days for your batch.',
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

  Widget _buildCard(StudentBirthday b) {
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
            child: Text(
              b.isMe ? '${b.name} (You)' : b.name,
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (isToday)
            const Icon(Icons.cake_rounded, color: AppColors.primaryBrand, size: 20)
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
