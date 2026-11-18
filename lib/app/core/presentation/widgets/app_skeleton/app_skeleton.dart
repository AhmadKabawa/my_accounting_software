import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:accounting_software/app/core/presentation/design_system/responsive/engine/app_enums.dart';
import 'package:accounting_software/app/core/presentation/design_system/tokens/app_motion.dart';

/// Responsive loading placeholders that preserve the shape of their content.
///
/// The shimmer is delayed briefly to avoid flashing during fast requests and
/// becomes static when the platform requests reduced motion.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton.line({
    super.key,
    this.width,
    this.height,
    this.delay = const Duration(milliseconds: 200),
  }) : variant = AppSkeletonVariant.line,
       columns = 1;

  const AppSkeleton.block({
    super.key,
    this.width,
    this.height,
    this.delay = const Duration(milliseconds: 200),
  }) : variant = AppSkeletonVariant.block,
       columns = 1;

  const AppSkeleton.card({
    super.key,
    this.width,
    this.height,
    this.delay = const Duration(milliseconds: 200),
  }) : variant = AppSkeletonVariant.card,
       columns = 1;

  const AppSkeleton.tableRow({
    super.key,
    this.width,
    this.height,
    this.delay = const Duration(milliseconds: 200),
    this.columns = 4,
  }) : variant = AppSkeletonVariant.tableRow,
       assert(columns > 0);

  final AppSkeletonVariant variant;
  final double? width;
  final double? height;
  final Duration delay;
  final int columns;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

enum AppSkeletonVariant { line, block, card, tableRow }

class _AppSkeletonState extends State<AppSkeleton> {
  Timer? _timer;
  bool _initialized = false;
  bool _visible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    if (AppMotion.reduceMotion(context) || widget.delay == Duration.zero) {
      _visible = true;
      return;
    }

    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return SizedBox(
        width: _resolvedWidth(context),
        height: _resolvedHeight(context),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final baseColor = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.06),
      scheme.surface,
    );
    final highlightColor = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.12),
      scheme.surface,
    );
    final reduceMotion = AppMotion.reduceMotion(context);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      enabled: !reduceMotion,
      child: _buildPlaceholder(context, baseColor),
    );
  }

  double _resolvedWidth(BuildContext context) =>
      widget.width ?? switch (widget.variant) {
        AppSkeletonVariant.line => AppComponentSize.cardWidth.of(context),
        AppSkeletonVariant.block ||
        AppSkeletonVariant.card ||
        AppSkeletonVariant.tableRow => double.infinity,
      };

  double _resolvedHeight(BuildContext context) =>
      widget.height ?? switch (widget.variant) {
        AppSkeletonVariant.line => AppIconSize.sm.of(context),
        AppSkeletonVariant.block || AppSkeletonVariant.card =>
          AppComponentSize.cardHeight.of(context),
        AppSkeletonVariant.tableRow => AppComponentSize.hitArea.of(context),
      };

  Widget _buildPlaceholder(BuildContext context, Color color) {
    final radius = widget.variant == AppSkeletonVariant.card
        ? AppRadius.lg.of(context)
        : AppRadius.sm.of(context);

    Widget shape({
      required double height,
      double? width,
      double? radius,
    }) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius ?? AppRadius.sm.of(context)),
          ),
        ),
      );
    }

    switch (widget.variant) {
      case AppSkeletonVariant.line:
        return shape(
          width: widget.width ?? AppComponentSize.cardWidth.of(context),
          height: widget.height ?? AppIconSize.sm.of(context),
          radius: radius,
        );
      case AppSkeletonVariant.block:
        return shape(
          width: widget.width,
          height: widget.height ?? AppComponentSize.cardHeight.of(context),
          radius: radius,
        );
      case AppSkeletonVariant.card:
        return shape(
          width: widget.width,
          height: widget.height ?? AppComponentSize.cardHeight.of(context),
          radius: radius,
        );
      case AppSkeletonVariant.tableRow:
        return SizedBox(
          width: widget.width,
          height: widget.height ?? AppComponentSize.hitArea.of(context),
          child: Row(
            children: List<Widget>.generate(widget.columns, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: index == widget.columns - 1
                        ? 0
                        : AppSpacing.sm.of(context),
                  ),
                  child: shape(
                    height: AppIconSize.sm.of(context),
                    radius: radius,
                  ),
                ),
              );
            }),
          ),
        );
    }
  }
}
