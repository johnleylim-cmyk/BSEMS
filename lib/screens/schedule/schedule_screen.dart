import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../core/utils.dart';
import '../../models/schedule_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/other_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gradient_button.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Schedule', style: Theme.of(context).textTheme.displaySmall).animate().fadeIn(),
          if (auth.isManager) GradientButton(label: 'Add Event', icon: Icons.add, onPressed: () => _showForm(context)),
        ]),
        const SizedBox(height: 20),
        Expanded(child: provider.schedules.isEmpty
            ? const EmptyState(icon: Icons.calendar_month_outlined, title: 'No Events Scheduled', subtitle: 'Add upcoming events and match schedules')
            : ListView.builder(itemCount: provider.schedules.length, itemBuilder: (_, i) {
                final s = provider.schedules[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(AppTheme.radiusMd), border: Border.all(color: AppTheme.border)),
                  child: Row(children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(color: AppTheme.accentCyan.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('${s.date.day}', style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w700, fontSize: 18)),
                        Text(AppUtils.formatDate(s.date).split(' ')[0], style: const TextStyle(color: AppTheme.accentCyan, fontSize: 10)),
                      ]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                      if (s.venue != null) Text(s.venue!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      if (s.time != null) Text(s.time!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ])),
                    if (auth.isManager) ...[
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textMuted), onPressed: () => _showForm(context, schedule: s)),
                      IconButton(icon: const Icon(Icons.delete_outlined, size: 18, color: AppTheme.accentRed), onPressed: () async {
                        await context.read<ScheduleProvider>().deleteSchedule(s.id);
                      }),
                    ],
                  ]),
                ).animate(delay: Duration(milliseconds: i * 60)).fadeIn(duration: 400.ms);
              })),
      ])),
    );
  }

  void _showForm(BuildContext context, {ScheduleModel? schedule}) {
    final isEdit = schedule != null;
    final titleCtrl = TextEditingController(text: schedule?.title ?? '');
    final venueCtrl = TextEditingController(text: schedule?.venue ?? '');
    final timeCtrl = TextEditingController(text: schedule?.time ?? '');
    DateTime selectedDate = schedule?.date ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      title: Text(isEdit ? 'Edit Schedule Event' : 'Add Schedule Event'),
      content: SizedBox(width: 400, child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: titleCtrl, validator: (v) => AppUtils.validateRequired(v, 'Title'), decoration: const InputDecoration(labelText: 'Event Title')),
        const SizedBox(height: 12),
        ListTile(contentPadding: EdgeInsets.zero, title: Text('Date: ${AppUtils.formatDate(selectedDate)}'), trailing: const Icon(Icons.calendar_today, color: AppTheme.accentCyan), onTap: () async {
          final d = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
          if (d != null) setDialogState(() => selectedDate = d);
        }),
        TextFormField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time (e.g., 3:00 PM)')),
        const SizedBox(height: 12),
        TextFormField(controller: venueCtrl, decoration: const InputDecoration(labelText: 'Venue')),
      ]))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          if (!formKey.currentState!.validate()) return;
          if (isEdit) {
            await context.read<ScheduleProvider>().updateSchedule(schedule.id, {
              'title': titleCtrl.text.trim(),
              'date': selectedDate.toIso8601String(),
              'time': timeCtrl.text.trim(),
              'venue': venueCtrl.text.trim(),
            });
          } else {
            await context.read<ScheduleProvider>().addSchedule(ScheduleModel(id: '', title: titleCtrl.text.trim(), date: selectedDate, time: timeCtrl.text.trim(), venue: venueCtrl.text.trim(), createdAt: DateTime.now()));
          }
          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) AppUtils.showSuccess(context, isEdit ? 'Event updated' : 'Event added');
        }, child: Text(isEdit ? 'Update' : 'Add')),
      ],
    )));
  }
}
