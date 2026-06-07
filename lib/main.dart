import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:momodown/core/router/app_router.dart';
import 'package:momodown/core/router/route_registry.dart';
import 'package:momodown/features/home/home_module.dart';
import 'package:momodown/features/memo/memo_module.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        routeRegistryProvider.overrideWithValue(
          const RouteRegistry(modules: [homeModule, memoModule]),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'MemoDown',
      routerConfig: router,
    );
  }
}
