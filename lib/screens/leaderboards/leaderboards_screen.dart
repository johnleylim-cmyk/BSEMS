import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../models/match_model.dart';
import '../../models/team_model.dart';
import '../../providers/match_provider.dart';
import '../../providers/team_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loader.dart';

class LeaderboardsScreen extends StatefulWidget {
  const LeaderboardsScreen({super.key});

  @override
  State<LeaderboardsScreen> createState() => _LeaderboardsScreenState();
}

class _LeaderboardsScreenState extends State<LeaderboardsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();
    final matchProvider = context.watch<MatchProvider>();
    final rows = _buildRows(
      teams: teamProvider.teams,
      matches: matchProvider.matches,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leaderboards',
              style: Theme.of(context).textTheme.displaySmall,
            ).animate().fadeIn(),
            const SizedBox(height: 8),
            Text(
              'Teams ranked by match results',
              style: Theme.of(context).textTheme.bodyMedium,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 24),
            Expanded(
              child: matchProvider.isLoading && rows.isEmpty
                  ? ShimmerLoader.list()
                  : rows.isEmpty
                  ? const EmptyState(
                      icon: Icons.leaderboard_outlined,
                      title: 'No Rankings',
                      subtitle:
                          'Save or complete match scores to see team rankings',
                    )
                  : ListView.builder(
                      itemCount: rows.length,
                      itemBuilder: (_, i) {
                        final row = rows[i];
                        final rank = i + 1;
                        final rankColor = _rankColor(rank);

                        return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: rank <= 3
                                    ? rankColor.withValues(alpha: 0.06)
                                    : AppTheme.card,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                                border: Border.all(
                                  color: rank <= 3
                                      ? rankColor.withValues(alpha: 0.3)
                                      : AppTheme.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 36,
                                    child: Text(
                                      '#$rank',
                                      style: TextStyle(
                                        color: rankColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: rank <= 3 ? 20 : 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (rank <= 3) ...[
                                    Icon(
                                      Icons.emoji_events,
                                      color: rankColor,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    child: Text(
                                      row.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${row.wins}W - ${row.losses}L'
                                        '${row.draws > 0 ? ' - ${row.draws}D' : ''}',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${row.winRate.toStringAsFixed(0)}% WR'
                                        ' / ${row.played} played',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                            .animate(delay: Duration(milliseconds: i * 60))
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.05, duration: 400.ms);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static List<_LeaderboardRow> _buildRows({
    required List<TeamModel> teams,
    required List<MatchModel> matches,
  }) {
    final rowsByTeamId = <String, _LeaderboardRow>{};

    String? teamName(String id, String? fallbackName) {
      for (final team in teams) {
        if (team.id == id) return team.name;
      }
      return fallbackName;
    }

    _LeaderboardRow ensureRow(String id, String? name) {
      return rowsByTeamId.putIfAbsent(
        id,
        () => _LeaderboardRow(
          name: name?.trim().isNotEmpty == true ? name! : 'Unknown Team',
        ),
      );
    }

    for (final match in matches) {
      if (match.team1Id == null || match.team2Id == null) continue;

      final hasSavedScore = match.score1 != 0 || match.score2 != 0;
      if (match.status != MatchStatus.completed && !hasSavedScore) continue;

      final team1 = ensureRow(
        match.team1Id!,
        teamName(match.team1Id!, match.team1Name),
      );
      final team2 = ensureRow(
        match.team2Id!,
        teamName(match.team2Id!, match.team2Name),
      );

      team1.played++;
      team2.played++;
      team1.pointsFor += match.score1;
      team1.pointsAgainst += match.score2;
      team2.pointsFor += match.score2;
      team2.pointsAgainst += match.score1;

      if (match.score1 == match.score2) {
        team1.draws++;
        team2.draws++;
      } else if (match.score1 > match.score2) {
        team1.wins++;
        team2.losses++;
      } else {
        team2.wins++;
        team1.losses++;
      }
    }

    final rows = rowsByTeamId.values.where((row) => row.played > 0).toList();
    rows.sort((a, b) {
      final wins = b.wins.compareTo(a.wins);
      if (wins != 0) return wins;
      final winRate = b.winRate.compareTo(a.winRate);
      if (winRate != 0) return winRate;
      final differential = b.differential.compareTo(a.differential);
      if (differential != 0) return differential;
      return a.name.compareTo(b.name);
    });
    return rows;
  }

  static Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppTheme.textMuted;
  }
}

class _LeaderboardRow {
  final String name;
  int played = 0;
  int wins = 0;
  int losses = 0;
  int draws = 0;
  int pointsFor = 0;
  int pointsAgainst = 0;

  _LeaderboardRow({required this.name});

  double get winRate => played > 0 ? (wins / played) * 100 : 0;
  int get differential => pointsFor - pointsAgainst;
}
