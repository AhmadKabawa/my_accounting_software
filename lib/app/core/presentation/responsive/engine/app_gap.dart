import 'package:flutter/material.dart';

/// A flexible gap widget that inserts space in Row, Column, or Flex layouts.
///
/// Automatically detects axis direction from ancestor Flex widget.
/// If no Flex ancestor is found, defaults to vertical spacing.
///
/// ```dart
/// Column(
///   children: [
///     Text('Hello'),
///     Gap(16),          // Vertical gap (auto-detected)
///     Text('World'),
///   ],
/// )
///
/// Row(
///   children: [
///     Icon(Icons.star),
///     Gap(8),           // Horizontal gap (auto-detected)
///     Text('Label'),
///   ],
/// )
///
/// // Force axis explicitly:
/// Gap(12, axis: Axis.horizontal)
///
/// // Expand to fill remaining space (like Spacer):
/// Gap.expand()
/// ```
class Gap extends StatelessWidget {
  final double size;

  /// Force a specific axis. If null, auto-detected from ancestor Flex.
  final Axis? axis;

  /// If true, expands like a [Spacer] (ignores [size]).
  final bool expand;

  const Gap(
    this.size, {
    this.axis,
    this.expand = false,
    super.key,
  });

  /// Creates an expanding gap (equivalent to [Spacer]).
  const Gap.expand({super.key})
      : size = 0,
        axis = null,
        expand = true;

  Axis _resolveAxis(BuildContext context) {
    if (axis != null) return axis!;

    // Walk up the tree to the nearest Flex ancestor. `is Flex` (not an
    // exact-type lookup) is required because Row and Column are subclasses.
    Axis? direction;
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is Flex) {
        direction = widget.direction;
        return false;
      }
      return true;
    });
    return direction ?? Axis.vertical;
  }

  @override
  Widget build(BuildContext context) {
    if (expand) return const Spacer();

    final resolvedAxis = _resolveAxis(context);
    return resolvedAxis == Axis.vertical
        ? SizedBox(height: size)
        : SizedBox(width: size);
  }
}