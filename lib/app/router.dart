import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/shell_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/athletes/athletes_list_screen.dart';
import '../screens/teams/teams_list_screen.dart';
import '../screens/tournaments/tournaments_list_screen.dart';
import '../screens/tournaments/tournament_detail_screen.dart';
import '../screens/matches/matches_list_screen.dart';
import '../screens/matches/match_scoring_screen.dart';
import '../screens/sports/sports_screen.dart';
import '../screens/venues/venues_screen.dart';
import '../screens/schedule/schedule_screen.dart';
import '../screens/announcements/announcements_screen.dart';
import '../screens/leaderboards/leaderboards_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/reports/reports_screen.dart';

/// Routes that require at least manager role.
const _managerRoutes = ['/sports', '/venues', '/reports'];

/// Routes that require admin role.
const _adminRoutes = ['/settings'];

/// GoRouter configuration with auth + role-guarded routes.
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuth = authProvider.isAuthenticated;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';

      // 1. Auth guard — block unauthenticated users
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/dashboard';

      // 2. Role guard — block unauthorized role access
      if (isAuth) {
        // Admin-only routes
        if (_adminRoutes.any((r) => location.startsWith(r)) &&
            !authProvider.isAdmin) {
          return '/dashboard';
        }
        // Manager-only routes
        if (_managerRoutes.any((r) => location.startsWith(r)) &&
            !authProvider.isManager) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      // ── Auth routes (no shell) ──
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Main app (with shell/sidebar) ──
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/athletes',
            builder: (context, state) => const AthletesListScreen(),
          ),
          GoRoute(
            path: '/teams',
            builder: (context, state) => const TeamsListScreen(),
          ),
          GoRoute(
            path: '/tournaments',
            builder: (context, state) => const TournamentsListScreen(),
          ),
          GoRoute(
            path: '/tournaments/:id',
            builder: (context, state) => TournamentDetailScreen(
              tournamentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/matches',
            builder: (context, state) => const MatchesListScreen(),
          ),
          GoRoute(
            path: '/matches/:id/score',
            builder: (context, state) => MatchScoringScreen(
              matchId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/sports',
            builder: (context, state) => const SportsScreen(),
          ),
          GoRoute(
            path: '/venues',
            builder: (context, state) => const VenuesScreen(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/announcements',
            builder: (context, state) => const AnnouncementsScreen(),
          ),
          GoRoute(
            path: '/leaderboards',
            builder: (context, state) => const LeaderboardsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
    ],
  );
}
