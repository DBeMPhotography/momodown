import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 应用全局事件基类。
///
/// 所有通过事件总线传递的事件均应继承此类。
abstract class AppEvent {
  const AppEvent();
}

/// 全局事件总线。
///
/// 基于广播 [StreamController]，支持类型安全的事件监听与发送。
/// 通过 [appEventBusProvider] 以 Riverpod 管理生命周期，
/// 确保在 Scope 销毁时自动释放资源。
class AppEventBus {
  final StreamController<AppEvent> _controller =
      StreamController<AppEvent>.broadcast();

  /// 监听指定类型的事件流。
  Stream<T> on<T extends AppEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  /// 发送事件。
  void emit(AppEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  /// 释放资源。
  void dispose() {
    _controller.close();
  }
}

/// 全局 [AppEventBus] Provider。
final appEventBusProvider = Provider<AppEventBus>((ref) {
  final bus = AppEventBus();
  ref.onDispose(bus.dispose);
  return bus;
});
