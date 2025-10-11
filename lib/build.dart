// flutter_json_sanitizer/build.dart
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:flutter_json_sanitizer/src/builder/schema_generator.dart';

Builder schemaBuilder(BuilderOptions options) {
  return PartBuilder([SchemaGenerator()], '.schema.g.dart');
}