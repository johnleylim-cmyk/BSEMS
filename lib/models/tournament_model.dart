import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums.dart';

/// Tournament model with bracket generation support.
class TournamentModel {
  final String id;
  final String name;
  final String sportId;
  final TournamentFormat format;
  final TournamentStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> teamIds;
  final List<Map<String, dynamic>> bracket;
  final String? rules;
  final String? prizePool;
  final String? venue;
  final String? description;
  final DateTime createdAt;

  const TournamentModel({
    required this.id,
    required this.name,
    required this.sportId,
    required this.format,
    required this.status,
    this.startDate,
    this.endDate,
    this.teamIds = const [],
    this.bracket = const [],
    this.rules,
    this.prizePool,
    this.venue,
    this.description,
    required this.createdAt,
  });

  factory TournamentModel.fromMap(Map<String, dynamic> map, String id) {
    return TournamentModel(
      id: id,
      name: map['name'] ?? '',
      sportId: map['sportId'] ?? '',
      format: TournamentFormat.values.firstWhere(
        (e) => e.name == map['format'],
        orElse: () => TournamentFormat.singleElimination,
      ),
      status: TournamentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TournamentStatus.draft,
      ),
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      teamIds: List<String>.from(map['teamIds'] ?? []),
      bracket: List<Map<String, dynamic>>.from(
        (map['bracket'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
      rules: map['rules'],
      prizePool: map['prizePool'],
      venue: map['venue'],
      description: map['description'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sportId': sportId,
      'format': format.name,
      'status': status.name,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'teamIds': teamIds,
      'bracket': bracket,
      'rules': rules,
      'prizePool': prizePool,
      'venue': venue,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  TournamentModel copyWith({
    String? name,
    String? sportId,
    TournamentFormat? format,
    TournamentStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? teamIds,
    List<Map<String, dynamic>>? bracket,
    String? rules,
    String? prizePool,
    String? venue,
    String? description,
  }) {
    return TournamentModel(
      id: id,
      name: name ?? this.name,
      sportId: sportId ?? this.sportId,
      format: format ?? this.format,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      teamIds: teamIds ?? this.teamIds,
      bracket: bracket ?? this.bracket,
      rules: rules ?? this.rules,
      prizePool: prizePool ?? this.prizePool,
      venue: venue ?? this.venue,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }
}
