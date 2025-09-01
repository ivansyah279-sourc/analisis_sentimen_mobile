import 'package:sentimen_mobile/app/modules/index/controllers/index_controller.dart';
import 'package:get/get.dart';
import 'package:sentimen_mobile/app/modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<IndexController>(() => IndexController());
  }
}
