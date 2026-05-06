import 'dart:async';
import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../models/announcement_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/sport_model.dart';
import '../models/venue_model.dart';
import '../services/firestore_service.dart';

/// Provider for schedules.
class ScheduleProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;
  StreamSubscription? _sub;

  List<ScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;

  void startListening() {
    _isLoading = true;
    notifyListeners();
    _sub = _service.streamSchedules().listen((data) {
      _schedules = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addSchedule(ScheduleModel schedule) =>
      _service.addSchedule(schedule);

  Future<void> updateSchedule(String id, Map<String, dynamic> data) =>
      _service.updateSchedule(id, data);

  Future<void> deleteSchedule(String id) => _service.deleteSchedule(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Provider for announcements.
class AnnouncementProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  StreamSubscription? _sub;

  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;

  void startListening() {
    _isLoading = true;
    notifyListeners();
    _sub = _service.streamAnnouncements().listen((data) {
      _announcements = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<String> addAnnouncement(AnnouncementModel a) =>
      _service.addAnnouncement(a);

  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) =>
      _service.updateAnnouncement(id, data);

  Future<void> deleteAnnouncement(String id) => _service.deleteAnnouncement(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Provider for sports.
class SportProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<SportModel> _sports = [];
  bool _isLoading = false;
  StreamSubscription? _sub;

  List<SportModel> get sports => _sports;
  bool get isLoading => _isLoading;

  void startListening() {
    _isLoading = true;
    notifyListeners();
    _sub = _service.streamSports().listen((data) {
      _sports = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<String> addSport(SportModel sport) => _service.addSport(sport);

  Future<void> updateSport(String id, Map<String, dynamic> data) =>
      _service.updateSport(id, data);

  Future<void> deleteSport(String id) => _service.deleteSport(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Provider for venues.
class VenueProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<VenueModel> _venues = [];
  bool _isLoading = false;
  StreamSubscription? _sub;

  List<VenueModel> get venues => _venues;
  bool get isLoading => _isLoading;

  void startListening() {
    _isLoading = true;
    notifyListeners();
    _sub = _service.streamVenues().listen((data) {
      _venues = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<String> addVenue(VenueModel venue) => _service.addVenue(venue);

  Future<void> updateVenue(String id, Map<String, dynamic> data) =>
      _service.updateVenue(id, data);

  Future<void> deleteVenue(String id) => _service.deleteVenue(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Provider for leaderboard entries.
class LeaderboardProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  List<LeaderboardEntryModel> _entries = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _sub;

  List<LeaderboardEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void startListening({String? sportId}) {
    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _service
        .streamLeaderboard(sportId: sportId)
        .listen(
          (data) {
            _entries = data;
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

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Dashboard provider - aggregates stats.
class DashboardProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  Map<String, int> _counts = {};
  bool _isLoading = false;

  Map<String, int> get counts => _counts;
  bool get isLoading => _isLoading;

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      _counts = await _service.getDashboardCounts();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }
}
