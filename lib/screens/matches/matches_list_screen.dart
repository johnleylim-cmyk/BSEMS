import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../core/utils.dart';
import '../../providers/match_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loader.dart';

class MatchesListScreen extends StatelessWidget {
  const MatchesListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('All Matches', style: Theme.of(context).textTheme.displaySmall).animate().fadeIn(),
        const SizedBox(height: 20),
        Expanded(child: provider.isLoading ? ShimmerLoader.list() : provider.matches.isEmpty
            ? const EmptyState(icon: Icons.sports_esports_outlined, title: 'No Matches', subtitle: 'Matches will appear when you generate tournament brackets')
            : ListView.builder(itemCount: provider.matches.length, itemBuilder: (context, i) {
                final m = provider.matches[i];
                final statusColor = AppUtils.statusColor(m.status.name);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: m.status == MatchStatus.live ? AppTheme.accentGreen : AppTheme.border)),
                  child: Row(children: [
                    Expanded(child: Text(m.team1Name ?? 'TBD', style: TextStyle(color: m.winnerId == m.team1Id ? AppTheme.accentGreen : AppTheme.textPrimary, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: [
                      Text('${m.score1} - ${m.score2}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Text(m.status.label, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600))),
                    ])),
                    Expanded(child: Text(m.team2Name ?? 'TBD', style: TextStyle(color: m.winnerId == m.team2Id ? AppTheme.accentGreen : AppTheme.textPrimary, fontWeight: FontWeight.w600))),
                  ]),
                ).animate(delay: Duration(milliseconds: i * 50)).fadeIn(duration: 300.ms);
              })),
      ])),
    );
  }
}
