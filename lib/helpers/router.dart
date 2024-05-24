import 'package:flutter/widgets.dart' show BuildContext, Widget;
import 'package:get/get.dart';
import 'package:scheduler/main.dart';
import 'package:scheduler/pages/code_page.dart';


generateRouter() {
  return List.of(Router.values.map((e) {
    return GetPage(
        name:  '/${e.path}', page: () => e.className);
    // final instanceMirrorT = reflector.reflectType(e.className) as ClassMirror;
    // return GoRoute(
    //     name: e.name,
    //     path: '/${e.path}',
    //     builder: (c, _) => instanceMirrorT.newInstance('', []) as Widget);
  }), growable: false);
}

enum Router {
  root(className: CodePage(), path: ''),
  ;

  const Router({required this.className, required this.path});

  final Widget className;
  final String path;

  navigate<T>(BuildContext context, [dynamic arguments]) =>
      Get.toNamed(name, arguments: arguments);
}
