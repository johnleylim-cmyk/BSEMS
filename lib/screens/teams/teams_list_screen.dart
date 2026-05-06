import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../core/utils.dart';
import '../../models/team_model.dart';
import '../../providers/team_provider.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/other_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/avatar_badge.dart';

class TeamsListScreen extends StatefulWidget {
  const TeamsListScreen({super.key});
  @override
  State<TeamsListScreen> createState() => _TeamsListScreenState();
}

class _TeamsListScreenState extends State<TeamsListScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamProvider>();
    final auth = context.watch<AuthProvider>();
    final filtered = provider.teams.where((t) => t.name.toLowerCase().contains(_search.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Teams', style: Theme.of(context).textTheme.displaySmall).animate().fadeIn(),
            if (auth.isManager) GradientButton(label: 'Add Team', icon: Icons.group_add, onPressed: () => _showForm(context)),
          ]),
          const SizedBox(height: 20),
          AppSearchBar(controller: _searchCtrl, hintText: 'Search teams...', onChanged: (v) => setState(() => _search = v)),
          const SizedBox(height: 20),
          Expanded(
            child: provider.isLoading
                ? ShimmerLoader.list()
                : filtered.isEmpty
                    ? EmptyState(icon: Icons.groups_outlined, title: 'No Teams', subtitle: 'Create your first team', actionLabel: auth.isManager ? 'Add Team' : null, onAction: auth.isManager ? () => _showForm(context) : null)
                    : LayoutBuilder(builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.4),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final t = filtered[i];
                            return _TeamCard(
                              team: t,
                              canManage: auth.isManager,
                              onEdit: () => _showForm(context, team: t),
                              onDelete: () => _confirmDelete(context, t),
                              onManageMembers: () => _showMemberManager(context, t),
                            ).animate(delay: Duration(milliseconds: i * 80)).fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), duration: 400.ms);
                          },
                        );
                      }),
          ),
        ]),
      ),
    );
  }

  /// Convert picked image bytes to a base64 data URI string for Firestore storage.
  /// This avoids needing Firebase Storage (works on Spark plan).
  String _bytesToBase64DataUri(Uint8List bytes) {
    final base64Str = base64Encode(bytes);
    return 'data:image/png;base64,$base64Str';
  }

  void _showForm(BuildContext context, {TeamModel? team}) {
    final isEdit = team != null;
    final nameCtrl = TextEditingController(text: team?.name ?? '');
    final descCtrl = TextEditingController(text: team?.description ?? '');
    SportType sportType = team?.sportType ?? SportType.sports;
    String? selectedSportId = team?.sportId;
    final formKey = GlobalKey<FormState>();
    final sports = context.read<SportProvider>().sports;

    Uint8List? pickedLogoBytes;
    String? existingLogo = team?.logo;
    bool saving = false;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      title: Text(isEdit ? 'Edit Team' : 'Add Team'),
      content: SizedBox(width: 500, child: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Logo Picker
        GestureDetector(
          onTap: () async {
            final bytes = await ImagePickerWeb.getImageAsBytes();
            if (bytes != null) {
              setDialogState(() => pickedLogoBytes = bytes);
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Column(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentPurple.withValues(alpha: 0.1),
                    border: Border.all(
                      color: pickedLogoBytes != null
                          ? AppTheme.accentCyan
                          : AppTheme.accentPurple.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    image: pickedLogoBytes != null
                        ? DecorationImage(image: MemoryImage(pickedLogoBytes!), fit: BoxFit.cover)
                        : existingLogo != null && existingLogo!.isNotEmpty
                            ? DecorationImage(
                                image: _imageProviderFromLogo(existingLogo!),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: pickedLogoBytes == null && (existingLogo == null || existingLogo!.isEmpty)
                      ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_photo_alternate_outlined, color: AppTheme.accentPurple, size: 26),
                          SizedBox(height: 2),
                          Text('Logo', style: TextStyle(color: AppTheme.accentPurple, fontSize: 10, fontWeight: FontWeight.w500)),
                        ])
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  pickedLogoBytes != null ? 'Logo selected ✓' : 'Tap to upload logo',
                  style: TextStyle(
                    color: pickedLogoBytes != null ? AppTheme.accentGreen : AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
                // Remove logo button if there's an existing or picked logo
                if (pickedLogoBytes != null || (existingLogo != null && existingLogo!.isNotEmpty))
                  TextButton.icon(
                    onPressed: () {
                      setDialogState(() {
                        pickedLogoBytes = null;
                        existingLogo = null;
                      });
                    },
                    icon: const Icon(Icons.close, size: 14, color: AppTheme.accentRed),
                    label: const Text('Remove Logo', style: TextStyle(color: AppTheme.accentRed, fontSize: 11)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(controller: nameCtrl, validator: (v) => AppUtils.validateRequired(v, 'Team name'), decoration: const InputDecoration(labelText: 'Team Name')),
        const SizedBox(height: 12),
        DropdownButtonFormField<SportType>(initialValue: sportType, decoration: const InputDecoration(labelText: 'Category'), items: SportType.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(), onChanged: (v) => setDialogState(() => sportType = v!)),
        const SizedBox(height: 12),
        if (sports.isNotEmpty) DropdownButtonFormField<String>(initialValue: selectedSportId, decoration: const InputDecoration(labelText: 'Sport / Game'), items: sports.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(), onChanged: (v) => setDialogState(() => selectedSportId = v)),
        const SizedBox(height: 12),
        TextFormField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description (optional)')),
      ])))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: saving ? null : () async {
            if (!formKey.currentState!.validate()) return;
            setDialogState(() => saving = true);

            final prov = context.read<TeamProvider>();
            final rootContext = context;

            // Determine the logo value
            String? logoValue = existingLogo;
            if (pickedLogoBytes != null) {
              logoValue = _bytesToBase64DataUri(pickedLogoBytes!);
            }

            if (isEdit) {
              await prov.updateTeam(team.id, {
                'name': nameCtrl.text.trim(),
                'sportType': sportType.name,
                'sportId': selectedSportId ?? '',
                'description': descCtrl.text.trim(),
                'logo': logoValue,
              });
            } else {
              await prov.addTeam(TeamModel(
                id: '',
                name: nameCtrl.text.trim(),
                sportId: selectedSportId ?? '',
                sportType: sportType,
                description: descCtrl.text.trim(),
                logo: logoValue,
                createdAt: DateTime.now(),
              ));
            }
            if (ctx.mounted) Navigator.pop(ctx);
            if (rootContext.mounted) AppUtils.showSuccess(rootContext, isEdit ? 'Team updated' : 'Team added');
          },
          child: saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isEdit ? 'Update' : 'Add'),
        ),
      ],
    )));
  }

  /// Returns the appropriate ImageProvider for a logo string (base64 data URI or network URL).
  ImageProvider _imageProviderFromLogo(String logo) {
    if (logo.startsWith('data:')) {
      final commaIndex = logo.indexOf(',');
      if (commaIndex != -1) {
        try {
          final bytes = base64Decode(logo.substring(commaIndex + 1));
          return MemoryImage(bytes);
        } catch (_) {}
      }
    }
    return NetworkImage(logo);
  }

  void _confirmDelete(BuildContext context, TeamModel t) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Team'),
      content: Text('Delete "${t.name}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed), onPressed: () async {
          await context.read<TeamProvider>().deleteTeam(t.id);
          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) AppUtils.showSuccess(context, 'Team deleted');
        }, child: const Text('Delete')),
      ],
    ));
  }

  /// Team Member Manager Dialog — add/remove athletes from team
  void _showMemberManager(BuildContext context, TeamModel team) {
    final athletes = context.read<AthleteProvider>().athletes;
    final currentMemberIds = List<String>.from(team.memberIds);

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      title: Text('${team.name} — Members'),
      content: SizedBox(
        width: 500,
        height: 450,
        child: Column(children: [
          // Current Members
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.accentCyan.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.2))),
            child: Row(children: [
              const Icon(Icons.groups, color: AppTheme.accentCyan, size: 20),
              const SizedBox(width: 8),
              Text('${currentMemberIds.length} members selected', style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 12),
          // Athletes List
          Expanded(child: athletes.isEmpty
              ? const Center(child: Text('No athletes registered yet', style: TextStyle(color: AppTheme.textMuted)))
              : ListView.builder(
                  itemCount: athletes.length,
                  itemBuilder: (_, i) {
                    final a = athletes[i];
                    final isMember = currentMemberIds.contains(a.id);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isMember ? AppTheme.accentCyan.withValues(alpha: 0.06) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isMember ? AppTheme.accentCyan.withValues(alpha: 0.3) : AppTheme.border),
                      ),
                      child: CheckboxListTile(
                        value: isMember,
                        activeColor: AppTheme.accentCyan,
                        title: Text(a.fullName, style: TextStyle(color: isMember ? AppTheme.accentCyan : AppTheme.textPrimary, fontWeight: isMember ? FontWeight.w600 : FontWeight.w400, fontSize: 14)),
                        subtitle: Text('${a.gender.label} • Age ${a.age}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        secondary: AvatarBadge(name: a.fullName, imageUrl: a.photoUrl, size: 34),
                        onChanged: (v) {
                          setDialogState(() {
                            if (v == true) {
                              currentMemberIds.add(a.id);
                            } else {
                              currentMemberIds.remove(a.id);
                            }
                          });
                        },
                      ),
                    );
                  },
                )),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          await context.read<TeamProvider>().updateTeam(team.id, {'memberIds': currentMemberIds});
          if (ctx.mounted) Navigator.pop(ctx);
          if (context.mounted) AppUtils.showSuccess(context, '${currentMemberIds.length} members saved');
        }, child: const Text('Save Members')),
      ],
    )));
  }
}

