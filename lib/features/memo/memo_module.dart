import 'package:go_router/go_router.dart';

import 'package:momodown/core/router/feature_module.dart';
import 'package:momodown/features/memo/presentation/pages/memo_list_page.dart';

/// Memo Feature 模块。
///
/// 注册备忘录列表路由 `/memos`。
class MemoModule implements FeatureModule {
  const MemoModule();

  @override
  String get name => 'memo';

  @override
  List<RouteBase> get routes => [
        GoRoute(
          path: '/memos',
          builder: (context, state) => const MemoListPage(),
        ),
      ];
}

/// 全局单例，供 [main.dart] 注入注册表。
const memoModule = MemoModule();
