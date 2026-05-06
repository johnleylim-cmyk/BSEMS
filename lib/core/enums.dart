/// All enumerations used across the BSEMS system.
library;

enum UserRole {
  admin,
  manager,
  viewer;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.viewer:
        return 'Viewer';
    }
  }
}

enum SportType {
  sports,
  esports;

  String get label {
    switch (this) {
      case SportType.sports:
        return 'Traditional Sports';
      case SportType.esports:
        return 'Esports';
    }
  }
}

enum TournamentStatus {
  draft,
  registration,
  active,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case TournamentStatus.draft:
        return 'Draft';
      case TournamentStatus.registration:
        return 'Registration';
      case TournamentStatus.active:
        return 'Active';
      case TournamentStatus.completed:
        return 'Completed';
      case TournamentStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum TournamentFormat {
  singleElimination,
  doubleElimination,
  roundRobin;

  String get label {
    switch (this) {
      case TournamentFormat.singleElimination:
        return 'Single Elimination';
      case TournamentFormat.doubleElimination:
        return 'Double Elimination';
      case TournamentFormat.roundRobin:
        return 'Round Robin';
    }
  }
}

enum MatchStatus {
  scheduled,
  live,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case MatchStatus.scheduled:
        return 'Scheduled';
      case MatchStatus.live:
        return 'Live';
      case MatchStatus.completed:
        return 'Completed';
      case MatchStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum Gender {
  male,
  female,
  other;

  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}

enum AnnouncementPriority {
  low,
  normal,
  high,
  urgent;

  String get label {
    switch (this) {
      case AnnouncementPriority.low:
        return 'Low';
      case AnnouncementPriority.normal:
        return 'Normal';
      case AnnouncementPriority.high:
        return 'High';
      case AnnouncementPriority.urgent:
        return 'Urgent';
    }
  }
}
