import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/data/models/notification_preference_model.dart';
import 'package:tuoora/presentation/institute/controllers/notification_preferences_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class NotificationPreferencesScreen
    extends GetView<NotificationPreferencesController> {
  const NotificationPreferencesScreen({super.key});

  static const Color _whatsappColor = Color(0xFF10B981);
  static const Color _pushColor = Color(0xFF2563EB);
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
                  onRefresh: controller.fetchPreferences,
                  color: AppColors.primaryBrand,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTopBanner(context),
                        const SizedBox(height: 16),
                        _buildAudienceFilterTabs(),
                        const SizedBox(height: 12),
                        _buildRulesCountText(),
                        const SizedBox(height: 16),
                        _buildGroupedRulesList(context),
                      ],
                    ),
                  ),
                );
              }),
            ),
            _buildBottomSaveBar(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Banner (Matching Web Header)
  // ---------------------------------------------------------------------------
  Widget _buildTopBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primaryBrand,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Preferences',
                      style: AppTextStyles.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage automated notification delivery rules across WhatsApp, Push, and Email',
                      style: AppTextStyles.outfit(
                        fontSize: 12.5,
                        color: AppColors.textTertiary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Actions: Message Templates & Previews, Enable All, Disable All
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _openTemplatesPreviewSheet(context),
                icon: const Icon(Icons.mark_email_read_outlined, size: 16),
                label: const Text('Message Templates & Previews →'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrand,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: AppTextStyles.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: controller.enableAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  backgroundColor: AppColors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: AppTextStyles.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Enable All'),
              ),
              OutlinedButton(
                onPressed: controller.disableAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.bohoRed,
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                  backgroundColor: const Color(0xFFFFF1F2),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: AppTextStyles.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Disable All'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Audience Filter Chips (Matching Web Tabs)
  // ---------------------------------------------------------------------------
  Widget _buildAudienceFilterTabs() {
    return Obx(() {
      final currentFilter = controller.selectedAudienceFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All Alerts',
              count: controller.totalCount,
              isSelected: currentFilter == 'ALL',
              onTap: () => controller.setFilter('ALL'),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'For Parents & Students',
              count: controller.parentsStudentsCount,
              isSelected: currentFilter == 'Parents & Students',
              onTap: () => controller.setFilter('Parents & Students'),
              badgeBg: const Color(0xFFDCFCE7),
              badgeColor: const Color(0xFF15803D),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'For Teachers & Staff',
              count: controller.teachersStaffCount,
              isSelected: currentFilter == 'Teachers & Staff',
              onTap: () => controller.setFilter('Teachers & Staff'),
              badgeBg: const Color(0xFFDBEAFE),
              badgeColor: const Color(0xFF1D4ED8),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'For Institute / Admin',
              count: controller.instituteAdminCount,
              isSelected: currentFilter == 'Institute / Admin',
              onTap: () => controller.setFilter('Institute / Admin'),
              badgeBg: const Color(0xFFFEF3C7),
              badgeColor: const Color(0xFFB45309),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    Color? badgeBg,
    Color? badgeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.white : const Color(0xFF334155),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : (badgeBg ?? const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.white
                      : (badgeColor ?? const Color(0xFF475569)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesCountText() {
    return Obx(() {
      final filtered = controller.filteredModules.length;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing all $filtered notification rules',
            style: AppTextStyles.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            '${controller.activeRulesCount} of ${controller.totalCount} active',
            style: AppTextStyles.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.successGreen,
            ),
          ),
        ],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Grouped Rules List by Category (FEES, ATTENDANCE, etc.)
  // ---------------------------------------------------------------------------
  Widget _buildGroupedRulesList(BuildContext context) {
    return Obx(() {
      final grouped = controller.groupedFilteredModules;
      if (grouped.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          alignment: Alignment.center,
          child: Column(
            children: [
              const Icon(Icons.notifications_off_outlined,
                  size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              Text(
                'No notification rules match the selected filter.',
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: grouped.entries.map((entry) {
          final category = entry.key;
          final items = entry.value;
          final categoryDesc = items.isNotEmpty ? items.first.categoryDesc : '';
          return _buildCategorySection(context, category, categoryDesc, items);
        }).toList(),
      );
    });
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    String categoryDesc,
    List<NotificationPreferenceModule> items,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header: "FEES — Payment collection..." + "Enable All Fees"
          _buildCategoryHeader(category, categoryDesc),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          // Rules list under this category
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (ctx, index) => _buildRuleItem(context, items[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String category, String categoryDesc) {
    return Obx(() {
      final isAllEnabled = controller.isCategoryAllEnabled(category);
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$category ',
                      style: AppTextStyles.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: 0.6,
                      ),
                    ),
                    if (categoryDesc.isNotEmpty)
                      TextSpan(
                        text: '— $categoryDesc',
                        style: AppTextStyles.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // "Enable All Category" Checkbox
            InkWell(
              onTap: () => controller.toggleCategory(category, !isAllEnabled),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: isAllEnabled,
                        onChanged: (val) =>
                            controller.toggleCategory(category, val ?? false),
                        activeColor: AppColors.primaryBrand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Enable All',
                      style: AppTextStyles.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isAllEnabled
                            ? AppColors.primaryBrand
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Individual Notification Rule Card
  // ---------------------------------------------------------------------------
  Widget _buildRuleItem(BuildContext context, NotificationPreferenceModule rule) {
    final isActive = rule.isEnabled &&
        (rule.whatsappEnabled || rule.pushEnabled || rule.emailEnabled);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Checkbox, Name, Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: rule.isEnabled,
                  onChanged: (v) => controller.toggleMaster(rule.module, v ?? false),
                  activeColor: AppColors.primaryBrand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: AppTextStyles.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: rule.isEnabled
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      rule.desc,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : 'DISABLED',
                  style: AppTextStyles.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second Row: Audience Pill + Preview & Edit Button
          Row(
            children: [
              _buildAudienceBadge(rule.audience),
              const Spacer(),
              // Preview & Edit Button
              InkWell(
                onTap: () => _openSingleRulePreview(context, rule),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: Color(0xFF334155),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Preview & Edit',
                        style: AppTextStyles.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Third Row: Channels (WhatsApp, Mobile Push, Email)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChannelToggle(
                  label: 'WhatsApp',
                  iconWidget: SvgPicture.asset(
                    AppImages.icWhatsapp,
                    width: 15,
                    height: 15,
                  ),
                  value: rule.isEnabled && rule.whatsappEnabled,
                  color: _whatsappColor,
                  onChanged: (val) =>
                      controller.toggleWhatsapp(rule.module, val),
                ),
                Container(width: 1, height: 22, color: const Color(0xFFE2E8F0)),
                _buildChannelToggle(
                  label: 'Mobile Push',
                  iconWidget: const Icon(
                    Icons.notifications_active_rounded,
                    size: 15,
                    color: _pushColor,
                  ),
                  value: rule.isEnabled && rule.pushEnabled,
                  color: _pushColor,
                  onChanged: (val) =>
                      controller.togglePush(rule.module, val),
                ),
                Container(width: 1, height: 22, color: const Color(0xFFE2E8F0)),
                _buildChannelToggle(
                  label: 'Email',
                  iconWidget: const Icon(
                    Icons.mail_rounded,
                    size: 15,
                    color: _emailColor,
                  ),
                  value: rule.isEnabled && rule.emailEnabled,
                  color: _emailColor,
                  onChanged: (val) =>
                      controller.toggleEmail(rule.module, val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceBadge(String audience) {
    Color bg;
    Color fg;
    if (audience == 'Teachers & Staff') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1D4ED8);
    } else if (audience == 'Institute / Admin') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
    } else {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        audience,
        style: AppTextStyles.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildChannelToggle({
    required String label,
    required Widget iconWidget,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 6),
            iconWidget,
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 11.5,
                fontWeight: value ? FontWeight.w700 : FontWeight.w500,
                color: value ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Message Templates & Previews Bottom Sheet
  // ---------------------------------------------------------------------------
  void _openTemplatesPreviewSheet(BuildContext context) {
    if (controller.modules.isEmpty) return;
    final initialRule = controller.modules.first;
    _openSingleRulePreview(context, initialRule, canSelectRule: true);
  }

  void _openSingleRulePreview(
    BuildContext context,
    NotificationPreferenceModule rule, {
    bool canSelectRule = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TemplatePreviewSheet(
        initialRule: rule,
        canSelectRule: canSelectRule,
        allRules: controller.modules,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Sticky Save Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomSaveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: controller.isSaving.value
                ? null
                : controller.savePreferences,
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
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Save Notification Preferences',
                        style: AppTextStyles.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Interactive Template Preview Sheet (WhatsApp, Push, Email)
// -----------------------------------------------------------------------------
class _TemplatePreviewSheet extends StatefulWidget {
  final NotificationPreferenceModule initialRule;
  final bool canSelectRule;
  final List<NotificationPreferenceModule> allRules;

  const _TemplatePreviewSheet({
    required this.initialRule,
    required this.canSelectRule,
    required this.allRules,
  });

  @override
  State<_TemplatePreviewSheet> createState() => _TemplatePreviewSheetState();
}

class _TemplatePreviewSheetState extends State<_TemplatePreviewSheet> {
  late NotificationPreferenceModule _selectedRule;
  int _selectedChannelIndex = 0; // 0: WhatsApp, 1: Mobile Push, 2: Email

  @override
  void initState() {
    super.initState();
    _selectedRule = widget.initialRule;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message Templates & Preview',
                        style: AppTextStyles.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Live sample of messages delivered across channels',
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 22),
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Rule Selector (if opened from top button)
          if (widget.canSelectRule)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<NotificationPreferenceModule>(
                    value: _selectedRule,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: widget.allRules.map((r) {
                      return DropdownMenuItem<NotificationPreferenceModule>(
                        value: r,
                        child: Text(
                          r.name,
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRule = val);
                      }
                    },
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                _selectedRule.name,
                style: AppTextStyles.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),

          // Channel Tabs (WhatsApp, Push, Email)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _channelTabItem(0, 'WhatsApp', AppImages.icWhatsapp, isSvg: true),
                  _channelTabItem(1, 'Mobile Push', Icons.notifications_active_rounded),
                  _channelTabItem(2, 'Email', Icons.mail_rounded),
                ],
              ),
            ),
          ),

          // Template Preview Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildChannelPreview(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _channelTabItem(int index, String label, dynamic icon, {bool isSvg = false}) {
    final isSelected = _selectedChannelIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedChannelIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSvg)
                SvgPicture.asset(icon as String, width: 14, height: 14)
              else
                Icon(icon as IconData,
                    size: 14,
                    color: isSelected
                        ? AppColors.textPrimary
                        : const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelPreview() {
    switch (_selectedChannelIndex) {
      case 0:
        return _buildWhatsappPreview();
      case 1:
        return _buildPushPreview();
      case 2:
        return _buildEmailPreview();
      default:
        return _buildWhatsappPreview();
    }
  }

  // WhatsApp Preview
  Widget _buildWhatsappPreview() {
    final text = _selectedRule.whatsappTemplate ??
        'Dear Parent, this is an automated update regarding ${_selectedRule.name} from Tuoora.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEAE2), // WhatsApp wallpaper tone
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(AppImages.icWhatsapp, width: 18, height: 18),
              const SizedBox(width: 8),
              Text(
                'Tuoora Official Delivery',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF075E54),
                ),
              ),
              const Spacer(),
              Text(
                'Today, 10:30 AM',
                style: AppTextStyles.outfit(
                  fontSize: 10.5,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Chat bubble
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    color: const Color(0xFF1F2937),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '10:30 AM',
                        style: AppTextStyles.outfit(
                          fontSize: 10,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all_rounded,
                          size: 14, color: Color(0xFF3B82F6)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildPersonalizationTip(),
        ],
      ),
    );
  }

  // Push Notification Preview
  Widget _buildPushPreview() {
    final text = _selectedRule.pushTemplate ??
        'Alert: Update regarding ${_selectedRule.name}.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.school, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'TUOORA',
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                'now',
                style: AppTextStyles.outfit(
                  fontSize: 10,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _selectedRule.name,
            style: AppTextStyles.outfit(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: AppTextStyles.outfit(
              fontSize: 12.5,
              color: const Color(0xFFCBD5E1),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          _buildPersonalizationTip(isDark: true),
        ],
      ),
    );
  }

  // Email Preview
  Widget _buildEmailPreview() {
    final text = _selectedRule.emailTemplate ??
        'Subject: Notification: ${_selectedRule.name}\n\nDear Parent/Student,\nThis is an automated notification from Tuoora.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_outline_rounded,
                  size: 18, color: Color(0xFF475569)),
              const SizedBox(width: 8),
              Text(
                'Email Preview',
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          Text(
            'From: notifications@tuoora.com',
            style: AppTextStyles.outfit(
              fontSize: 11.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'To: parent@example.com',
            style: AppTextStyles.outfit(
              fontSize: 11.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const Divider(height: 16, color: Color(0xFFE2E8F0)),
          Text(
            text,
            style: AppTextStyles.outfit(
              fontSize: 12.5,
              color: const Color(0xFF1E293B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          _buildPersonalizationTip(),
        ],
      ),
    );
  }

  Widget _buildPersonalizationTip({bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Dynamic tags like {student_name}, {amount}, {date} are auto-filled during delivery.',
              style: AppTextStyles.outfit(
                fontSize: 10.5,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
