import 'package:go_router/go_router.dart';

/// Feature 模块接口。
///
/// 每个 Feature 模块实现此接口，在 [routes] 中声明自身路由。
/// [RouteRegistry] 收集所有模块的路由并合并为 [GoRouter] 配置。
///
/// 新增 Feature 时：
/// 1. 创建 `lib/features/xxx/xxx_module.dart` 实现 [FeatureModule]。
/// 2. 在 `main.dart` 的 `modules` 列表中加入该模块。
/// 无需修改 `app_router.dart` 内部逻辑。
abstract class FeatureModule {
  /// 模块唯一标识名。
  String get name;

  /// 模块路由表。
  List<RouteBase> get routes;
}
