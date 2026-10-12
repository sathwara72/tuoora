import 'dart:io';

import 'package:tuoora/core/constants/app_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/services/media_cache_service.dart';
import 'package:tuoora/core/widgets/audio_player_popup.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/pdf_viewer_popup.dart';
import 'package:tuoora/presentation/institute/view/in_app_resource_viewer.dart';

/// Renders a single chat attachment (image / video / audio / document) and
/// drives the WhatsApp-style open flow:
///   - Images stream + cache automatically; tapping opens the fullscreen
///     viewer.
///   - Video / audio / document show a download affordance for remote files.
///     Tapping downloads to cache with a live % ring overlaid on the bubble,
///     then opens the cached file in the fullscreen viewer.
///   - Files already on this device (the sender's just-sent attachment) skip
///     the download and open immediately.
///
/// Identical for sender and receiver — only [isMe] tweaks the tint.
class ChatAttachmentView extends StatelessWidget {
  final String url; // local file path OR remote http(s) url
  final String type; // 'image' | 'video' | 'audio' | 'document'
  final bool isMe;

  const ChatAttachmentView({
    super.key,
    required this.url,
    required this.type,
    required this.isMe,
  });

  bool get _isLocal => !url.startsWith('http');

  MediaCacheService get _cache => Get.find<MediaCacheService>();

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'image':
        return _buildImage();
      case 'video':
        return _buildMedia(_MediaKind.video);
      case 'audio':
        return _buildMedia(_MediaKind.audio);
      case 'document':
        return _buildMedia(_MediaKind.document);
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------- image

