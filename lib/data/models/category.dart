import 'package:equatable/equatable.dart';

/// 分类模型
class Category extends Equatable {
  /// 分类 ID
  final int? id;

  /// 分类名称
  final String name;

  /// 分类图标名称
  final String icon;

  /// 分类颜色值
  final int colorValue;

  /// 创建时间
  final DateTime? createdAt;

  const Category({
    this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    this.createdAt,
  });

  /// 从数据库 Map 创建 Category
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      colorValue: map['color_value'] as int,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon': icon,
      'color_value': colorValue,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// 复制并修改字段
  Category copyWith({
    int? id,
    String? name,
    String? icon,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, colorValue, createdAt];

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, colorValue: $colorValue)';
  }
}
