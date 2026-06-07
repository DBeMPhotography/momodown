import 'package:momodown/features/memo/domain/entities/memo_entity.dart';

/// 备忘录数据仓库抽象接口。
///
/// 业务层通过此接口访问数据，不依赖具体实现（Isar / Dio / Mock）。
/// 更换数据源时只需提供新的实现并替换 Provider，无需修改业务代码。
abstract class MemoRepository {
  /// 获取所有备忘录
  Future<List<MemoEntity>> getAllMemos();

  /// 根据 ID 获取单个备忘录
  Future<MemoEntity?> getMemoById(String id);

  /// 保存（新增或更新）备忘录
  Future<MemoEntity> saveMemo(MemoEntity memo);

  /// 删除指定 ID 的备忘录
  Future<void> deleteMemo(String id);
}
