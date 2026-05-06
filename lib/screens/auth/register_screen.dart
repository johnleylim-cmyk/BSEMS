import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../core/utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      AppUtils.showError(context, 'Passwords do not match');
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      displayName: _nameCtrl.text.trim(),
    );
    if (success && mounted) {
      context.go('/dashboard');
    } else if (mounted && auth.error != null) {
      AppUtils.showError(context, auth.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppTheme.accentCyan.withValues(alpha: 0.4), blurRadius: 30)],
                  ),
                  child: const Center(child: Text('B', style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w800))),
                ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text('Create Account', style: Theme.of(context).textTheme.displaySmall).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text('Join the BSEMS platform', style: Theme.of(context).textTheme.bodyMedium).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(controller: _nameCtrl, validator: (v) => AppUtils.validateRequired(v, 'Name'), decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outlined, size: 20, color: AppTheme.textMuted))),
                        const SizedBox(height: 16),
                        TextFormField(controller: _emailCtrl, validator: AppUtils.validateEmail, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, size: 20, color: AppTheme.textMuted))),
                        const SizedBox(height: 16),
                        TextFormField(controller: _passCtrl, obscureText: _obscure, validator: AppUtils.validatePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outlined, size: 20, color: AppTheme.textMuted), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppTheme.textMuted), onPressed: () => setState(() => _obscure = !_obscure)))),
                        const SizedBox(height: 16),
                        TextFormField(controller: _confirmCtrl, obscureText: true, validator: (v) => AppUtils.validateRequired(v, 'Confirm password'), decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outlined, size: 20, color: AppTheme.textMuted))),
                        const SizedBox(height: 28),
                        GradientButton(label: 'Create Account', icon: Icons.person_add, isLoading: auth.isLoading, onPressed: _submit, width: double.infinity),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.15, duration: 600.ms),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium),
                  MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => context.go('/login'), child: const Text('Sign In', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.w600)))),
                ]).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
