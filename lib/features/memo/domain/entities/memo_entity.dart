/// 备忘录领域实体，与存储/网络层解耦。
class MemoEntity {
  const MemoEntity({
    required this.id,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content;

  @override
  int get hashCode => id.hashCode ^ content.hashCode;

  @override
  String toString() =>
      'MemoEntity(id: \'$id\', content: \'$content\', createdAt: $createdAt)';
}
