import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/data/local/my_shared_pref.dart';
import 'app/modules/splash/bindings/splash_binding.dart';
import 'app/routes/app_pages.dart';
import 'config/translations/localization_service.dart';
import 'package:sentimen_mobile/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MySharedPref.init();
  await initializeDateFormatting(
    LocalizationService.getCurrentLocal().languageCode,
  );

  runApp(const MyApp());
  configLoading();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      rebuildFactor: (old, data) => true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Sentiment Apps',
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.fade,
          smartManagement: SmartManagement.keepFactory,
          initialBinding: SplashBinding(),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          locale: MySharedPref.getCurrentLocal(),
          translations: LocalizationService.getInstance(),
          themeMode: ThemeMode.dark,
          theme: ThemeData(
            brightness: Brightness.light,
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black,
              selectionColor: Colors.grey,
              selectionHandleColor: Colors.black,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.white,
              selectionColor: Colors.white30,
              selectionHandleColor: Colors.white,
            ),
            cardColor: Colors.grey[900],
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              secondary: Colors.deepOrange,
            ),
          ),
          builder: (context, widget) {
            return EasyLoading.init()(
              context,
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 500) {
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: SizedBox(
                            width: 400,
                            height: 844,
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                size: const Size(400, 844),
                              ),
                              child: widget!,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return widget!;
                },
              ),
            );
          },
        );
      },
    );
  }
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.spinningCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..radius = 10.0
    ..backgroundColor = ColorConstants.colorBackground
    ..indicatorColor = Colors.black
    ..textColor = Colors.black
    ..userInteractions = false
    ..dismissOnTap = false
    ..animationStyle = EasyLoadingAnimationStyle.scale;
}
