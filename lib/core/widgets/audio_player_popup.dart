import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';

/// Small popup that plays an audio file (remote URL or local path), starting
/// straight away, and closes itself when the audio finishes.
class AudioPlayerPopup extends StatefulWidget {
  final String source; // http(s) url or local file path
  final String title;

  const AudioPlayerPopup({super.key, required this.source, required this.title});

  static Future<void> show({required String source, required String title}) {
    return Get.dialog(
      AudioPlayerPopup(source: source, title: title),
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  State<AudioPlayerPopup> createState() => _AudioPlayerPopupState();
}

class _AudioPlayerPopupState extends State<AudioPlayerPopup> {
  late final VideoPlayerController _controller;
  bool _failed = false;
  bool _closing = false;

  bool get _isLocal => !widget.source.startsWith('http');

  @override
  void initState() {
    super.initState();
    _controller = _isLocal
        ? VideoPlayerController.file(File(widget.source))
        : VideoPlayerController.networkUrl(Uri.parse(widget.source));
    _controller.addListener(_onTick);
    _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {});
          _controller.play();
        })
        .catchError((_) {
          if (mounted) setState(() => _failed = true);
        });
  }

  void _onTick() {
    final v = _controller.value;
    if (v.hasError && !_failed && mounted) {
      setState(() => _failed = true);
      return;
    }
    // Finished: close the popup.
    if (v.isInitialized &&
        !_closing &&
        v.duration > Duration.zero &&
        v.position >= v.duration) {
      _closing = true;
      if (mounted && (Get.isDialogOpen ?? false)) Get.back();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: _failed ? _buildError() : _buildPlayer(),
      ),
    );
  }

  Widget _buildError() {
    return Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.errorRed),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "Couldn't play this audio",
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildPlayer() {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        final total = value.duration;
        final pos = value.position > total ? total : value.position;
        final ready = value.isInitialized && total > Duration.zero;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrand.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.audiotrack_rounded,
                    size: 20,
                    color: AppColors.primaryBrand,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  iconSize: 40,
                  color: AppColors.primaryBrand,
                  onPressed: ready
                      ? () => value.isPlaying
                            ? _controller.pause()
                            : _controller.play()
                      : null,
                  icon: Icon(
                    value.isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      activeColor: AppColors.primaryBrand,
                      inactiveColor: AppColors.borderGrey,
                      value: ready ? pos.inMilliseconds.toDouble() : 0,
                      max: ready ? total.inMilliseconds.toDouble() : 1,
                      onChanged: ready
                          ? (v) => _controller.seekTo(
                              Duration(milliseconds: v.round()),
                            )
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${_fmt(pos)} / ${_fmt(total)}',
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
