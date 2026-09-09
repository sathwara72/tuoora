import 'dart:io';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/services/push_notification_service.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';

class DownloadService extends GetxService {
  Future<String?> download({
    required String label,
    required Future<List<int>> Function() fetch,
    required String fileName,
    String? successMessage,
  }) async {
    final snack = AppSnackBar.downloading(label);
    try {
      final bytes = await fetch();
      await snack.close();
      return await saveFile(
        bytes: bytes,
        fileName: fileName,
        successMessage: successMessage,
      );
    } catch (_) {
      await snack.close();
      AppSnackBar.error(AppStrings.downloadFailed);
      return null;
    }
  }

  Future<String?> saveFile({
    required List<int> bytes,
    required String fileName,
    String? successMessage,
  }) async {
    try {
      String? filePath;

      if (Platform.isAndroid) {
        final directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          filePath = '${directory.path}/$fileName';
        } else {
          filePath =
              '/storage/emulated/0/Android/data/com.app.tuoora/files/$fileName';
        }
      } else if (Platform.isIOS) {
        throw Exception('iOS download path requires path_provider package');
      }

      if (filePath == null) {
        throw Exception('Could not determine download directory');
      }

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      AppSnackBar.success(successMessage ?? 'File downloaded');

      if (Get.isRegistered<PushNotificationService>()) {
        Get.find<PushNotificationService>().showLocalNotification(
          title: 'Report Downloaded',
          body: '$fileName has been downloaded successfully.',
        );
      }

      return filePath;
    } catch (e) {
      AppSnackBar.error(AppStrings.downloadFailed);
      return null;
    }
  }
}
