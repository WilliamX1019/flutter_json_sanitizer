import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

/// 一个用于在 JSON 对象和 TransferableTypedData 之间进行转换的工具类。
///
/// 这在需要在 Isolate 之间高效传递 JSON 数据时非常有用。
class JsonTransferableUtils {
  // 私有构造函数，防止该类被实例化。
  JsonTransferableUtils._();

  /// 将一个 JSON 对象（Map 或 List）编码为 TransferableTypedData。
  ///
  /// [jsonData] 是要被编码的 Dart 对象，通常是 Map<String, dynamic> 或 List<dynamic>。
  /// 返回一个可以被发送到另一个 Isolate 的 [TransferableTypedData] 对象。
  static TransferableTypedData encode(Object jsonData) {
    // 1. 使用 dart:convert 将对象编码为 JSON 字符串。
    final String jsonString = jsonEncode(jsonData);

    // 2. 将 JSON 字符串编码为 UTF-8 字节列表。
    final List<int> utf8Bytes = utf8.encode(jsonString);

    // 3. 从字节列表创建 Uint8List。
    final Uint8List uint8list = Uint8List.fromList(utf8Bytes);

    // 4. 创建并返回 TransferableTypedData。
    //    注意：fromList 期望一个 List<TypedData>，所以我们将 Uint8List 放在一个列表中。
    return TransferableTypedData.fromList([uint8list]);
  }

  /// 将从 Isolate 接收到的 TransferableTypedData 解码回 JSON 对象。
  ///
  /// [transferableData] 是从其他 Isolate 接收到的数据。
  /// 返回一个动态类型的对象 (dynamic)，你需要根据实际情况将其转换为具体的类型，
  /// 例如 `as Map<String, dynamic>`。
  static dynamic decode(TransferableTypedData transferableData) {
    // 1. 将 TransferableTypedData 物化为 ByteBuffer 以访问其内容。
    final ByteBuffer buffer = transferableData.materialize();

    // 2. 将 ByteBuffer 视图转换为 Uint8List。
    //    这里不需要拷贝数据，asUint8List() 只是创建了一个视图。
    final Uint8List receivedUint8List = buffer.asUint8List();

    // 3. 将 UTF-8 字节解码为 JSON 字符串。
    final String jsonString = utf8.decode(receivedUint8List);

    // 4. 将 JSON 字符串解码回原始的 Dart 对象。
    return jsonDecode(jsonString);
  }
}