import 'dart:async';
import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../services/firestore_service.dart';

/// Team state provider with real-time streaming.
class TeamProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<TeamModel> _teams = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _sub;

  List<TeamModel> get teams => _teams;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _teams.length;

  /// Look up a team's logo by its ID. Returns null if not found.
  String? getLogoForTeam(String? teamId) {
    if (teamId == null) return null;
    for (final team in _teams) {
      if (team.id == teamId) return team.logo;
    }
    return null;
  }

  void startListening() {
    _isLoading = true;
    notifyListeners();

    _sub = _service.streamTeams().listen(
      (data) {
        _teams = data;
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

  Future<String> addTeam(TeamModel team) async {
    try {
      return await _service.addTeam(team);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTeam(String id, Map<String, dynamic> data) async {
    try {
      await _service.updateTeam(id, data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTeam(String id) async {
    try {
      await _service.deleteTeam(id);
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
