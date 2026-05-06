import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums.dart';

/// Team model representing a sports or esports team.
class TeamModel {
  final String id;
  final String name;
  final String sportId;
  final SportType sportType;
  final String? captainId;
  final List<String> memberIds;
  final String? logo;
  final int wins;
  final int losses;
  final int draws;
  final String? description;
  final DateTime createdAt;

  const TeamModel({
    required this.id,
    required this.name,
    required this.sportId,
    required this.sportType,
    this.captainId,
    this.memberIds = const [],
    this.logo,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.description,
    required this.createdAt,
  });

  int get totalGames => wins + losses + draws;
  double get winRate => totalGames > 0 ? (wins / totalGames) * 100 : 0;

  factory TeamModel.fromMap(Map<String, dynamic> map, String id) {
    return TeamModel(
      id: id,
      name: map['name'] ?? '',
      sportId: map['sportId'] ?? '',
      sportType: SportType.values.firstWhere(
        (e) => e.name == map['sportType'],
        orElse: () => SportType.sports,
      ),
      captainId: map['captainId'],
      memberIds: List<String>.from(map['memberIds'] ?? []),
      logo: map['logo'],
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      draws: map['draws'] ?? 0,
      description: map['description'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sportId': sportId,
      'sportType': sportType.name,
      'captainId': captainId,
      'memberIds': memberIds,
      'logo': logo,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  TeamModel copyWith({
    String? name,
    String? sportId,
    SportType? sportType,
    String? captainId,
    List<String>? memberIds,
    String? logo,
    int? wins,
    int? losses,
    int? draws,
    String? description,
  }) {
    return TeamModel(
      id: id,
      name: name ?? this.name,
      sportId: sportId ?? this.sportId,
      sportType: sportType ?? this.sportType,
      captainId: captainId ?? this.captainId,
      memberIds: memberIds ?? this.memberIds,
      logo: logo ?? this.logo,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }
}
