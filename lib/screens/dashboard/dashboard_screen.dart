import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/other_providers.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/team_provider.dart';
import '../../providers/tournament_provider.dart';
import '../../providers/match_provider.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/glass_card.dart';
import '../../core/utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    context.watch<DashboardProvider>();
    final athletes = context.watch<AthleteProvider>();
    final teams = context.watch<TeamProvider>();
    final tournaments = context.watch<TournamentProvider>();
    final matches = context.watch<MatchProvider>();
    final announcements = context.watch<AnnouncementProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Welcome back, ${auth.user?.displayName ?? 'User'}', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 4),
                  Text('Here\'s your sports management overview', style: Theme.of(context).textTheme.bodyMedium),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                  ),
                  child: Text(auth.user?.role.label ?? '', style: const TextStyle(color: AppTheme.accentCyan, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms),

            const SizedBox(height: 28),

            // KPI Tiles
            LayoutBuilder(builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.8,
                children: [
                  StatTile(title: 'Total Athletes', value: '${athletes.count}', icon: Icons.people, accentColor: AppTheme.accentCyan, animationDelay: 0),
                  StatTile(title: 'Total Teams', value: '${teams.count}', icon: Icons.groups, accentColor: AppTheme.accentPurple, animationDelay: 100),
                  StatTile(title: 'Tournaments', value: '${tournaments.count}', icon: Icons.emoji_events, accentColor: AppTheme.accentOrange, animationDelay: 200),
                  StatTile(title: 'Matches', value: '${matches.count}', icon: Icons.sports_esports, accentColor: AppTheme.accentGreen, animationDelay: 300),
                ],
              );
            }),

            const SizedBox(height: 28),

            // Charts Row
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSportDistribution(context, athletes)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTournamentStatus(context, tournaments)),
                  ],
                );
              }
              return Column(children: [
                _buildSportDistribution(context, athletes),
                const SizedBox(height: 16),
                _buildTournamentStatus(context, tournaments),
              ]);
            }),

            const SizedBox(height: 28),

            // Recent Announcements
            _buildRecentAnnouncements(context, announcements),
          ],
        ),
      ),
    );
  }

  Widget _buildSportDistribution(BuildContext context, AthleteProvider provider) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Athletes Overview', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Distribution by gender', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: provider.athletes.isEmpty
                ? const Center(child: Text('No data yet', style: TextStyle(color: AppTheme.textMuted)))
                : PieChart(PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: _buildPieSections(provider),
                  )),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  List<PieChartSectionData> _buildPieSections(AthleteProvider provider) {
    final male = provider.athletes.where((a) => a.gender.name == 'male').length;
    final female = provider.athletes.where((a) => a.gender.name == 'female').length;
    final other = provider.athletes.where((a) => a.gender.name == 'other').length;
    final total = provider.count;
    if (total == 0) return [];

    return [
      PieChartSectionData(value: male.toDouble(), title: '$male', color: AppTheme.accentCyan, radius: 30, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
      PieChartSectionData(value: female.toDouble(), title: '$female', color: AppTheme.accentPink, radius: 30, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
      if (other > 0)
        PieChartSectionData(value: other.toDouble(), title: '$other', color: AppTheme.accentOrange, radius: 30, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
    ];
  }

  Widget _buildTournamentStatus(BuildContext context, TournamentProvider provider) {
    final draft = provider.tournaments.where((t) => t.status.name == 'draft').length;
    final active = provider.tournaments.where((t) => t.status.name == 'active').length;
    final completed = provider.tournaments.where((t) => t.status.name == 'completed').length;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tournament Status', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Current tournament breakdown', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: provider.tournaments.isEmpty
                ? const Center(child: Text('No tournaments yet', style: TextStyle(color: AppTheme.textMuted)))
                : BarChart(BarChartData(
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: draft.toDouble(), color: AppTheme.accentOrange, width: 28, borderRadius: BorderRadius.circular(6))]),
                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: active.toDouble(), color: AppTheme.accentGreen, width: 28, borderRadius: BorderRadius.circular(6))]),
                      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: completed.toDouble(), color: AppTheme.accentCyan, width: 28, borderRadius: BorderRadius.circular(6))]),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                        switch (v.toInt()) { case 0: return const Text('Draft', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)); case 1: return const Text('Active', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)); case 2: return const Text('Done', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)); default: return const Text(''); }
                      })),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  )),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 600.ms);
  }

  Widget _buildRecentAnnouncements(BuildContext context, AnnouncementProvider provider) {
    final recent = provider.announcements.take(5).toList();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Announcements', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            const Text('No announcements yet', style: TextStyle(color: AppTheme.textMuted))
          else
            ...recent.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Container(width: 4, height: 40, decoration: BoxDecoration(color: a.priority.name == 'urgent' ? AppTheme.accentRed : AppTheme.accentCyan, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(AppUtils.timeAgo(a.createdAt), style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ])),
              ]),
            )),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 600.ms);
  }
}
