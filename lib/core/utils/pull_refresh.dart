import 'package:get/get.dart';

/// Keeps a screen's full-page loader hidden while a pull-to-refresh runs.
///
/// Controllers set `isLoading = true` for every fetch, so a screen that swaps
/// its whole body for a loader on `isLoading` destroys the RefreshIndicator the
/// moment the user pulls. Gate that loader with `!PullRefresh.active.value`
/// and pass the fetch through [PullRefresh.run] so the spinner stays until the
/// API call has finished.
class PullRefresh {
  PullRefresh._();

  static final active = false.obs;
  static int _running = 0;

  static Future<void> run(Future<void> Function() fetch) async {
    _running++;
    active.value = true;
    try {
      await fetch();
    } finally {
      if (--_running == 0) active.value = false;
    }
  }
}
