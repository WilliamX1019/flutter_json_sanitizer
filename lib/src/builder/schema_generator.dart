import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_json_sanitizer/src/annotations.dart';

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
    final buffer = StringBuffer();

    // --- START OF THE CRITICAL FIX ---
    // For freezed classes, the properties are defined in the default factory
    // constructor's parameters, not as class fields. We must find that constructor.
    final constructor = element.unnamedConstructor;

    if (constructor == null || !constructor.isFactory) {
      throw InvalidGenerationSourceError(
        'Could not find a default factory constructor on `${element.name}`. The @generateSchema annotation is designed to work with freezed classes.',
        element: element,
      );
    }
    // --- END OF THE CRITICAL FIX ---


    buffer.writeln('const Map<String, dynamic> _\$${className}Schema = {');

    // --- THE MAIN LOOP IS NOW CORRECT ---
    // We iterate over constructor parameters, not class fields.
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
    // --- END OF THE CORRECTED LOOP ---

    buffer.writeln('};');
    return buffer.toString();
  }
  
  // This helper method remains unchanged and correct.
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
      return '_\$${element.name}Schema';
    }

    return 'dynamic';
  }
}