import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_json_sanitizer/src/annotations.dart';

class SchemaGenerator extends GeneratorForAnnotation<GenerateSchema> {
  final _schemaAnnotationChecker =
      const TypeChecker.fromRuntime(GenerateSchema);

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          '`@GenerateSchema` can only be used on classes.',
          element: element);
    }

    final className = element.name;
    final buffer = StringBuffer();

    // --- START: 全新的、更通用的字段发现逻辑 ---

    // 定义一个列表来存储我们找到的“字段”信息
    final fieldsToProcess = <_FieldInfo>[];

    // 策略1: 检查是否存在 Freezed 风格的默认工厂构造函数
    final factoryConstructor = element.unnamedConstructor;
    if (factoryConstructor != null && factoryConstructor.isFactory) {
      // 这是 Freezed 模型，我们遍历其构造函数参数
      for (final param in factoryConstructor.parameters) {
        fieldsToProcess.add(_FieldInfo.fromParameter(param));
      }
    } else {
      // 策略2: 这是普通的Dart模型，我们遍历其公开的实例字段
      for (final field in element.fields) {
        // 忽略静态字段或私有字段
        if (!field.isStatic && field.isPublic) {
          fieldsToProcess.add(_FieldInfo.fromField(field));
        }
      }
    }

    if (fieldsToProcess.isEmpty) {
      throw InvalidGenerationSourceError(
        'Could not find any fields or factory constructor parameters to process for class `${element.name}`.',
        element: element,
      );
    }
    // --- END: 全新的逻辑 ---

    // 生成公开的变量名
    buffer.writeln('const Map<String, dynamic> \$${className}Schema = {');

    // 现在，我们遍历这个统一的 `fieldsToProcess` 列表
    for (final fieldInfo in fieldsToProcess) {
      // 从 _FieldInfo 对象中获取信息
      final jsonKey = fieldInfo.getJsonKeyName();
      final schemaValue = _getSchemaValueForType(fieldInfo.type);

      buffer.writeln("  '$jsonKey': $schemaValue,");
    }

    buffer.writeln('};');
    return buffer.toString();
  }

  String _getSchemaValueForType(DartType type) {
    if (type.element == null) return 'dynamic';

    if (type.isDartCoreInt ||
        type.isDartCoreString ||
        type.isDartCoreDouble ||
        type.isDartCoreBool ||
        type.isDartCoreObject) {
      final typeString = type.getDisplayString(withNullability: true);
      return typeString.endsWith('?')
          ? typeString.substring(0, typeString.length - 1)
          : typeString;
    }

    if (type.isDartCoreList) {
      if ((type as InterfaceType).typeArguments.isNotEmpty) {
        return 'ListSchema(${_getSchemaValueForType(type.typeArguments.first)})';
      }
      return 'ListSchema(dynamic)';
    }

    if (type.isDartCoreMap) {
      if ((type as InterfaceType).typeArguments.length == 2) {
        return 'MapSchema(${_getSchemaValueForType(type.typeArguments[1])})';
      }
      return 'MapSchema(dynamic)';
    }

    final element = type.element;
    if (element is ClassElement &&
        _schemaAnnotationChecker.hasAnnotationOf(element)) {
      // --- CRITICAL FIX 2: Reference the PUBLIC variable name ---
      // Change from `_$${element.name}Schema` to `$${element.name}Schema`
      return '\$${element.name}Schema';
    }

    return 'dynamic';
  }
}

// 我们需要一个新的辅助类来统一“字段”和“参数”的信息
class _FieldInfo {
  final Element element; // 可以是 FieldElement 或 ParameterElement
  final String name;
  final DartType type;

  _FieldInfo({required this.element, required this.name, required this.type});

  factory _FieldInfo.fromField(FieldElement field) {
    return _FieldInfo(element: field, name: field.name, type: field.type);
  }

  factory _FieldInfo.fromParameter(ParameterElement param) {
    return _FieldInfo(element: param, name: param.name, type: param.type);
  }

  // 统一获取 @JsonKey 注解的逻辑
  String getJsonKeyName() {
    const checker = TypeChecker.fromRuntime(JsonKey);
    final annotation = checker.firstAnnotationOf(element);
    if (annotation != null) {
      final nameReader = ConstantReader(annotation).read('name');
      if (nameReader.isString) {
        return nameReader.stringValue;
      }
    }
    return name;
  }
}
