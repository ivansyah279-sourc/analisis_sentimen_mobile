import 'package:sentimen_mobile/app/modules/index/controllers/index_controller.dart';
import 'package:get/get.dart';

class IndexBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IndexController>(IndexController(), permanent: true);
  }
}
