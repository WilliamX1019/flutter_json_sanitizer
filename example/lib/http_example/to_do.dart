import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';
import 'package:json_annotation/json_annotation.dart';
part 'to_do.g.dart';
part 'to_do.schema.g.dart';

@JsonSerializable()
@GenerateSchema()
class Todo {
  final int id;
  final String title;
  final bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
  Map<String, dynamic> toJson() => _$TodoToJson(this);
}
