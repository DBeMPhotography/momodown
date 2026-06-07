import 'package:go_router/go_router.dart';

import 'package:momodown/core/router/feature_module.dart';
import 'package:momodown/features/home/presentation/pages/home_page.dart';

/// Home Feature 模块。
///
/// 注册首页路由 `/`。
class HomeModule implements FeatureModule {
  const HomeModule();

  @override
  String get name => 'home';

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
      ];
}

/// 全局单例，供 [main.dart] 注入注册表。
const homeModule = HomeModule();
