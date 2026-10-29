import 'package:flutter/material.dart';

class ModuleItem {
  final String title;
  final VoidCallback onTap;
  final String svgAsset;

  /// Optional count shown as a badge on the tile (read inside an Obx, so it
  /// can come from Rx values). Nothing is shown when it returns 0.
  final int Function()? badgeCount;

  /// Badge colour; defaults to the brand colour.
  final Color Function()? badgeColor;

  ModuleItem(
    this.title,
    this.onTap,
    this.svgAsset, {
    this.badgeCount,
    this.badgeColor,
  });
}
