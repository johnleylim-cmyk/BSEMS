import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../core/utils.dart';
import '../../models/tournament_model.dart';
import '../../providers/tournament_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/other_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/gradient_button.dart';

class TournamentsListScreen extends StatefulWidget {
  const TournamentsListScreen({super.key});
  @override
  State<TournamentsListScreen> createState() => _TournamentsListScreenState();
}

class _TournamentsListScreenState extends State<TournamentsListScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TournamentProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Tournaments', style: Theme.of(context).textTheme.displaySmall).animate().fadeIn(),
          if (auth.isManager) GradientButton(label: 'Create Tournament', icon: Icons.add, onPressed: () => _showForm(context)),
        ]),
        const SizedBox(height: 20),
        Expanded(
          child: provider.isLoading ? ShimmerLoader.list() : provider.tournaments.isEmpty
              ? EmptyState(icon: Icons.emoji_events_outlined, title: 'No Tournaments', subtitle: 'Create your first tournament', actionLabel: auth.isManager ? 'Create' : null, onAction: auth.isManager ? () => _showForm(context) : null)
              : ListView.builder(itemCount: provider.tournaments.length, itemBuilder: (context, i) {
                  final t = provider.tournaments[i];
                  return _TournamentCard(tournament: t, canManage: auth.isManager, onTap: () => context.go('/tournaments/${t.id}'), onDelete: () => _confirmDelete(context, t))
                      .animate(delay: Duration(milliseconds: i * 80)).fadeIn(duration: 400.ms).slideY(begin: 0.05, duration: 400.ms);
                }),
        ),
      ])),
    );
  }

  void _showForm(BuildContext context) {
    final nameCtrl = TextEditingController();
    final rulesCtrl = TextEditingController();
    final prizeCtrl = TextEditingController();
    TournamentFormat format = TournamentFormat.singleElimination;
    String? selectedSportId;
    final sports = context.read<SportProvider>().sports;
    final formKey = GlobalKey<FormState>();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      title: const Text('Create Tournament'),
      content: SizedBox(width: 500, child: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: nameCtrl, validator: (v) => AppUtils.validateRequired(v, 'Name'), decoration: const InputDecoration(labelText: 'Tournament Name')),
        const SizedBox(height: 12),
        if (sports.isNotEmpty) DropdownButtonFormField<String>(initialValue: selectedSportId, decoration: const InputDecoration(labelText: 'Sport / Game'), items: sports.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(), onChanged: (v) => setDialogState(() => selectedSportId = v)),
        const SizedBox(height: 12),
        DropdownButtonFormField<TournamentFormat>(initialValue: format, decoration: const InputDecoration(labelText: 'Format'), items: TournamentFormat.values.map((f) => DropdownMenuItem(value: f, child: Text(f.label))).toList(), onChanged: (v) => setDialogState(() => format = v!)),
        const SizedBox(height: 12),
        TextFormField(controller: prizeCtrl, decoration: const InputDecoration(labelText: 'Prize Pool (optional)')),
        const SizedBox(height: 12),
        TextFormField(controller: rulesCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Rules (optional)')),
      ])))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          await context.read<TournamentProvider>().addTournament(TournamentModel(id: '', name: nameCtrl.text.trim(), sportId: selectedSportId ?? '', format: format, status: TournamentStatus.draft, rules: rulesCtrl.text.trim(), prizePool: prizeCtrl.text.trim(), createdAt: DateTime.now()));
          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) AppUtils.showSuccess(context, 'Tournament created');
        }, child: const Text('Create')),
      ],
    )));
  }

  void _confirmDelete(BuildContext context, TournamentModel t) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Tournament'),
      content: Text('Delete "${t.name}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed), onPressed: () async {
          await context.read<TournamentProvider>().deleteTournament(t.id);
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text('Delete')),
      ],
    ));
  }
}

class _TournamentCard extends StatelessWidget {
  final TournamentModel tournament;
  final bool canManage;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _TournamentCard({required this.tournament, required this.canManage, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppUtils.statusColor(tournament.status.name);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(AppTheme.radiusLg), border: Border.all(color: AppTheme.border)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.accentOrange.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.emoji_events, color: AppTheme.accentOrange, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tournament.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 4),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Text(tournament.status.label, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600))),
              const SizedBox(width: 12),
              Text(tournament.format.label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(width: 12),
              Text('${tournament.teamIds.length} teams', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ]),
          ])),
          if (canManage) IconButton(icon: const Icon(Icons.delete_outlined, size: 18, color: AppTheme.accentRed), onPressed: onDelete),
          const Icon(Icons.chevron_right, color: AppTheme.textMuted),
        ]),
      ),
    );
  }
}
