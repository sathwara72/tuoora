import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/utils/url_launcher_utils.dart';

/// Opens the phone dialer for [phone]. Renders nothing when there is no
/// number, including the gap after it.
class CallIconButton extends StatelessWidget {
  final String? phone;

  const CallIconButton({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    final number = phone?.trim() ?? '';
    if (number.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: AppStrings.instCallBtn,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => UrlLauncherUtils.callPhone(number),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBrandLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.call_rounded,
              size: 18,
              color: AppColors.primaryBrand,
            ),
          ),
        ),
      ),
    );
  }
}
