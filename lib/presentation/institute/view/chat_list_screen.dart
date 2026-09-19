import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/chat_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/data/models/chat_model.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatListScreen extends GetView<ChatController> {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(title: AppStrings.chats),
            Expanded(
              child: Padding(
                padding: AppSpacing.x16,
                child: Column(
                  children: [
                    AppSpacing.v16,
                    _buildSearchField(),
                    AppSpacing.v20,
                    Expanded(
                      child: Obx(() {
                        return CommonStateWidget(
                          isLoading: controller.isLoading.value,
                          isEmpty: controller.filteredChats.isEmpty,
                          emptyTitle: AppStrings.noChatsFound,
                          emptySubtitle:
                              AppStrings.startANewConversationToSee,
                          emptyIcon: Icons.chat_bubble_outline_rounded,
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 88, top: 4),
                            itemCount: controller.filteredChats.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final chat = controller.filteredChats[index];
                              return _ChatCard(
                                chat: chat,
                                onTap: () => controller.openChat(chat),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SubscriptionGuard.hideAddOnIOS
          ? null
          : FloatingActionButton(
              onPressed: () => SubscriptionGuard.runAddAction(() {
                controller.fetchParticipants();
                Get.toNamed(AppRoutes.instituteCreateChat);
              }),
              backgroundColor: SubscriptionGuard.blocksAdd
                  ? AppColors.textMuted
                  : AppColors.primaryBrand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: AppColors.white),
            ),
    );
  }

  Widget _buildSearchField() {
    return AppSearchField(
      hintText: AppStrings.searchChats,
      onChanged: (value) => controller.searchQuery.value = value,
    );
  }
}

class _ChatCard extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const _ChatCard({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCount > 0;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: hasUnread
                  ? AppColors.primaryBrand.withValues(alpha: 0.25)
                  : AppColors.background,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: AppSpacing.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(
                name: chat.participantName,
                imageUrl: chat.participantImage,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.participantName.isEmpty
                                ? 'Unknown'
                                : chat.participantName,
                            style: AppTextStyles.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          chat.lastMessageTime,
                          style: AppTextStyles.outfit(
                            fontSize: 11,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: hasUnread
                                ? AppColors.primaryBrand
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _PreviewLine(chat: chat)),
                        const SizedBox(width: 8),
                        if (hasUnread) _UnreadBadge(count: chat.unreadCount),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _Avatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
    final fallback = CircleAvatar(
      radius: 26,
      backgroundColor: AppColors.primaryBrandLight,
      child: Text(
        initial,
        style: AppTextStyles.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBrand,
        ),
      ),
    );

    final url = imageUrl?.trim();
    if (url == null || url.isEmpty || !url.startsWith('http')) {
      return fallback;
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  final Chat chat;

  const _PreviewLine({required this.chat});

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCount > 0;
    final color = hasUnread ? AppColors.textPrimary : AppColors.textSecondary;
    final weight = hasUnread ? FontWeight.w600 : FontWeight.w400;

    final iconForType = _typeIcon(chat.lastMessageType);
    final caption = chat.lastMessage.isEmpty
        ? _typeFallback(chat.lastMessageType)
        : chat.lastMessage;

    if (caption.isEmpty) {
      return Text(
        AppStrings.tapToStartChatting,
        style: AppTextStyles.outfit(
          fontSize: 13,
          color: AppColors.textTertiary,
          fontStyle: FontStyle.italic,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconForType != null) ...[
          Icon(iconForType, size: 14, color: color),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            caption,
            style: AppTextStyles.outfit(
              fontSize: 13,
              color: color,
              fontWeight: weight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData? _typeIcon(String? type) {
    switch (type) {
      case 'image':
        return Icons.image_rounded;
      case 'video':
        return Icons.videocam_rounded;
      case 'audio':
        return Icons.audiotrack_rounded;
      case 'document':
        return Icons.description_rounded;
      default:
        return null;
    }
  }

  String _typeFallback(String? type) {
    switch (type) {
      case 'image':
        return 'Photo';
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'document':
        return 'Document';
      default:
        return '';
    }
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : count.toString();
    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryBrand,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrand.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
