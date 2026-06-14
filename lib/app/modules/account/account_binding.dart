/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:get/get.dart';
import 'account_controller.dart';

class AccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountController>(() => AccountController());
  }
}
