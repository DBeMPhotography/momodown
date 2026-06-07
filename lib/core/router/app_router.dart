import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:momodown/core/router/route_registry.dart';

/// 全局 [GoRouter] Provider。
///
/// 从 [routeRegistryProvider] 读取已合并的路由表，构建 [GoRouter]。
/// Feature 模块通过向 [RouteRegistry] 注册自身路由实现自注册。
final appRouterProvider = Provider<GoRouter>((ref) {
  final registry = ref.watch(routeRegistryProvider);
  return GoRouter(
    routes: registry.allRoutes,
    initialLocation: '/',
    debugLogDiagnostics: true,
  );
});
