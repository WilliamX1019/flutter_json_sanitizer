// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// SchemaGenerator
// **************************************************************************

const Map<String, dynamic> $UserProfileSchema = {
  'user_id': int,
  'name': String,
  'is_active': bool,
  'tags': ListSchema(String),
  'permissions': $PermissionsSchema,
  'mainProduct': $MainProductSchema,
  'metadata': $MetadataSchema,
};

const Map<String, dynamic> $MainProductSchema = {
  'product_id': int,
  'name': String,
};

const Map<String, dynamic> $MetadataSchema = {};

const Map<String, dynamic> $PermissionsSchema = {
  'read': int,
  'write': int,
  'admin': int,
};
