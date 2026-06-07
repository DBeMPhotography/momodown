import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momodown/features/memo/data/repositories/local_memo_repository.dart';
import 'package:momodown/features/memo/domain/entities/memo_entity.dart';
import 'package:momodown/features/memo/domain/repositories/memo_repository.dart';

void main() {
  group('LocalMemoRepository', () {
    late ProviderContainer container;
    late MemoRepository repository;

    setUp(() {
      container = ProviderContainer();
      repository = container.read(localMemoRepositoryProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('getAllMemos returns empty list initially', () async {
      final memos = await repository.getAllMemos();
      expect(memos, isEmpty);
    });

    test('getMemoById returns null for unknown id', () async {
      final memo = await repository.getMemoById('unknown');
      expect(memo, isNull);
    });

    test('saveMemo then getMemoById returns the memo', () async {
      final memo = MemoEntity(
        id: '1',
        content: 'Hello MemoDown',
        createdAt: DateTime(2026, 6, 7),
      );

      await repository.saveMemo(memo);
      final found = await repository.getMemoById('1');

      expect(found, isNotNull);
      expect(found!.id, '1');
      expect(found.content, 'Hello MemoDown');
    });

    test('saveMemo updates existing memo', () async {
      final memo = MemoEntity(
        id: '1',
        content: 'Original',
        createdAt: DateTime(2026, 6, 7),
      );
      final updated = MemoEntity(
        id: '1',
        content: 'Updated',
        createdAt: DateTime(2026, 6, 7),
      );

      await repository.saveMemo(memo);
      await repository.saveMemo(updated);
      final found = await repository.getMemoById('1');

      expect(found!.content, 'Updated');
    });

    test('deleteMemo removes the memo', () async {
      final memo = MemoEntity(
        id: '1',
        content: 'To be deleted',
        createdAt: DateTime(2026, 6, 7),
      );

      await repository.saveMemo(memo);
      await repository.deleteMemo('1');
      final found = await repository.getMemoById('1');

      expect(found, isNull);
    });

    test('saveMemo returns the saved memo', () async {
      final memo = MemoEntity(
        id: '1',
        content: 'Test',
        createdAt: DateTime(2026, 6, 7),
      );

      final saved = await repository.saveMemo(memo);
      expect(saved.id, '1');
      expect(saved.content, 'Test');
    });
  });
}
