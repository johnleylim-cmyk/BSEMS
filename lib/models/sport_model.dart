import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums.dart';

/// Sport / Game model — supports both traditional sports and esports.
class SportModel {
  final String id;
  final String name;
  final SportType type;
  final String? icon;
  final int maxTeamSize;
  final String? description;
  final String? rules;
  final DateTime createdAt;

  const SportModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.maxTeamSize = 5,
    this.description,
    this.rules,
    required this.createdAt,
  });

  factory SportModel.fromMap(Map<String, dynamic> map, String id) {
    return SportModel(
      id: id,
      name: map['name'] ?? '',
      type: SportType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SportType.sports,
      ),
      icon: map['icon'],
      maxTeamSize: map['maxTeamSize'] ?? 5,
      description: map['description'],
      rules: map['rules'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      'icon': icon,
      'maxTeamSize': maxTeamSize,
      'description': description,
      'rules': rules,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
