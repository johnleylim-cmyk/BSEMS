import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums.dart';

/// Athlete / player profile model.
class AthleteModel {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final Gender gender;
  final String barangay;
  final List<String> sportIds;
  final List<String> teamIds;
  final String? photoUrl;
  final String? contactNumber;
  final String? email;
  final Map<String, dynamic> stats;
  final DateTime createdAt;

  const AthleteModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.barangay,
    this.sportIds = const [],
    this.teamIds = const [],
    this.photoUrl,
    this.contactNumber,
    this.email,
    this.stats = const {},
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory AthleteModel.fromMap(Map<String, dynamic> map, String id) {
    return AthleteModel(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      age: map['age'] ?? 0,
      gender: Gender.values.firstWhere(
        (e) => e.name == map['gender'],
        orElse: () => Gender.other,
      ),
      barangay: map['barangay'] ?? '',
      sportIds: List<String>.from(map['sportIds'] ?? []),
      teamIds: List<String>.from(map['teamIds'] ?? []),
      photoUrl: map['photoUrl'],
      contactNumber: map['contactNumber'],
      email: map['email'],
      stats: Map<String, dynamic>.from(map['stats'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'gender': gender.name,
      'barangay': barangay,
      'sportIds': sportIds,
      'teamIds': teamIds,
      'photoUrl': photoUrl,
      'contactNumber': contactNumber,
      'email': email,
      'stats': stats,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  AthleteModel copyWith({
    String? firstName,
    String? lastName,
    int? age,
    Gender? gender,
    String? barangay,
    List<String>? sportIds,
    List<String>? teamIds,
    String? photoUrl,
    String? contactNumber,
    String? email,
    Map<String, dynamic>? stats,
  }) {
    return AthleteModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      barangay: barangay ?? this.barangay,
      sportIds: sportIds ?? this.sportIds,
      teamIds: teamIds ?? this.teamIds,
      photoUrl: photoUrl ?? this.photoUrl,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      stats: stats ?? this.stats,
      createdAt: createdAt,
    );
  }
}
