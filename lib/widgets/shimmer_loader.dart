import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../app/theme.dart';

/// Shimmer loading placeholder for premium skeleton screens.
class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 80,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceLight,
      highlightColor: AppTheme.border,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  /// Creates a list-style shimmer with N items.
  static Widget list({int count = 5, double itemHeight = 72}) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoader(height: itemHeight),
        ),
      ),
    );
  }

  /// Creates a grid-style shimmer.
  static Widget grid({int count = 6, double itemHeight = 140}) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(
        count,
        (i) => ShimmerLoader(width: 280, height: itemHeight),
      ),
    );
  }
}
