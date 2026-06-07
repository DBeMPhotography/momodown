import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:momodown/core/router/route_registry.dart';
import 'package:momodown/features/home/home_module.dart';
import 'package:momodown/features/memo/memo_module.dart';
import 'package:momodown/main.dart';

void main() {
  group('MyApp', () {
    testWidgets('renders HomePage at initial route', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routeRegistryProvider.overrideWithValue(
              const RouteRegistry(modules: [homeModule, memoModule]),
            ),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('MemoDown'), findsOneWidget);
      expect(find.text('Welcome to MemoDown!'), findsOneWidget);
    });
  });
}
