import 'package:cloud_firestore/cloud_firestore.dart';

/// Venue model for sports facilities and locations.
class VenueModel {
  final String id;
  final String name;
  final String? address;
  final int? capacity;
  final String? type;
  final List<String> facilities;
  final String? imageUrl;
  final String? notes;
  final DateTime createdAt;

  const VenueModel({
    required this.id,
    required this.name,
    this.address,
    this.capacity,
    this.type,
    this.facilities = const [],
    this.imageUrl,
    this.notes,
    required this.createdAt,
  });

  factory VenueModel.fromMap(Map<String, dynamic> map, String id) {
    return VenueModel(
      id: id,
      name: map['name'] ?? '',
      address: map['address'],
      capacity: map['capacity'],
      type: map['type'],
      facilities: List<String>.from(map['facilities'] ?? []),
      imageUrl: map['imageUrl'],
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'capacity': capacity,
      'type': type,
      'facilities': facilities,
      'imageUrl': imageUrl,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
