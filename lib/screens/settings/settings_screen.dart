import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../core/enums.dart';
import '../../core/utils.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _barangayCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await FirestoreService().getSettings();
    _barangayCtrl.text = settings['barangayName'] ?? '';
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Settings', style: Theme.of(context).textTheme.displaySmall).animate().fadeIn(),
        const SizedBox(height: 28),

        // Profile Card
        GlassCard(child: Row(children: [
          CircleAvatar(radius: 30, backgroundColor: AppTheme.accentCyan.withValues(alpha: 0.15), child: Text(AppUtils.initials(auth.user?.displayName ?? 'U'), style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w700, fontSize: 20))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(auth.user?.displayName ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 18)),
            Text(auth.user?.email ?? '', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.accentCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Text(auth.user?.role.label ?? '', style: const TextStyle(color: AppTheme.accentCyan, fontSize: 11, fontWeight: FontWeight.w600))),
          ])),
        ])).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 24),

        if (auth.isAdmin) ...[
          // Barangay Config
          Text('System Configuration', style: Theme.of(context).textTheme.headlineMedium).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Barangay Name', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(controller: _barangayCtrl, decoration: const InputDecoration(hintText: 'Enter your barangay name')),
            const SizedBox(height: 12),
            GradientButton(label: _loading ? 'Saving...' : 'Save Settings', icon: Icons.save, isLoading: _loading, onPressed: () async {
              setState(() => _loading = true);
              await FirestoreService().updateSettings({'barangayName': _barangayCtrl.text.trim()});
              setState(() => _loading = false);
              if (context.mounted) AppUtils.showSuccess(context, 'Settings saved');
            }),
          ])).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 24),

          // User Management
          Text('User Management', style: Theme.of(context).textTheme.headlineMedium).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          const _UserManagementSection(),
        ],
      ])),
    );
  }
}

class _UserManagementSection extends StatefulWidget {
  const _UserManagementSection();
  @override
  State<_UserManagementSection> createState() => _UserManagementSectionState();
}

class _UserManagementSectionState extends State<_UserManagementSection> {
  final AuthService _authService = AuthService();
  List<UserModel> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      _users = await _authService.getAllUsers();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().user;
    if (_loading) {
      return const GlassCard(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())));
    }
    if (_users.isEmpty) {
      return const GlassCard(child: Padding(padding: EdgeInsets.all(20), child: Text('No users found', style: TextStyle(color: AppTheme.textMuted))));
    }

    return GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${_users.length} registered users', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      const SizedBox(height: 12),
      ..._users.map((u) {
        final isCurrentUser = u.uid == currentUser?.uid;
        final roleColor = u.role == UserRole.admin
            ? AppTheme.accentCyan
            : u.role == UserRole.manager
                ? AppTheme.accentOrange
                : AppTheme.textMuted;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.background.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
          child: Row(children: [
            CircleAvatar(radius: 18, backgroundColor: roleColor.withValues(alpha: 0.15), child: Text(AppUtils.initials(u.displayName), style: TextStyle(color: roleColor, fontWeight: FontWeight.w600, fontSize: 12))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(u.displayName, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                if (isCurrentUser) Container(margin: const EdgeInsets.only(left: 6), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: AppTheme.accentGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: const Text('You', style: TextStyle(color: AppTheme.accentGreen, fontSize: 9, fontWeight: FontWeight.w600))),
              ]),
              Text(u.email, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ])),
            if (!isCurrentUser) DropdownButton<UserRole>(
              value: u.role,
              underline: const SizedBox(),
              dropdownColor: AppTheme.surface,
              style: TextStyle(color: roleColor, fontSize: 12, fontWeight: FontWeight.w600),
              items: UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (newRole) async {
                if (newRole == null) return;
                await _authService.updateUserRole(u.uid, newRole);
                await _loadUsers();
                if (context.mounted) AppUtils.showSuccess(context, 'Role updated to ${newRole.label}');
              },
            ) else Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(u.role.label, style: TextStyle(color: roleColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
        );
      }),
    ])).animate().fadeIn(delay: 500.ms);
  }
}
