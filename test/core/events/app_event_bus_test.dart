import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:momodown/core/events/app_event_bus.dart';

class TestEvent extends AppEvent {
  const TestEvent(this.payload);
  final String payload;
}

class OtherEvent extends AppEvent {
  const OtherEvent();
}

void main() {
  group('AppEventBus', () {
    late ProviderContainer container;
    late AppEventBus bus;

    setUp(() {
      container = ProviderContainer();
      bus = container.read(appEventBusProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('receives emitted event', () async {
      const event = TestEvent('hello');
      final future = bus.on<TestEvent>().first;
      bus.emit(event);
      final received = await future;
      expect(received.payload, 'hello');
    });

    test('filters events by type', () async {
      const testEvent = TestEvent('test');
      const otherEvent = OtherEvent();
      final future = bus.on<TestEvent>().first;
      bus.emit(otherEvent);
      bus.emit(testEvent);
      final received = await future;
      expect(received, isA<TestEvent>());
    });

    test('multiple listeners receive same event', () async {
      const event = TestEvent('broadcast');
      final future1 = bus.on<TestEvent>().first;
      final future2 = bus.on<TestEvent>().first;
      bus.emit(event);
      final received1 = await future1;
      final received2 = await future2;
      expect(received1.payload, 'broadcast');
      expect(received2.payload, 'broadcast');
    });
  });
}
