import 'package:flutter/widgets.dart' show Widget;
import 'package:go_router/go_router.dart' show GoRoute;
import 'package:reflectable/reflectable.dart'
    show Reflectable, ClassMirror, newInstanceCapability;
import 'package:river/main.dart' show Wow;

List<GoRoute> generateRouter() {
  return List.of(Router.values.map((e) {
    final instanceMirrorT = reflector.reflectType(e.className) as ClassMirror;
    return GoRoute(
        path: e.path,
        builder: (c, _) => instanceMirrorT.newInstance('', []) as Widget);
  }), growable: false);
}

class Reflector extends Reflectable {
  const Reflector()
      : super(
          newInstanceCapability,
        ); // Request the capability to invoke methods.
}

const reflector = Reflector();

enum Router {
  root(className: Wow, path: '/'),
  ;

  const Router({required this.className, required this.path});

  final Type className;
  final String path;
}
