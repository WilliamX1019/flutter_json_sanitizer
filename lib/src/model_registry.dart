import 'package:flutter/foundation.dart';

typedef ModelFactory<T> = T Function(Map<String, dynamic> json);

/// 模型注册中心，用于在 Isolate 内根据模型名称创建实例。
/// 在主线程初始化时注册模型工厂，然后在子 Isolate 中使用。
class ModelRegistry {
  /// 私有静态注册表，保存模型名称与构造函数映射。
  static final Map<String, ModelFactory<dynamic>> _registry = {};

  /// 注册模型类型及其构造函数。
  ///
  /// 示例：
  /// ```dart
  /// ModelRegistry.register<User>('User', (json) => User.fromJson(json));
  /// ```
  static void register<T>(String modelName, ModelFactory<T> factory) {
    if (modelName.isEmpty) {
      throw ArgumentError('modelName cannot be empty');
    }
    if (_registry.containsKey(modelName)) {
      // 可重复注册时覆盖旧的构造函数
      if (kDebugMode) {
        print(
            '⚠️ ModelRegistry: overriding existing registration for "$modelName"');
      }
    }
    _registry[modelName] = factory;
    if (kDebugMode) {
      print('✅ ModelRegistry: registered model "$modelName"');
    }
  }

  /// 根据模型名称创建实例。
  ///
  /// 若未找到对应构造函数，返回 `null`。
  static T? create<T>(String modelName, Map<String, dynamic> json) {
    final factory = _registry[modelName];
    if (factory == null) {
      if (kDebugMode) {
        print('❌ ModelRegistry: no factory found for "$modelName"');
      }
      return null;
    }

    try {
      final result = factory(json);
      return result as T;
    } catch (e, s) {
      if (kDebugMode) {
        print('❌ ModelRegistry: failed to create "$modelName" instance: $e');
        print(s);
      }
      return null;
    }
  }

  /// 检查某个模型是否已注册。
  static bool isRegistered(String modelName) =>
      _registry.containsKey(modelName);

  /// 移除某个模型的注册
  static void unregister(String modelName) {
    if (_registry.containsKey(modelName)) {
      _registry.remove(modelName);
      if (kDebugMode) {
        print('🧹 ModelRegistry: unregistered model "$modelName"');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ ModelRegistry: model "$modelName" is not registered');
      }
    }
  }

  /// 返回已注册模型名称列表。
  static List<String> get registeredModels => List.unmodifiable(_registry.keys);

  /// 清除所有注册（仅调试或测试场景使用）
  static void clear() {
    _registry.clear();
    if (kDebugMode) {
      print('🧹 ModelRegistry: cleared all registrations');
    }
  }
}
