import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';

final NumberFormat _inr = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

String formatInr(num value) => _inr.format(value);

/// Summary card: total spend, month and a few counts.
class ExpenseHeroCard extends StatelessWidget {
  final String title;
  final double total;
  final String monthLabel;
  final List<MapEntry<String, String>> stats;

  const ExpenseHeroCard({
    super.key,
    required this.title,
    required this.total,
    required this.monthLabel,
    this.stats = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryBrand,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              if (monthLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    monthLabel,
                    style: AppTextStyles.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatInr(total),
            style: AppTextStyles.outfit(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (int i = 0; i < stats.length; i++) ...[
                  if (i > 0)
                    Container(
                      width: 1,
                      height: 26,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats[i].value,
                        style: AppTextStyles.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        stats[i].key,
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact category card for a 3-per-row grid.
class ExpenseCategoryGridTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final String subtitle;
  final double amount;
  final VoidCallback? onTap;

  const ExpenseCategoryGridTile({
    super.key,
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 19, color: AppColors.primaryBrand),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatInr(amount),
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.outfit(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
