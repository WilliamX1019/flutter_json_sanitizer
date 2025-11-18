// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_demo_model.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

const Map<String, dynamic> $TestDemoModelSchema = {
  'userId': int,
  'name': String,
  'isActive': bool,
  'tags': ListSchema(
    itemType: String,
    itemSchema: String,
  ),
  'permissions': $PermissionsSchema,
  'mainProduct': $MainProductSchema,
};

const Map<String, dynamic> $MainProductSchema = {
  'productId': int,
  'name': String,
};

const Map<String, dynamic> $PermissionsSchema = {
  'read': int,
  'write': int,
  'admin': int,
};
