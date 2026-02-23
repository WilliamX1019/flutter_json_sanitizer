// 文件：lib/safe_convert/safe_freezed.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'safe_converter_utils.dart'; // 你的转换器所在文件

// 1. 将所有安全转换器打包成一个常数组
const safeJsonConverters = [
  SafeIntConverter(),
  SafeNullableIntConverter(),
  SafeDoubleConverter(),
  SafeNullableDoubleConverter(),
  SafeBoolConverter(),
  SafeNullableBoolConverter(),
  SafeMapConverter(),
  SafeNullableMapConverter(),
];

// 2. 将 Freezed 注解也顺手定好（你甚至能在这里控制带不带 json/copy 等生成要素）
// 2. 生产级最佳实践 Freezed 配置宏
const safeFreezed = Freezed(
  // [强力推荐] 开启不可变集合防篡改，防止在状态管理中引用了旧数据流地址
  makeCollectionsUnmodifiable: true,
  // 保持标准的 JSON 序列化功能开启（这是核心）
  fromJson: true,
  toJson: true,
  // 开启 fallback 兼容性：遇到枚举类没有映射到的新类型时，是否允许抛出/给默认兜底
  // 当配合未知枚举值时非常有效，不过具体枚举兜底一般写在枚举上方 (@JsonValue(unknownEnumValue))
  // [推荐] 提供 `copyWith` 和 `==` 方法以支持基于属性的值比较（Riverpod/Bloc 刚需）
  copyWith: true,
  equal: true,
  // [可选优化] 生态：如果在产线上有性能极度敏感（成千上万个对象同时在内存）
  // 且不需要打印 Log 调试数据时，关闭 toString() 生成能略微降低包体积与解析负荷
  // toStringOverride: false,
);
