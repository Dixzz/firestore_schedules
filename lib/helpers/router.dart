import 'package:flutter/widgets.dart' show BuildContext, Widget;
import 'package:go_router/go_router.dart' show GoRoute, GoRouterHelper;
import 'package:scheduler/main.dart';
import 'package:scheduler/pages/code_page.dart';


List<GoRoute> generateRouter() {
  return List.of(Router.values.map((e) {
    return GoRoute(
        name: e.name, path: '/${e.path}', builder: (_, __) => e.className);
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

  Future<T?> navigate<T>(BuildContext context, [dynamic arguments]) =>
      context.pushNamed(name, extra: arguments);
}
