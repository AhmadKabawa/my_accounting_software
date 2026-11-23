import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Lays its children in equal-width columns and gives them the height of the
/// tallest one. Unlike IntrinsicHeight it uses no intrinsic queries, so cells
/// may contain LayoutBuilder and other widgets that cannot answer them.
class EqualHeightRow extends MultiChildRenderObjectWidget {
  const EqualHeightRow({super.key, required this.gap, required super.children});

  final double gap;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderEqualHeightRow(gap: gap, textDirection: Directionality.of(context));

  @override
  void updateRenderObject(
    BuildContext context,
    RenderEqualHeightRow renderObject,
  ) {
    renderObject
      ..gap = gap
      ..textDirection = Directionality.of(context);
  }
}

class _CellParentData extends ContainerBoxParentData<RenderBox> {}

class RenderEqualHeightRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _CellParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _CellParentData> {
  RenderEqualHeightRow({
    required double gap,
    required TextDirection textDirection,
  }) : _gap = gap,
       _textDirection = textDirection;

  double _gap;
  double get gap => _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _CellParentData) {
      child.parentData = _CellParentData();
    }
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.smallest;
      return;
    }

    final width = constraints.maxWidth;
    final cell = (width - _gap * (childCount - 1)) / childCount;
    final loose = BoxConstraints(minWidth: cell, maxWidth: cell);
    var tallest = 0.0;

    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(loose, parentUsesSize: true);
      tallest = math.max(tallest, child.size.height);
    }

    final tight = BoxConstraints.tightFor(width: cell, height: tallest);
    var index = 0;
    for (
      var child = firstChild;
      child != null;
      child = childAfter(child), index++
    ) {
      if (child.size.height != tallest) {
        child.layout(tight, parentUsesSize: true);
      }
      final dx = index * (cell + _gap);
      (child.parentData! as _CellParentData).offset = Offset(
        _textDirection == TextDirection.rtl ? width - dx - cell : dx,
        0,
      );
    }

    size = constraints.constrain(Size(width, tallest));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
