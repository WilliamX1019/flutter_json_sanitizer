/// 一个标记，用于描述一个列表的期望结构。
/// [itemSchema] 可以是基础类型(int), 另一个Schema Map, 甚至是另一个ListSchema。
class ListSchema {  /// 列表中每个元素的 Dart 类型（可以是 int/String/ModelClass 等）
  final Type? itemType;
  final dynamic itemSchema;
  const ListSchema({
    this.itemType,
    required this.itemSchema,
  });
}

/// 一个标记，用于描述一个Map的期望结构。
/// JSON的key几乎总是String，所以我们只关心值的类型。
class MapSchema {
  final dynamic valueSchema;
  const MapSchema({
    this.valueSchema,
  });
}