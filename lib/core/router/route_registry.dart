import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:momodown/core/router/feature_module.dart';

/// 路由注册表 Provider。
///
/// 默认提供空注册表。在 [ProviderScope] 中通过 [overrideWithValue]
/// 注入已注册所有 Feature 的实例：
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     routeRegistryProvider.overrideWithValue(
///       RouteRegistry(modules: [homeModule, memoModule]),
///     ),
///   ],
///   child: MyApp(),
/// )
/// ```
final routeRegistryProvider = Provider<RouteRegistry>(
  (ref) => const RouteRegistry(modules: []),
);

/// 路由注册表。
///
/// 在构造时接收所有 [FeatureModule]，合并其路由表。
/// 通过 [allRoutes] 暴露给 [GoRouter] 使用。
class RouteRegistry {
  const RouteRegistry({required this._modules});

  final List<FeatureModule> _modules;

  /// 所有已注册模块的路由合并列表。
  List<RouteBase> get allRoutes => [
        for (final module in _modules) ...module.routes,
      ];

  /// 根据模块名查找对应路由（调试用）。
  List<RouteBase> routesOf(String moduleName) {
    final module = _modules.firstWhere(
      (m) => m.name == moduleName,
      orElse: () => throw StateError('Module $moduleName not found'),
    );
    return module.routes;
  }
}
