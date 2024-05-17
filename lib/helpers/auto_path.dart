import 'package:flutter/widgets.dart' show BuildContext, Widget;
import 'package:go_router/go_router.dart' show GoRoute, GoRouterHelper;
import 'package:reflectable/reflectable.dart'
    show Reflectable, ClassMirror, newInstanceCapability;

import '../pages/home.dart';

class Reflector extends Reflectable {
  const Reflector()
      : super(
          newInstanceCapability,
        ); // Request the capability to invoke methods.
}

const reflector = Reflector();

List<GoRoute> generateRouter() {
  return List.of(Router.values.map((e) {
    final instanceMirrorT = reflector.reflectType(e.className) as ClassMirror;
    return GoRoute(
        name: e.name,
        path: '/${e.path}',
        builder: (c, _) => instanceMirrorT.newInstance('', []) as Widget);
  }), growable: false);
}

enum Router {
  root(className: Home, path: ''),
  ;

  const Router({required this.className, required this.path});

  final Type className;
  final String path;

  Future<T?> navigate<T>(BuildContext context, [dynamic arguments]) =>
      context.pushNamed(name, extra: arguments);
}