  Widget _buildImage() {
    final Widget thumb = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 240,
          minWidth: 180,
          maxWidth: 280,
        ),
        child: _isLocal
            ? Image.file(
                File(url),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _imageError(),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  height: 200,
                  width: 200,
                  alignment: Alignment.center,
                  color: AppColors.background.withValues(alpha: 0.3),
                  child: const CommonLoading(),
                ),
                errorWidget: (_, _, _) => _imageError(),
              ),
      ),
    );

    return GestureDetector(
      onTap: () => _open(
        InAppResourceViewer.image(url: url, title: AppStrings.studentAssignmentAttachmentImage),
      ),
      child: thumb,
    );
  }

  Widget _imageError() => Container(
    height: 120,
    width: 200,
    alignment: Alignment.center,
    color: AppColors.background.withValues(alpha: 0.3),
    child: Icon(
      Icons.broken_image_outlined,
      color: isMe ? AppColors.white : AppColors.textTertiary,
    ),
  );

  // ------------------------------------------------ video / audio / document

  Widget _buildMedia(_MediaKind kind) {
    // Audio plays straight away in a popup: no download step, no progress
    // ring. A copy already in the cache is used, otherwise it streams.
    if (kind == _MediaKind.audio) {
      return Obx(() {
        String source = url;
        if (!_isLocal) {
          final st = _cache.stateFor(url).value;
          if (st.status == MediaDownloadStatus.done && st.localPath != null) {
            source = st.localPath!;
          }
        }
        return _shell(
          kind,
          _Affordance.ready,
          1,
          onTap: () => _playAudio(source),
        );
      });
    }

    // Local file (e.g. sender's optimistic attachment) — already available,
    // open directly with a ready/play affordance.
    if (_isLocal) {
      return _shell(kind, _Affordance.ready, 0, onTap: () => _openLocal(url, kind));
    }

    // Remote — observe the cache download state for this URL.
    return Obx(() {
      final st = _cache.stateFor(url).value;
      switch (st.status) {
        case MediaDownloadStatus.done:
          final path = st.localPath ?? url;
          return _shell(
            kind,
            _Affordance.ready,
            1,
            onTap: () => _openLocal(path, kind),
          );
        case MediaDownloadStatus.downloading:
          return _shell(kind, _Affordance.progress, st.progress, onTap: null);
        case MediaDownloadStatus.failed:
        case MediaDownloadStatus.idle:
          return _shell(
            kind,
            _Affordance.download,
            0,
            onTap: () => _startDownloadAndOpen(kind),
          );
      }
    });
  }

  Future<void> _startDownloadAndOpen(_MediaKind kind) async {
    final path = await _cache.ensureDownloaded(url);
    if (path != null) _openLocal(path, kind);
  }

  /// Visual shell. Video shows a thumbnail box, audio/document show a file
  /// tile. The [affordance] controls the centred (video) or trailing
  /// (tile) indicator: download icon, % ring, or play/open icon.
  Widget _shell(
    _MediaKind kind,
    _Affordance affordance,
    double progress, {
    required VoidCallback? onTap,
  }) {
    if (kind == _MediaKind.video) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 160,
            width: 220,
            color: Colors.black87,
            alignment: Alignment.center,
            child: _indicator(affordance, progress, onDark: true, kind: kind),
          ),
        ),
      );
    }

    // audio / document tile
    final IconData leadingIcon = kind == _MediaKind.audio
        ? Icons.audiotrack_rounded
        : Icons.description_rounded;
    final tint = isMe ? AppColors.white : AppColors.primaryBrand;
    final textColor = isMe ? AppColors.white : AppColors.textPrimary;
    final name = _displayFilename(url);
    final sub = kind == _MediaKind.audio
        ? 'Audio'
        : (name.contains('.') ? name.split('.').last.toUpperCase() : 'FILE');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: isMe ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(leadingIcon, color: tint, size: 22),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  Text(
                    sub,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _indicator(affordance, progress, onDark: false, kind: kind),
          ],
        ),
      ),
    );
  }

  // Centred/trailing indicator: download icon, % progress ring, or play/open.
  Widget _indicator(_Affordance a, double progress, {required bool onDark, required _MediaKind kind}) {
    final color = onDark ? AppColors.white : AppColors.primaryBrand;
    switch (a) {
      case _Affordance.download:
        return Icon(Icons.download_rounded, color: color, size: onDark ? 40 : 26);
      case _Affordance.progress:
        return SizedBox(
          width: onDark ? 48 : 34,
          height: onDark ? 48 : 34,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress == 0 ? null : progress,
                strokeWidth: 3,
                color: color,
                backgroundColor: color.withValues(alpha: 0.25),
              ),
              Text(
                '${(progress * 100).clamp(0, 100).round()}',
                style: AppTextStyles.outfit(
                  fontSize: onDark ? 11 : 9,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      case _Affordance.ready:
        if (kind == _MediaKind.document) {
          return const SizedBox.shrink();
        }
        return Icon(
          Icons.play_circle_outline_rounded,
          color: color,
          size: onDark ? 48 : 26,
        );
    }
  }

  void _openLocal(String path, _MediaKind kind) {
    switch (kind) {
      case _MediaKind.video:
        _open(InAppResourceViewer.video(url: path, title: AppStrings.studentAssignmentAttachmentVideo));
        break;
      case _MediaKind.audio:
        _playAudio(path);
        break;
      case _MediaKind.document:
        if (path.toLowerCase().endsWith('.pdf')) {
          PdfViewerPopup.show(path: path, title: _displayFilename(path));
        } else {
          // Non-PDF documents need Google Docs Viewer which requires a public HTTP URL.
          // If we downloaded it, the URL is still remote, so use the remote URL.
          final targetUrl = url.startsWith('http') ? url : path;
          _open(
            InAppResourceViewer.web(url: targetUrl, title: _displayFilename(targetUrl)),
          );
        }
        break;
    }
  }

  void _playAudio(String source) {
    AudioPlayerPopup.show(source: source, title: _displayFilename(url));
  }

  void _open(Widget viewer) {
    Get.to(
      () => viewer,
      fullscreenDialog: true,
      transition: Transition.fadeIn,
    );
  }

  String _displayFilename(String urlOrPath) {
    if (urlOrPath.isEmpty) return 'File';
    try {
      final segments = Uri.parse(urlOrPath).pathSegments;
      if (segments.isNotEmpty && segments.last.isNotEmpty) {
        return segments.last;
      }
    } catch (_) {}
    return urlOrPath.split(RegExp(r'[\\/]')).last;
  }
}

enum _MediaKind { video, audio, document }

enum _Affordance { download, progress, ready }
