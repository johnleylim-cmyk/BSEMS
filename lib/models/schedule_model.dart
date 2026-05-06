import 'package:cloud_firestore/cloud_firestore.dart';

/// Schedule entry model for calendar views.
class ScheduleModel {
  final String id;
  final String title;
  final String? matchId;
  final String? tournamentId;
  final DateTime date;
  final String? time;
  final String? venue;
  final String? notes;
  final DateTime createdAt;

  const ScheduleModel({
    required this.id,
    required this.title,
    this.matchId,
    this.tournamentId,
    required this.date,
    this.time,
    this.venue,
    this.notes,
    required this.createdAt,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String id) {
    return ScheduleModel(
      id: id,
      title: map['title'] ?? '',
      matchId: map['matchId'],
      tournamentId: map['tournamentId'],
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: map['time'],
      venue: map['venue'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'matchId': matchId,
      'tournamentId': tournamentId,
      'date': Timestamp.fromDate(date),
      'time': time,
      'venue': venue,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
