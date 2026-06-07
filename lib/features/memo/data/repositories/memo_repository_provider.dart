import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momodown/features/memo/domain/repositories/memo_repository.dart';
import 'package:momodown/features/memo/data/repositories/local_memo_repository.dart';

/// 全局可访问的 [MemoRepository] Provider。
///
/// 默认注入本地实现。未来如需切换为远程实现（例如用户登录后），
/// 只需在 [ProviderScope] 中使用 [override] 替换此 Provider：
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     memoRepositoryProvider.overrideWithValue(remoteMemoRepository),
///   ],
///   child: MyApp(),
/// )
/// ```
final memoRepositoryProvider = Provider<MemoRepository>(
  (ref) => ref.watch(localMemoRepositoryProvider),
);
