import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';

class StudentBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  const StudentBottomNav({super.key, required this.currentIndex, this.onTap});

  static const _items = <_NavItem>[
    _NavItem(
      icon: Icons.home_rounded,
      label: 'Home',
      route: AppRoutes.studentDashboard,
    ),
    _NavItem(
      icon: Icons.assignment_outlined,
      label: 'Tasks',
      route: AppRoutes.studentHomework,
    ),
    _NavItem(
      icon: Icons.currency_rupee_rounded,
      label: 'Fees',
      route: AppRoutes.studentFeeHistory,
    ),
    _NavItem(
      icon: Icons.calendar_month_outlined,
      label: 'Attendance',
      route: AppRoutes.studentAttendance,
    ),
    _NavItem(
      icon: Icons.grid_view_rounded,
      label: 'More',
      route: AppRoutes.studentSettings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: AppSpacing.s64 + AppSpacing.s10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (i) => _buildNavItem(i, _items[i]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, _NavItem item) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryBrand : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (onTap != null) {
            onTap!(index);
          } else if (currentIndex != index) {
            Get.offAllNamed(item.route);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: color, size: 23),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.outfit(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isSelected ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primaryBrand,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
