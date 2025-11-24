/// 通用安全扩展方法
/// 用于将可空的基本数据类型安全地转换为非空类型，避免空指针异常。

extension SafeString on String? {
  /// 如果为 null，返回空字符串 ""
  String get orEmpty => this ?? '';
}

extension SafeInt on int? {
  /// 如果为 null，返回 0
  int get orZero => this ?? 0;
}

extension SafeDouble on double? {
  /// 如果为 null，返回 0.0
  double get orZero => this ?? 0.0;
}

extension SafeNum on num? {
  /// 如果为 null，返回 0
  num get orZero => this ?? 0;
}

extension SafeBool on bool? {
  /// 如果为 null，返回 false
  bool get orFalse => this ?? false;

  /// 如果为 null，返回 true
  bool get orTrue => this ?? true;
}

extension SafeList<T> on List<T>? {
  /// 如果为 null，返回空列表 []
  List<T> get orEmpty => this ?? const [];

  /// 安全获取长度，如果为 null 返回 0
  int get count => this?.length ?? 0;
}

extension SafeMap<K, V> on Map<K, V>? {
  /// 如果为 null，返回空 Map {}
  Map<K, V> get orEmpty => this ?? const {};

  /// 安全获取长度，如果为 null 返回 0
  int get count => this?.length ?? 0;
}
