import 'package:flutter/material.dart';

/// 首页占位页面。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MemoDown')),
      body: const Center(
        child: Text('Welcome to MemoDown!'),
      ),
    );
  }
}
