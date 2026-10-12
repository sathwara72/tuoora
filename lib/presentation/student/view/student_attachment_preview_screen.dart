import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/student/controllers/attachment_preview_controller.dart';
import 'package:tuoora/presentation/student/models/assignment_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

class StudentAttachmentPreviewScreen
    extends GetView<AttachmentPreviewController> {
  const StudentAttachmentPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final attachment = controller.selectedAttachment.value;
          if (attachment == null) {
            return const Center(
              child: Text(AppStrings.studentAttachmentNoneSelected),
            );
          }
          if (controller.isAttachmentLoading.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StudentAppBar(
                  title: attachment.name,
                  showDefaultActions: false,
                ),
                const Expanded(
                  child: CommonLoading(color: AppColors.primaryBrand),
                ),
              ],
            );
          }
          return _Body(attachment: attachment);
        }),
      ),
      bottomNavigationBar: Obx(() {
        final attachment = controller.selectedAttachment.value;
        if (attachment == null || controller.isAttachmentLoading.value) {
          return const SizedBox.shrink();
        }
        return const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: _ActionRow(),
        );
      }),
    );
  }
}

class _Body extends StatelessWidget {
  final AssignmentAttachment attachment;

  const _Body({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudentAppBar(title: attachment.name, showDefaultActions: false),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: _PreviewSurface(attachment: attachment),
                  ),
                ),
                const SizedBox(height: 24),
                _FileInfoCard(attachment: attachment),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewSurface extends StatelessWidget {
  final AssignmentAttachment attachment;

  const _PreviewSurface({required this.attachment});

  @override
  Widget build(BuildContext context) {
    switch (attachment.kind) {
      case AssignmentAttachmentKind.image:
        return _ImagePreview(attachment: attachment);
      case AssignmentAttachmentKind.video:
        return _VideoPreview(attachment: attachment);
      case AssignmentAttachmentKind.document:
        return _DocumentPreview(attachment: attachment);
      case AssignmentAttachmentKind.audio:
        return _AudioPreview(attachment: attachment);
    }
  }
}

class _ImagePreview extends StatelessWidget {
  final AssignmentAttachment attachment;

  const _ImagePreview({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final url = attachment.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        color: AppColors.background,
        constraints: const BoxConstraints(minHeight: 240),
        child: url != null && url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (_, _) => const _LoadingPlaceholder(),
                errorWidget: (_, _, _) =>
                    const _ErrorPlaceholder(icon: Icons.broken_image_outlined),
              )
            : const _ErrorPlaceholder(icon: Icons.image_outlined),
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  final AssignmentAttachment attachment;

  const _VideoPreview({required this.attachment});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final url = widget.attachment.url;
    if (url == null || url.isEmpty) {
      setState(() {
        _failed = true;
        _loading = false;
      });
      return;
    }
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        showOptions: false,
        placeholder: const CommonLoading(color: AppColors.white),
      );
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        constraints: const BoxConstraints(minHeight: 220),
        color: AppColors.textPrimary,
        child: _failed
            ? const _ErrorPlaceholder(icon: Icons.videocam_off_rounded)
            : (_loading || _chewieController == null)
            ? const _LoadingPlaceholder()
            : AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              ),
      ),
    );
  }
}

class _DocumentPreview extends StatefulWidget {
  final AssignmentAttachment attachment;

  const _DocumentPreview({required this.attachment});

  @override
  State<_DocumentPreview> createState() => _DocumentPreviewState();
}

class _DocumentPreviewState extends State<_DocumentPreview> {
  WebViewController? _controller;
  bool _loading = true;
  bool _failed = false;

  static const _docExtensions = [
    '.pdf',
    '.doc',
    '.docx',
    '.ppt',
    '.pptx',
    '.xls',
    '.xlsx',
  ];

  @override
  void initState() {
    super.initState();
    final url = widget.attachment.url;
    if (url == null || url.isEmpty) {
      _failed = true;
      _loading = false;
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _failed = true;
                _loading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_resolvedUrl(url)));
  }

  String _resolvedUrl(String raw) {
    final lower = raw.toLowerCase();
    if (_docExtensions.any(lower.endsWith)) {
      return 'https://docs.google.com/viewer?embedded=true&url=$raw';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || _controller == null) {
      return const _ErrorPlaceholder(icon: Icons.insert_drive_file_outlined);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        constraints: const BoxConstraints(minHeight: 320),
        color: AppColors.background,
        child: Stack(
          children: [
            Positioned.fill(child: WebViewWidget(controller: _controller!)),
            if (_loading) const _LoadingPlaceholder(),
          ],
        ),
      ),
    );
  }
}

