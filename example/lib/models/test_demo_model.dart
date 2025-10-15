// To parse this JSON data, do
//
//     final testDemoModel = testDemoModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_json_sanitizer/flutter_json_sanitizer.dart';

part 'test_demo_model.schema.g.dart';

TestDemoModel testDemoModelFromJson(String str) => TestDemoModel.fromJson(json.decode(str));

String testDemoModelToJson(TestDemoModel data) => json.encode(data.toJson());

@generateSchema
class TestDemoModel {
    int? userId;
    String? name;
    bool? isActive;
    List<String>? tags;
    Permissions? permissions;
    MainProduct? mainProduct;
    // Metadata? metadata;

    TestDemoModel({
        this.userId,
        this.name,
        this.isActive,
        this.tags,
        this.permissions,
        this.mainProduct,
        // this.metadata,
    });

    factory TestDemoModel.fromJson(Map<String, dynamic> json) => TestDemoModel(
        userId: json["user_id"],
        name: json["name"],
        isActive: json["is_active"],
        tags: json["tags"] == null ? [] : List<String>.from(json["tags"]!.map((x) => x)),
        permissions: json["permissions"] == null ? null : Permissions.fromJson(json["permissions"]),
        mainProduct: json["mainProduct"] == null ? null : MainProduct.fromJson(json["mainProduct"]),
        // metadata: json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "is_active": isActive,
        "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
        "permissions": permissions?.toJson(),
        "mainProduct": mainProduct?.toJson(),
        // "metadata": metadata?.toJson(),
    };
}
@generateSchema
class MainProduct {
    int? productId;
    String? name;

    MainProduct({
        this.productId,
        this.name,
    });

    factory MainProduct.fromJson(Map<String, dynamic> json) => MainProduct(
        productId: json["product_id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "product_id": productId,
        "name": name,
    };
}
// @generateSchema
// class Metadata {
//     Metadata();

//     factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
//     );

//     Map<String, dynamic> toJson() => {
//     };
// }
@generateSchema
class Permissions {
    int? read;
    int? write;
    int? admin;

    Permissions({
        this.read,
        this.write,
        this.admin,
    });

    factory Permissions.fromJson(Map<String, dynamic> json) => Permissions(
        read: json["read"],
        write: json["write"],
        admin: json["admin"],
    );

    Map<String, dynamic> toJson() => {
        "read": read,
        "write": write,
        "admin": admin,
    };
}
