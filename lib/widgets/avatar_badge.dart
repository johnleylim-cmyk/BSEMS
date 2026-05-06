import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Circular avatar with optional online badge and gradient border.
/// Supports network URLs and base64 data URIs for images.
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

  /// Parse a base64 data URI into bytes, or return null.
  static Uint8List? _parseBase64(String url) {
    if (url.startsWith('data:')) {
      final commaIndex = url.indexOf(',');
      if (commaIndex != -1) {
        try {
          return base64Decode(url.substring(commaIndex + 1));
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);

    Widget avatar;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final base64Bytes = _parseBase64(imageUrl!);
      final ImageProvider imageProvider = base64Bytes != null
          ? MemoryImage(base64Bytes)
          : NetworkImage(imageUrl!);
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundImage: imageProvider,
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
