// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductListModel _$ProductListModelFromJson(Map<String, dynamic> json) {
  return _ProductListModel.fromJson(json);
}

/// @nodoc
mixin _$ProductListModel {
  @JsonKey(name: "list")
  List<ProductModel>? get list => throw _privateConstructorUsedError;
  @JsonKey(name: "paginate")
  Paginate? get paginate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductListModelCopyWith<ProductListModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductListModelCopyWith<$Res> {
  factory $ProductListModelCopyWith(
          ProductListModel value, $Res Function(ProductListModel) then) =
      _$ProductListModelCopyWithImpl<$Res, ProductListModel>;
  @useResult
  $Res call(
      {@JsonKey(name: "list") List<ProductModel>? list,
      @JsonKey(name: "paginate") Paginate? paginate});

  $PaginateCopyWith<$Res>? get paginate;
}

/// @nodoc
class _$ProductListModelCopyWithImpl<$Res, $Val extends ProductListModel>
    implements $ProductListModelCopyWith<$Res> {
  _$ProductListModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? list = freezed,
    Object? paginate = freezed,
  }) {
    return _then(_value.copyWith(
      list: freezed == list
          ? _value.list
          : list // ignore: cast_nullable_to_non_nullable
              as List<ProductModel>?,
      paginate: freezed == paginate
          ? _value.paginate
          : paginate // ignore: cast_nullable_to_non_nullable
              as Paginate?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PaginateCopyWith<$Res>? get paginate {
    if (_value.paginate == null) {
      return null;
    }

    return $PaginateCopyWith<$Res>(_value.paginate!, (value) {
      return _then(_value.copyWith(paginate: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductListModelImplCopyWith<$Res>
    implements $ProductListModelCopyWith<$Res> {
  factory _$$ProductListModelImplCopyWith(_$ProductListModelImpl value,
          $Res Function(_$ProductListModelImpl) then) =
      __$$ProductListModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "list") List<ProductModel>? list,
      @JsonKey(name: "paginate") Paginate? paginate});

  @override
  $PaginateCopyWith<$Res>? get paginate;
}

/// @nodoc
class __$$ProductListModelImplCopyWithImpl<$Res>
    extends _$ProductListModelCopyWithImpl<$Res, _$ProductListModelImpl>
    implements _$$ProductListModelImplCopyWith<$Res> {
  __$$ProductListModelImplCopyWithImpl(_$ProductListModelImpl _value,
      $Res Function(_$ProductListModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? list = freezed,
    Object? paginate = freezed,
  }) {
    return _then(_$ProductListModelImpl(
      list: freezed == list
          ? _value._list
          : list // ignore: cast_nullable_to_non_nullable
              as List<ProductModel>?,
      paginate: freezed == paginate
          ? _value.paginate
          : paginate // ignore: cast_nullable_to_non_nullable
              as Paginate?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductListModelImpl implements _ProductListModel {
  const _$ProductListModelImpl(
      {@JsonKey(name: "list") final List<ProductModel>? list,
      @JsonKey(name: "paginate") this.paginate})
      : _list = list;

  factory _$ProductListModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductListModelImplFromJson(json);

  final List<ProductModel>? _list;
  @override
  @JsonKey(name: "list")
  List<ProductModel>? get list {
    final value = _list;
    if (value == null) return null;
    if (_list is EqualUnmodifiableListView) return _list;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "paginate")
  final Paginate? paginate;

  @override
  String toString() {
    return 'ProductListModel(list: $list, paginate: $paginate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductListModelImpl &&
            const DeepCollectionEquality().equals(other._list, _list) &&
            (identical(other.paginate, paginate) ||
                other.paginate == paginate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_list), paginate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductListModelImplCopyWith<_$ProductListModelImpl> get copyWith =>
      __$$ProductListModelImplCopyWithImpl<_$ProductListModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductListModelImplToJson(
      this,
    );
  }
}

abstract class _ProductListModel implements ProductListModel {
  const factory _ProductListModel(
          {@JsonKey(name: "list") final List<ProductModel>? list,
          @JsonKey(name: "paginate") final Paginate? paginate}) =
      _$ProductListModelImpl;

  factory _ProductListModel.fromJson(Map<String, dynamic> json) =
      _$ProductListModelImpl.fromJson;

  @override
  @JsonKey(name: "list")
  List<ProductModel>? get list;
  @override
  @JsonKey(name: "paginate")
  Paginate? get paginate;
  @override
  @JsonKey(ignore: true)
  _$$ProductListModelImplCopyWith<_$ProductListModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Paginate _$PaginateFromJson(Map<String, dynamic> json) {
  return _Paginate.fromJson(json);
}

/// @nodoc
mixin _$Paginate {
  @JsonKey(name: "page")
  int? get page => throw _privateConstructorUsedError;
  @JsonKey(name: "total_page")
  int? get totalPage => throw _privateConstructorUsedError;
  @JsonKey(name: "total")
  int? get total => throw _privateConstructorUsedError;
  @JsonKey(name: "limit")
  int? get limit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaginateCopyWith<Paginate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginateCopyWith<$Res> {
  factory $PaginateCopyWith(Paginate value, $Res Function(Paginate) then) =
      _$PaginateCopyWithImpl<$Res, Paginate>;
  @useResult
  $Res call(
      {@JsonKey(name: "page") int? page,
      @JsonKey(name: "total_page") int? totalPage,
      @JsonKey(name: "total") int? total,
      @JsonKey(name: "limit") int? limit});
}

/// @nodoc
class _$PaginateCopyWithImpl<$Res, $Val extends Paginate>
    implements $PaginateCopyWith<$Res> {
  _$PaginateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? totalPage = freezed,
    Object? total = freezed,
    Object? limit = freezed,
  }) {
    return _then(_value.copyWith(
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      totalPage: freezed == totalPage
          ? _value.totalPage
          : totalPage // ignore: cast_nullable_to_non_nullable
              as int?,
      total: freezed == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaginateImplCopyWith<$Res>
    implements $PaginateCopyWith<$Res> {
  factory _$$PaginateImplCopyWith(
          _$PaginateImpl value, $Res Function(_$PaginateImpl) then) =
      __$$PaginateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "page") int? page,
      @JsonKey(name: "total_page") int? totalPage,
      @JsonKey(name: "total") int? total,
      @JsonKey(name: "limit") int? limit});
}

/// @nodoc
class __$$PaginateImplCopyWithImpl<$Res>
    extends _$PaginateCopyWithImpl<$Res, _$PaginateImpl>
    implements _$$PaginateImplCopyWith<$Res> {
  __$$PaginateImplCopyWithImpl(
      _$PaginateImpl _value, $Res Function(_$PaginateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? totalPage = freezed,
    Object? total = freezed,
    Object? limit = freezed,
  }) {
    return _then(_$PaginateImpl(
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      totalPage: freezed == totalPage
          ? _value.totalPage
          : totalPage // ignore: cast_nullable_to_non_nullable
              as int?,
      total: freezed == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PaginateImpl implements _Paginate {
  const _$PaginateImpl(
      {@JsonKey(name: "page") this.page,
      @JsonKey(name: "total_page") this.totalPage,
      @JsonKey(name: "total") this.total,
      @JsonKey(name: "limit") this.limit});

  factory _$PaginateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginateImplFromJson(json);

  @override
  @JsonKey(name: "page")
  final int? page;
  @override
  @JsonKey(name: "total_page")
  final int? totalPage;
  @override
  @JsonKey(name: "total")
  final int? total;
  @override
  @JsonKey(name: "limit")
  final int? limit;

  @override
  String toString() {
    return 'Paginate(page: $page, totalPage: $totalPage, total: $total, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginateImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.totalPage, totalPage) ||
                other.totalPage == totalPage) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, page, totalPage, total, limit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginateImplCopyWith<_$PaginateImpl> get copyWith =>
      __$$PaginateImplCopyWithImpl<_$PaginateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaginateImplToJson(
      this,
    );
  }
}

abstract class _Paginate implements Paginate {
  const factory _Paginate(
      {@JsonKey(name: "page") final int? page,
      @JsonKey(name: "total_page") final int? totalPage,
      @JsonKey(name: "total") final int? total,
      @JsonKey(name: "limit") final int? limit}) = _$PaginateImpl;

  factory _Paginate.fromJson(Map<String, dynamic> json) =
      _$PaginateImpl.fromJson;

  @override
  @JsonKey(name: "page")
  int? get page;
  @override
  @JsonKey(name: "total_page")
  int? get totalPage;
  @override
  @JsonKey(name: "total")
  int? get total;
  @override
  @JsonKey(name: "limit")
  int? get limit;
  @override
  @JsonKey(ignore: true)
  _$$PaginateImplCopyWith<_$PaginateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
