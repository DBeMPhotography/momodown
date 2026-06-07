import 'package:flutter/material.dart';

/// 备忘录列表占位页面。
class MemoListPage extends StatelessWidget {
  const MemoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Memos')),
      body: const Center(
        child: Text('Memo List Placeholder'),
      ),
    );
  }
}
