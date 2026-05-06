import 'package:cloud_firestore/cloud_firestore.dart';

/// Leaderboard entry for ranking athletes/teams.
class LeaderboardEntryModel {
  final String id;
  final String? athleteId;
  final String? teamId;
  final String? sportId;
  final String? tournamentId;
  final String displayName;
  final int points;
  final int wins;
  final int losses;
  final int draws;
  final int rank;
  final DateTime createdAt;

  const LeaderboardEntryModel({
    required this.id,
    this.athleteId,
    this.teamId,
    this.sportId,
    this.tournamentId,
    required this.displayName,
    this.points = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.rank = 0,
    required this.createdAt,
  });

  int get totalGames => wins + losses + draws;
  double get winRate => totalGames > 0 ? (wins / totalGames) * 100 : 0;

  factory LeaderboardEntryModel.fromMap(Map<String, dynamic> map, String id) {
    return LeaderboardEntryModel(
      id: id,
      athleteId: map['athleteId'],
      teamId: map['teamId'],
      sportId: map['sportId'],
      tournamentId: map['tournamentId'],
      displayName: map['displayName'] ?? '',
      points: map['points'] ?? 0,
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      draws: map['draws'] ?? 0,
      rank: map['rank'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'athleteId': athleteId,
      'teamId': teamId,
      'sportId': sportId,
      'tournamentId': tournamentId,
      'displayName': displayName,
      'points': points,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'rank': rank,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
