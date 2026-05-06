import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../core/utils.dart';
import '../../models/venue_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/other_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_button.dart';

class VenuesScreen extends StatelessWidget {
  const VenuesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VenueProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Venues', style: Theme.of(context).textTheme.displaySmall).animate().fadeIn(),
          if (auth.isManager) GradientButton(label: 'Add Venue', icon: Icons.add_location, onPressed: () => _showForm(context)),
        ]),
        const SizedBox(height: 20),
        Expanded(child: provider.venues.isEmpty
            ? EmptyState(icon: Icons.location_on_outlined, title: 'No Venues', subtitle: 'Add your sports venues and facilities', actionLabel: auth.isManager ? 'Add Venue' : null, onAction: auth.isManager ? () => _showForm(context) : null)
            : ListView.builder(itemCount: provider.venues.length, itemBuilder: (_, i) {
                final v = provider.venues[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.accentGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.location_on, color: AppTheme.accentGreen, size: 22)),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(v.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                      if (v.address != null) Text(v.address!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      if (v.capacity != null) Text('Capacity: ${v.capacity}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ])),
                    if (auth.isManager) ...[
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textMuted), onPressed: () => _showForm(context, venue: v)),
                      IconButton(icon: const Icon(Icons.delete_outlined, size: 18, color: AppTheme.accentRed), onPressed: () async {
                        await context.read<VenueProvider>().deleteVenue(v.id);
                        if (context.mounted) AppUtils.showSuccess(context, 'Venue deleted');
                      }),
                    ],
                  ]),
                ).animate(delay: Duration(milliseconds: i * 60)).fadeIn(duration: 400.ms);
              })),
      ])),
    );
  }

  void _showForm(BuildContext context, {VenueModel? venue}) {
    final isEdit = venue != null;
    final nameCtrl = TextEditingController(text: venue?.name ?? '');
    final addrCtrl = TextEditingController(text: venue?.address ?? '');
    final capCtrl = TextEditingController(text: venue?.capacity != null ? '${venue!.capacity}' : '');
    final formKey = GlobalKey<FormState>();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(isEdit ? 'Edit Venue' : 'Add Venue'),
      content: SizedBox(width: 400, child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: nameCtrl, validator: (v) => AppUtils.validateRequired(v, 'Name'), decoration: const InputDecoration(labelText: 'Venue Name')),
        const SizedBox(height: 12),
        TextFormField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Address')),
        const SizedBox(height: 12),
        TextFormField(controller: capCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity')),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          if (isEdit) {
            await context.read<VenueProvider>().updateVenue(venue.id, {
              'name': nameCtrl.text.trim(),
              'address': addrCtrl.text.trim(),
              'capacity': int.tryParse(capCtrl.text),
            });
          } else {
            await context.read<VenueProvider>().addVenue(VenueModel(id: '', name: nameCtrl.text.trim(), address: addrCtrl.text.trim(), capacity: int.tryParse(capCtrl.text), createdAt: DateTime.now()));
          }
          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) AppUtils.showSuccess(context, isEdit ? 'Venue updated' : 'Venue added');
        }, child: Text(isEdit ? 'Update' : 'Add')),
      ],
    ));
  }
}
