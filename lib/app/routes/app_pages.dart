import 'package:sentimen_mobile/app/modules/auth/bindings/auth_binding.dart';
import 'package:sentimen_mobile/app/modules/auth/views/login_view.dart';
import 'package:sentimen_mobile/app/modules/index/views/index_view.dart';
import 'package:sentimen_mobile/app/modules/splash/views/maintenance_view.dart';
import 'package:sentimen_mobile/app/modules/index/bindings/index_binding.dart';
import 'package:get/get.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.MAINTENANCE,
      page: () => const MaintenanceView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.INDEX,
      page: () => IndexView(),
      binding: IndexBinding(),
    ),
  ];
}
