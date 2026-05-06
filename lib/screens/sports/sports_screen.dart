import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../core/utils.dart';
import '../../models/sport_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/other_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_button.dart';

class SportsScreen extends StatelessWidget {
  const SportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SportProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Sports & Games', style: Theme.of(context).textTheme.displaySmall).animate().fadeIn(),
          if (auth.isManager) GradientButton(label: 'Add Sport / Game', icon: Icons.add, onPressed: () => _showForm(context)),
        ]),
        const SizedBox(height: 20),
        Expanded(child: provider.sports.isEmpty
            ? EmptyState(icon: Icons.sports_basketball_outlined, title: 'No Sports / Games', subtitle: 'Add any sport or esports game', actionLabel: auth.isManager ? 'Add' : null, onAction: auth.isManager ? () => _showForm(context) : null)
            : LayoutBuilder(builder: (context, constraints) {
                final cols = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                return GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2.0), itemCount: provider.sports.length, itemBuilder: (_, i) {
                  final s = provider.sports[i];
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(AppTheme.radiusLg), border: Border.all(color: AppTheme.border)),
                    child: Row(children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: (s.type == SportType.esports ? AppTheme.accentPurple : AppTheme.accentCyan).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(s.type == SportType.esports ? Icons.sports_esports : Icons.sports_basketball, color: s.type == SportType.esports ? AppTheme.accentPurple : AppTheme.accentCyan, size: 24)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(s.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(s.type.label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        if (s.maxTeamSize > 0) Text('Max ${s.maxTeamSize} players/team', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ])),
                      if (auth.isManager) ...[
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textMuted), onPressed: () => _showForm(context, sport: s)),
                        IconButton(icon: const Icon(Icons.delete_outlined, size: 18, color: AppTheme.accentRed), onPressed: () async {
                          await context.read<SportProvider>().deleteSport(s.id);
                          if (context.mounted) AppUtils.showSuccess(context, 'Deleted');
                        }),
                      ],
                    ]),
                  ).animate(delay: Duration(milliseconds: i * 80)).fadeIn(duration: 400.ms);
                });
              })),
      ])),
    );
  }

  void _showForm(BuildContext context, {SportModel? sport}) {
    final isEdit = sport != null;
    final nameCtrl = TextEditingController(text: sport?.name ?? '');
    final descCtrl = TextEditingController(text: sport?.description ?? '');
    final sizeCtrl = TextEditingController(text: '${sport?.maxTeamSize ?? 5}');
    SportType type = sport?.type ?? SportType.sports;
    final formKey = GlobalKey<FormState>();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      title: Text(isEdit ? 'Edit Sport / Game' : 'Add Sport / Game'),
      content: SizedBox(width: 400, child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: nameCtrl, validator: (v) => AppUtils.validateRequired(v, 'Name'), decoration: const InputDecoration(labelText: 'Name (e.g., Basketball, Mobile Legends, Valorant)')),
        const SizedBox(height: 12),
        DropdownButtonFormField<SportType>(initialValue: type, decoration: const InputDecoration(labelText: 'Type'), items: SportType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(), onChanged: (v) => setDialogState(() => type = v!)),
        const SizedBox(height: 12),
        TextFormField(controller: sizeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Team Size')),
        const SizedBox(height: 12),
        TextFormField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description (optional)')),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          if (isEdit) {
            await context.read<SportProvider>().updateSport(sport.id, {
              'name': nameCtrl.text.trim(),
              'type': type.name,
              'maxTeamSize': int.tryParse(sizeCtrl.text) ?? 5,
              'description': descCtrl.text.trim(),
            });
          } else {
            await context.read<SportProvider>().addSport(SportModel(id: '', name: nameCtrl.text.trim(), type: type, maxTeamSize: int.tryParse(sizeCtrl.text) ?? 5, description: descCtrl.text.trim(), createdAt: DateTime.now()));
          }
          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) AppUtils.showSuccess(context, isEdit ? 'Updated' : 'Sport/game added');
        }, child: Text(isEdit ? 'Update' : 'Add')),
      ],
    )));
  }
}
