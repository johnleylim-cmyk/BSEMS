import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../core/enums.dart';

/// Navigation item model for the sidebar.
class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  /// Minimum role required to see this nav item.
  /// null = visible to all authenticated users.
  final UserRole? minRole;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.minRole,
  });
}

/// Premium sidebar navigation with glassmorphic design.
class SidebarNav extends StatelessWidget {
  final List<NavItem> items;
  final String currentRoute;
  final String barangayName;
  final VoidCallback? onLogout;

  const SidebarNav({
    super.key,
    required this.items,
    required this.currentRoute,
    this.barangayName = 'BSEMS',
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: AppTheme.sidebarGradient,
        border: Border(
          right: BorderSide(
            color: AppTheme.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: [
          // ── Brand Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentCyan.withValues(alpha: 0.3),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'B',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BSEMS',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        barangayName,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.2, duration: 400.ms),

          const Divider(height: 1),

          // ── Nav Items ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isActive = currentRoute.startsWith(item.route);
                return _NavTile(
                  item: item,
                  isActive: isActive,
                  onTap: () => context.go(item.route),
                  delay: index * 50,
                );
              },
            ),
          ),

          // ── Logout ──
          if (onLogout != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: _NavTile(
                item: const NavItem(
                  label: 'Logout',
                  icon: Icons.logout_outlined,
                  activeIcon: Icons.logout,
                  route: '/logout',
                ),
                isActive: false,
                onTap: onLogout!,
                isLogout: true,
                delay: 0,
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final bool isLogout;
  final int delay;

  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
    this.isLogout = false,
    this.delay = 0,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isLogout
        ? AppTheme.accentRed
        : (widget.isActive ? AppTheme.accentCyan : AppTheme.textSecondary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppTheme.accentCyan.withValues(alpha: 0.1)
                  : (_hovered
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: widget.isActive
                  ? Border.all(
                      color: AppTheme.accentCyan.withValues(alpha: 0.2))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  widget.isActive ? widget.item.activeIcon : widget.item.icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.item.label,
                  style: TextStyle(
                    color: widget.isActive
                        ? AppTheme.textPrimary
                        : (widget.isLogout
                            ? AppTheme.accentRed
                            : AppTheme.textSecondary),
                    fontWeight:
                        widget.isActive ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.1, duration: 300.ms);
  }
}
