import 'dart:async';

import 'package:flutter/material.dart';

import '../core/bracket_generator.dart';
import '../core/enums.dart';
import '../models/match_model.dart';
import '../models/tournament_model.dart';
import '../services/firestore_service.dart';

class TournamentProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<TournamentModel> _tournaments = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _sub;

  List<TournamentModel> get tournaments => _tournaments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _tournaments.length;

  void startListening() {
    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _service.streamTournaments().listen(
      (data) {
        _tournaments = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<String> addTournament(TournamentModel tournament) async {
    try {
      return await _service.addTournament(tournament);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTournament(String id, Map<String, dynamic> data) async {
    try {
      await _service.updateTournament(id, data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTournament(String id) async {
    try {
      await _service.deleteTournamentCascade(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> generateBracket({
    required String tournamentId,
    required List<String> teamIds,
    required List<String> teamNames,
    required TournamentFormat format,
    ValueChanged<List<MatchModel>>? onLocalMatchesReady,
  }) async {
    if (teamIds.length != teamNames.length) {
      _error = 'Selected team data is incomplete';
      notifyListeners();
      throw ArgumentError(_error);
    }

    final previousTournaments = List<TournamentModel>.of(_tournaments);

    try {
      final teams = [
        for (var i = 0; i < teamIds.length; i++)
          BracketTeam(id: teamIds[i], name: teamNames[i]),
      ];
      final specs = BracketGenerator.generate(format: format, teams: teams);
      final idByKey = {
        for (final spec in specs) spec.key: _service.newMatchId(),
      };

      final matches = [
        for (final spec in specs)
          MatchModel(
            id: idByKey[spec.key]!,
            tournamentId: tournamentId,
            round: spec.round,
            matchNumber: spec.matchNumber,
            team1Id: spec.team1Id,
            team2Id: spec.team2Id,
            team1Name: spec.team1Name,
            team2Name: spec.team2Name,
            score1: spec.score1,
            score2: spec.score2,
            winnerId: spec.winnerId,
            status: spec.status,
            bracketType: spec.bracketType,
            nextMatchId: spec.nextKey == null ? null : idByKey[spec.nextKey],
            nextMatchSlot: spec.nextSlot,
            loserNextMatchId: spec.loserNextKey == null
                ? null
                : idByKey[spec.loserNextKey],
            loserNextMatchSlot: spec.loserNextSlot,
            createdAt: DateTime.now(),
          ),
      ];

      final bracketData = [
        for (final spec in specs)
          spec.toBracketMap(idByKey[spec.key]!, idByKey),
      ];

      _replaceTournamentLocally(
        tournamentId: tournamentId,
        status: TournamentStatus.active,
        teamIds: teamIds,
        bracketData: bracketData,
      );
      onLocalMatchesReady?.call(matches);

      await _service.replaceTournamentMatches(
        tournamentId: tournamentId,
        matches: matches,
        bracketData: bracketData,
        tournamentData: {
          'status': TournamentStatus.active.name,
          'teamIds': teamIds,
        },
      );

      _error = null;
      notifyListeners();
    } catch (e) {
      _tournaments = previousTournaments;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _replaceTournamentLocally({
    required String tournamentId,
    required TournamentStatus status,
    required List<String> teamIds,
    required List<Map<String, dynamic>> bracketData,
  }) {
    final index = _tournaments.indexWhere(
      (tournament) => tournament.id == tournamentId,
    );
    if (index < 0) return;

    _tournaments = [
      for (var i = 0; i < _tournaments.length; i++)
        if (i == index)
          _tournaments[i].copyWith(
            status: status,
            teamIds: List<String>.of(teamIds),
            bracket: [
              for (final entry in bracketData) Map<String, dynamic>.of(entry),
            ],
          )
        else
          _tournaments[i],
    ];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
