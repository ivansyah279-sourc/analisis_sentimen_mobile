part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const MAINTENANCE = _Paths.MAINTENANCE;
  static const LOGIN = _Paths.LOGIN;
  static const INDEX = _Paths.INDEX;
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/';
  static const MAINTENANCE = '/maintenance';
  static const LOGIN = '/login';
  static const INDEX = '/index';
}
