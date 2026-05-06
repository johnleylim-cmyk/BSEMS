import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Circular avatar with optional online badge and gradient border.
class AvatarBadge extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showBorder;

  const AvatarBadge({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 44,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);

    Widget avatar;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: AppTheme.surfaceLight,
      );
    } else {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: AppTheme.accentCyan.withValues(alpha: 0.15),
        child: Text(
          initials,
          style: TextStyle(
            color: AppTheme.accentCyan,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.35,
          ),
        ),
      );
    }

    if (showBorder) {
      return Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.primaryGradient,
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.background,
          ),
          child: avatar,
        ),
      );
    }

    return avatar;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
