import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject with EquatableMixin {
  CategoryModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.emoji = '📦',
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String eventId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int sortOrder;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final String emoji;

  CategoryModel copyWith({
    String? id,
    String? eventId,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? emoji,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'name': name,
    'sortOrder': sortOrder,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'emoji': emoji,
  };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] as String,
    eventId: json['eventId'] as String,
    name: json['name'] as String,
    sortOrder: json['sortOrder'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    emoji: json['emoji'] as String? ?? '📦',
  );

  @override
  List<Object?> get props => [
    id,
    eventId,
    name,
    sortOrder,
    createdAt,
    updatedAt,
    emoji,
  ];
}
