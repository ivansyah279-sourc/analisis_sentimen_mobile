import 'package:sentimen_mobile/app/services/api_call_status.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;

  @override
  void onInit() async {
    super.onInit();

    await Future.delayed(const Duration(milliseconds: 3500));
    Get.offAndToNamed(Routes.LOGIN);
  }
}
