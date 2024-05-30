import 'package:flutter/widgets.dart' show BuildContext, RouteSettings, Widget;
import 'package:get/get.dart';
import 'package:scheduler/main.dart';
import 'package:scheduler/pages/home.dart';
import 'package:scheduler/pages/login/login.dart';

class Xyz extends GetMiddleware {

  @override
  RouteSettings? redirect(String? route) {
    if ((pref.getBool('login') ?? false) && route != '/home') {
      return const RouteSettings(name: '/home');
    }
    return null;
  }
}


enum Routes {
  home(className: Home(), path: 'home'),
  login(className: Login(), path: ''),
  ;

  const Routes({required this.className, required this.path});

  final Widget className;
  final String path;

  navigate<T>(BuildContext context, [dynamic arguments]) =>
      Get.toNamed(name, arguments: arguments);
}
