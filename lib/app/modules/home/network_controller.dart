import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:iron_street_app/app/widgets/custom_toast.dart';

class NetworkController extends GetxController {
  var isOffline = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    // Run initial check immediately
    _checkInternetConnection();
    // Poll connection status every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkInternetConnection();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final bool hasNet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      _updateConnectionStatus(!hasNet);
    } catch (_) {
      _updateConnectionStatus(true);
    }
  }

  void _updateConnectionStatus(bool offline) {
    if (isOffline.value != offline) {
      isOffline.value = offline;
      if (offline) {
        CustomToast.show(
          'No Internet Connection. Some features may be offline.',
          isError: true,
          isPersistent: true,
        );
      } else {
        CustomToast.dismissPersistent();
        CustomToast.show(
          'Internet connection restored!',
          isSuccess: true,
        );
      }
    }
  }
}
