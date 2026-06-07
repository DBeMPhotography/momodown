import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:momodown/features/memo/domain/entities/memo_entity.dart';
import 'package:momodown/features/memo/domain/repositories/memo_repository.dart';

/// 本地 [MemoRepository] 实现（基于 Isar，当前为占位）。
///
/// Phase 1 中仅提供内存级占位实现，后续接入 Isar 数据库后替换内部逻辑即可，
/// 对外接口与业务代码完全无侵入。
final localMemoRepositoryProvider = Provider<MemoRepository>(
  (ref) => LocalMemoRepository(),
);

class LocalMemoRepository implements MemoRepository {
  // TODO: 接入 Isar 实例后替换为真实数据库操作
  final List<MemoEntity> _memos = [];

  @override
  Future<List<MemoEntity>> getAllMemos() async => List.unmodifiable(_memos);

  @override
  Future<MemoEntity?> getMemoById(String id) async {
    try {
      return _memos.firstWhere((m) => m.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<MemoEntity> saveMemo(MemoEntity memo) async {
    final index = _memos.indexWhere((m) => m.id == memo.id);
    if (index >= 0) {
      _memos[index] = memo;
    } else {
      _memos.add(memo);
    }
    return memo;
  }

  @override
  Future<void> deleteMemo(String id) async {
    _memos.removeWhere((m) => m.id == id);
  }
}
