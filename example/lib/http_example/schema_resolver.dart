/// A static registry to map Types to their JsonSanitizer schemas.
/// This allows avoids passing the full schema object in every API call.
class SchemaResolver {
  static final Map<Type, Map<String, dynamic>> _registry = {};

  /// Register a schema for a specific model Type.
  static void register(Type type, Map<String, dynamic> schema) {
    _registry[type] = schema;
  }

  /// Retrieve a registered schema for a Type.
  static Map<String, dynamic>? get(Type type) {
    return _registry[type];
  }
}
