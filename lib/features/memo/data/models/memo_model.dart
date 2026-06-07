import 'package:momodown/features/memo/domain/entities/memo_entity.dart';

/// 备忘录数据模型，用于 Isar 存储或网络序列化。
///
/// 作为数据层与领域层之间的适配器，隔离外部库类型对业务代码的污染。
class MemoModel {
  const MemoModel({
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// 从领域实体转换为数据模型
  factory MemoModel.fromEntity(MemoEntity entity) => MemoModel(
        id: entity.id,
        content: entity.content,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  /// 转换为领域实体
  MemoEntity toEntity() => MemoEntity(
        id: id,
        content: content,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
