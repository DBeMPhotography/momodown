import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:momodown/core/router/feature_module.dart';
import 'package:momodown/core/router/route_registry.dart';

class TestModuleA implements FeatureModule {
  const TestModuleA();

  @override
  String get name => 'moduleA';

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: '/a',
          builder: (context, state) => const SizedBox(),
        ),
      ];
}

class TestModuleB implements FeatureModule {
  const TestModuleB();

  @override
  String get name => 'moduleB';

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: '/b',
          builder: (context, state) => const SizedBox(),
        ),
      ];
}

void main() {
  group('RouteRegistry', () {
    test('returns empty routes when no modules', () {
      const registry = RouteRegistry(modules: []);
      expect(registry.allRoutes, isEmpty);
    });

    test('merges routes from all modules', () {
      const registry = RouteRegistry(modules: [TestModuleA(), TestModuleB()]);
      final routes = registry.allRoutes;
      expect(routes.length, 2);
    });

    test('routesOf returns routes for specific module', () {
      const registry = RouteRegistry(modules: [TestModuleA()]);
      final routes = registry.routesOf('moduleA');
      expect(routes.length, 1);
    });

    test('routesOf throws for unknown module', () {
      const registry = RouteRegistry(modules: []);
      expect(() => registry.routesOf('unknown'), throwsStateError);
    });
  });
}
