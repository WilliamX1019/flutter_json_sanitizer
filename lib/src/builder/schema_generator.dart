import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_json_sanitizer/src/annotations.dart';
import 'package:flutter_json_sanitizer/src/schema_helpers.dart';

class SchemaGenerator extends GeneratorForAnnotation<GenerateSchema> {
  final _schemaAnnotationChecker = const TypeChecker.fromRuntime(GenerateSchema);
  final _jsonKeyChecker = const TypeChecker.fromRuntime(JsonKey);

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          '`@GenerateSchema` can only be used on classes.',
          element: element);
    }

    final className = element.name;
    final constructor = element.unnamedConstructor;

    if (constructor == null || !constructor.isFactory) {
      throw InvalidGenerationSourceError(
        'Could not find a default factory constructor on `${element.name}`. The @generateSchema annotation is designed to work with freezed classes.',
        element: element,
      );
    }
    
    final buffer = StringBuffer();
    // --- CRITICAL FIX 1: Generate a PUBLIC variable name ---
    // Change from `_$${className}Schema` to `$${className}Schema`
    buffer.writeln('const Map<String, dynamic> \$${className}Schema = {');

    for (final param in constructor.parameters) {
      String jsonKey = param.name;
      final jsonKeyAnnotation = _jsonKeyChecker.firstAnnotationOf(param);
      if (jsonKeyAnnotation != null) {
        final nameReader = ConstantReader(jsonKeyAnnotation).read('name');
        if (nameReader.isString) {
          jsonKey = nameReader.stringValue;
        }
      }

      final schemaValue = _getSchemaValueForType(param.type);
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
      final typeString = type.getDisplayString();
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
    if (element is ClassElement && _schemaAnnotationChecker.hasAnnotationOf(element)) {
      // --- CRITICAL FIX 2: Reference the PUBLIC variable name ---
      // Change from `_$${element.name}Schema` to `$${element.name}Schema`
      return '\$${element.name}Schema';
    }

    return 'dynamic';
  }
}