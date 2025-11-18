import 'package:flutter/foundation.dart';

typedef ModelFactory<T> = T Function(Map<String, dynamic> json);

/// 模型注册中心，用于在 Isolate 内根据模型名称创建实例。
/// 在主线程初始化时注册模型工厂，然后在子 Isolate 中使用。
class ModelRegistry {
  /// 私有静态注册表，保存模型名称与构造函数映射。
  static final Map<Type, ModelFactory<dynamic>> _registry = {};

  /// 注册模型类型及其构造函数。
  ///
  /// 示例：
  /// ```dart
  /// ModelRegistry.register<User>('User', (json) => User.fromJson(json));
  /// ```
  static void register<T>(Type type, ModelFactory<T> factory,
      {bool isSubIsolate = false}) {

    if (_registry.containsKey(type)) {
      // 可重复注册时覆盖旧的构造函数
      if (kDebugMode) {
        print(
            '⚠️ ModelRegistry: overriding existing registration for "$type", isSubIsolate: $isSubIsolate');
      }
    }
    _registry[type] = factory;
    if (kDebugMode) {
      print('✅ ModelRegistry: registered model "$type", isSubIsolate: $isSubIsolate');
    }
  }

  /// 根据模型名称创建实例。
  ///
  /// 若未找到对应构造函数，返回 `null`。
  static T? create<T>(Type type, Map<String, dynamic> json,
      {bool isSubIsolate = false}) {
    final factory = _registry[type];
    if (factory == null) {
      if (kDebugMode) {
        print('❌ ModelRegistry: no factory found for "$type" , isSubIsolate: $isSubIsolate');
      }
      return null;
    }

    try {
      final result = factory(json);
      if (kDebugMode) {
        print( '✅ ModelRegistry: successfully created "$type" instance from JSON, isSubIsolate: $isSubIsolate');
      }
      return result as T;
    } catch (e, s) {
      if (kDebugMode) {
        print('❌ ModelRegistry: failed to create "$type" instance: $e, isSubIsolate: $isSubIsolate');
        print(s);
      }
      return null;
    }
  }

  /// 检查某个模型是否已注册。
  static bool isRegistered(Type type) =>
      _registry.containsKey(type);

  /// 移除某个模型的注册
  static void unregister(Type type) {
    if (_registry.containsKey(type)) {
      _registry.remove(type);
      if (kDebugMode) {
        print('🧹 ModelRegistry: unregistered model "$type"');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ ModelRegistry: model "$type" is not registered');
      }
    }
  }

  /// 返回已注册模型类型列表。
  static List<Type> get registeredTypes => List.unmodifiable(_registry.keys);

  /// 清除所有注册（仅调试或测试场景使用）
  static void clear() {
    _registry.clear();
    if (kDebugMode) {
      print('🧹 ModelRegistry: cleared all registrations');
    }
  }
}