class _TeamCard extends StatelessWidget {
  final TeamModel team;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onManageMembers;
  const _TeamCard({required this.team, required this.canManage, required this.onEdit, required this.onDelete, required this.onManageMembers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(AppTheme.radiusLg), border: Border.all(color: AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Team logo or fallback icon
          _buildTeamLogo(),
          const SizedBox(width: 12),
          Expanded(child: Text(team.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 16), overflow: TextOverflow.ellipsis)),
          if (canManage) PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18, color: AppTheme.textMuted),
            color: AppTheme.surface,
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'members') onManageMembers();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16, color: AppTheme.textSecondary), SizedBox(width: 8), Text('Edit')])),
              const PopupMenuItem(value: 'members', child: Row(children: [Icon(Icons.person_add_outlined, size: 16, color: AppTheme.accentCyan), SizedBox(width: 8), Text('Manage Members')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outlined, size: 16, color: AppTheme.accentRed), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppTheme.accentRed))])),
            ],
          ),
        ]),
        const SizedBox(height: 12),
        // Members
        GestureDetector(
          onTap: onManageMembers,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.accentCyan.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.people_outlined, size: 14, color: AppTheme.accentCyan),
              const SizedBox(width: 6),
              Text('${team.memberIds.length} members', style: const TextStyle(color: AppTheme.accentCyan, fontSize: 12, fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
        const Spacer(),
        Row(children: [
          _StatChip(label: 'W', value: '${team.wins}', color: AppTheme.accentGreen),
          const SizedBox(width: 8),
          _StatChip(label: 'L', value: '${team.losses}', color: AppTheme.accentRed),
          const SizedBox(width: 8),
          _StatChip(label: 'D', value: '${team.draws}', color: AppTheme.accentOrange),
        ]),
      ]),
    );
  }

  /// Build the team logo widget — shows uploaded logo or a fallback icon.
  Widget _buildTeamLogo() {
    if (team.logo != null && team.logo!.isNotEmpty) {
      return AvatarBadge(
        name: team.name,
        imageUrl: team.logo,
        size: 44,
        showBorder: true,
      );
    }
    // Fallback: sport type icon
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        team.sportType == SportType.esports ? Icons.sports_esports : Icons.sports_basketball,
        color: AppTheme.accentPurple,
        size: 22,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text('$label: $value', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
