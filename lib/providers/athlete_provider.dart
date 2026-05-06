import 'dart:async';
import 'package:flutter/material.dart';
import '../models/athlete_model.dart';
import '../services/firestore_service.dart';

/// Athlete state provider with real-time streaming.
class AthleteProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<AthleteModel> _athletes = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _sub;

  List<AthleteModel> get athletes => _athletes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _athletes.length;

  /// Start streaming athletes from Firestore.
  void startListening() {
    _isLoading = true;
    notifyListeners();

    _sub = _service.streamAthletes().listen(
      (data) {
        _athletes = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Add a new athlete.
  Future<String> addAthlete(AthleteModel athlete) async {
    try {
      final id = await _service.addAthlete(athlete);
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Update an athlete.
  Future<void> updateAthlete(String id, Map<String, dynamic> data) async {
    try {
      await _service.updateAthlete(id, data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete an athlete.
  Future<void> deleteAthlete(String id) async {
    try {
      await _service.deleteAthlete(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