class _AudioPreview extends StatefulWidget {
  final AssignmentAttachment attachment;

  const _AudioPreview({required this.attachment});

  @override
  State<_AudioPreview> createState() => _AudioPreviewState();
}

class _AudioPreviewState extends State<_AudioPreview> {
  VideoPlayerController? _audioController;
  ChewieController? _chewieController;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final url = widget.attachment.url;
    if (url == null || url.isEmpty) {
      setState(() {
        _failed = true;
        _loading = false;
      });
      return;
    }
    try {
      _audioController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _audioController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _audioController!,
        autoPlay: false,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: false,
        showOptions: false,
        placeholder: const CommonLoading(color: AppColors.white),
      );
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _audioController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        constraints: const BoxConstraints(minHeight: 180),
        color: AppColors.primaryBrandLight,
        child: _failed
            ? const _ErrorPlaceholder(icon: Icons.audiotrack_rounded)
            : (_loading || _chewieController == null)
            ? const _LoadingPlaceholder()
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: Chewie(controller: _chewieController!),
              ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 240,
      child: CommonLoading(color: AppColors.primaryBrand),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final IconData icon;

  const _ErrorPlaceholder({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Center(child: Icon(icon, size: 48, color: AppColors.textTertiary)),
    );
  }
}

class _FileInfoCard extends StatelessWidget {
  final AssignmentAttachment attachment;

  const _FileInfoCard({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _InfoIcon(kind: attachment.kind),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.name,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _metaLine(attachment),
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _metaLine(AssignmentAttachment a) {
    final parts = <String>[_kindLabel(a.kind), a.sizeLabel];
    if (a.durationLabel != null) parts.add(a.durationLabel!);
    return parts.join(' · ');
  }

  String _kindLabel(AssignmentAttachmentKind kind) {
    switch (kind) {
      case AssignmentAttachmentKind.document:
        return AppStrings.studentAssignmentAttachmentDocument;
      case AssignmentAttachmentKind.image:
        return AppStrings.studentAssignmentAttachmentImage;
      case AssignmentAttachmentKind.video:
        return AppStrings.studentAssignmentAttachmentVideo;
      case AssignmentAttachmentKind.audio:
        return AppStrings.studentAssignmentAttachmentAudio;
    }
  }
}

class _InfoIcon extends StatelessWidget {
  final AssignmentAttachmentKind kind;

  const _InfoIcon({required this.kind});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    switch (kind) {
      case AssignmentAttachmentKind.document:
        bg = AppColors.successBg;
        fg = AppColors.successGreen;
        icon = Icons.description_rounded;
        break;
      case AssignmentAttachmentKind.image:
        bg = AppColors.primaryBrandLight;
        fg = AppColors.orangeTag;
        icon = Icons.image_rounded;
        break;
      case AssignmentAttachmentKind.video:
        bg = AppColors.primaryBrandLight;
        fg = AppColors.orangeTag;
        icon = Icons.smart_display_rounded;
        break;
      case AssignmentAttachmentKind.audio:
        bg = AppColors.primaryBrandLight;
        fg = AppColors.orangeTag;
        icon = Icons.audiotrack_rounded;
        break;
    }
    return Container(
      width: AppSpacing.s40,
      height: AppSpacing.s40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.s12),
      ),
      child: Icon(icon, color: fg, size: 20),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return _ActionButton(
      label: AppStrings.studentAttachmentDownload,
      icon: Icons.download_rounded,
      isPrimary: true,
      onTap: () {
        Get.find<AttachmentPreviewController>().downloadAttachment();
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary ? AppColors.primaryBrand : AppColors.white;
    final fg = isPrimary ? AppColors.white : AppColors.textPrimary;
    final border = isPrimary
        ? Border.all(color: AppColors.primaryBrand)
        : Border.all(color: AppColors.borderGrey);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: border,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s14,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isPrimary) ...[
                Icon(icon, size: 18, color: fg),
                AppSpacing.h8,
              ],
              Text(
                label,
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
              if (isPrimary) ...[
                AppSpacing.h8,
                Icon(icon, size: 18, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
