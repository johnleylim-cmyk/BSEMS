import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums.dart';

/// Announcement model for the news/bulletin board.
class AnnouncementModel {
  final String id;
  final String title;
  final String body;
  final String authorId;
  final String? authorName;
  final AnnouncementPriority priority;
  final String? imageUrl;
  final DateTime createdAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    this.authorName,
    required this.priority,
    this.imageUrl,
    required this.createdAt,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    return AnnouncementModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'],
      priority: AnnouncementPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => AnnouncementPriority.normal,
      ),
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'authorId': authorId,
      'authorName': authorName,
      'priority': priority.name,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
