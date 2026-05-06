import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums.dart';

/// Match model — individual game within a tournament.
class MatchModel {
  final String id;
  final String? tournamentId;
  final int round;
  final int matchNumber;
  final String? team1Id;
  final String? team2Id;
  final String? team1Name;
  final String? team2Name;
  final int score1;
  final int score2;
  final String? winnerId;
  final MatchStatus status;
  final DateTime? scheduledAt;
  final String? venue;
  final String? notes;
  /// For double elimination: 'winners', 'losers', or 'grand_finals'.
  final String? bracketType;
  /// Winner routing target for generated brackets.
  final String? nextMatchId;
  final int? nextMatchSlot;
  /// Loser routing target for double-elimination winners-bracket matches.
  final String? loserNextMatchId;
  final int? loserNextMatchSlot;
  final DateTime createdAt;

  const MatchModel({
    required this.id,
    this.tournamentId,
    this.round = 1,
    this.matchNumber = 1,
    this.team1Id,
    this.team2Id,
    this.team1Name,
    this.team2Name,
    this.score1 = 0,
    this.score2 = 0,
    this.winnerId,
    required this.status,
    this.scheduledAt,
    this.venue,
    this.notes,
    this.bracketType,
    this.nextMatchId,
    this.nextMatchSlot,
    this.loserNextMatchId,
    this.loserNextMatchSlot,
    required this.createdAt,
  });

  static int? _intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  factory MatchModel.fromMap(Map<String, dynamic> map, String id) {
    return MatchModel(
      id: id,
      tournamentId: map['tournamentId'],
      round: map['round'] ?? 1,
      matchNumber: map['matchNumber'] ?? 1,
      team1Id: map['team1Id'],
      team2Id: map['team2Id'],
      team1Name: map['team1Name'],
      team2Name: map['team2Name'],
      score1: map['score1'] ?? 0,
      score2: map['score2'] ?? 0,
      winnerId: map['winnerId'],
      status: MatchStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MatchStatus.scheduled,
      ),
      scheduledAt: (map['scheduledAt'] as Timestamp?)?.toDate(),
      venue: map['venue'],
      notes: map['notes'],
      bracketType: map['bracketType'],
      nextMatchId: map['nextMatchId'],
      nextMatchSlot: _intOrNull(map['nextMatchSlot']),
      loserNextMatchId: map['loserNextMatchId'],
      loserNextMatchSlot: _intOrNull(map['loserNextMatchSlot']),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tournamentId': tournamentId,
      'round': round,
      'matchNumber': matchNumber,
      'team1Id': team1Id,
      'team2Id': team2Id,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'score1': score1,
      'score2': score2,
      'winnerId': winnerId,
      'status': status.name,
      'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      'venue': venue,
      'notes': notes,
      'bracketType': bracketType,
      'nextMatchId': nextMatchId,
      'nextMatchSlot': nextMatchSlot,
      'loserNextMatchId': loserNextMatchId,
      'loserNextMatchSlot': loserNextMatchSlot,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  MatchModel copyWith({
    String? tournamentId,
    int? round,
    int? matchNumber,
    String? team1Id,
    String? team2Id,
    String? team1Name,
    String? team2Name,
    int? score1,
    int? score2,
    String? winnerId,
    MatchStatus? status,
    DateTime? scheduledAt,
    String? venue,
    String? notes,
    String? bracketType,
    String? nextMatchId,
    int? nextMatchSlot,
    String? loserNextMatchId,
    int? loserNextMatchSlot,
  }) {
    return MatchModel(
      id: id,
      tournamentId: tournamentId ?? this.tournamentId,
      round: round ?? this.round,
      matchNumber: matchNumber ?? this.matchNumber,
      team1Id: team1Id ?? this.team1Id,
      team2Id: team2Id ?? this.team2Id,
      team1Name: team1Name ?? this.team1Name,
      team2Name: team2Name ?? this.team2Name,
      score1: score1 ?? this.score1,
      score2: score2 ?? this.score2,
      winnerId: winnerId ?? this.winnerId,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      venue: venue ?? this.venue,
      notes: notes ?? this.notes,
      bracketType: bracketType ?? this.bracketType,
      nextMatchId: nextMatchId ?? this.nextMatchId,
      nextMatchSlot: nextMatchSlot ?? this.nextMatchSlot,
      loserNextMatchId: loserNextMatchId ?? this.loserNextMatchId,
      loserNextMatchSlot: loserNextMatchSlot ?? this.loserNextMatchSlot,
      createdAt: createdAt,
    );
  }
}
