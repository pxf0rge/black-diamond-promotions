import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 0)
class EventModel extends HiveObject with EquatableMixin {
  EventModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String location;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  EventModel copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'description': description,
    'date': date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    id: json['id'] as String,
    name: json['name'] as String,
    location: json['location'] as String,
    description: json['description'] as String,
    date: DateTime.parse(json['date'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    description,
    date,
    createdAt,
    updatedAt,
  ];
}
