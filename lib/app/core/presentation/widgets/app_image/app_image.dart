// ─────────────────────────────────────────────────────────────────
// app_image.dart
//
// Widget احترافي للصور يدعم:
// ✅ Asset + Network
// ✅ أشكال مختلفة: rectangle, rounded, circle
// ✅ Loading shimmer + Error fallback
// ✅ Hero animation جاهزة
// ✅ Aspect ratio control
// ✅ onTap
// ✅ تحكم كامل بالأبعاد من المستخدم
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// app_image_shape.dart
// 
// أشكال الصور المدعومة:
// ✅ rectangle - مستطيل عادي
// ✅ rounded - مستطيل بزوايا دائرية
// ✅ circle - دائري
// ─────────────────────────────────────────────────────────────────

enum AppImageShape {
  /// مستطيل عادي بدون زوايا دائرية
  rectangle,
  
  /// مستطيل بزوايا دائرية (تحدد عن طريق borderRadius)
  rounded,
  
  /// شكل دائري (مثالي للصور الشخصية/Avatars)
  circle;
  
  /// تحقق إذا كان الشكل دائرياً
  bool get isCircle => this == circle;
  
  /// تحقق إذا كان الشكل مدوراً
  bool get isRounded => this == rounded;
  
  /// تحقق إذا كان الشكل مستطيلاً عادياً
  bool get isRectangle => this == rectangle;
}

class AppImage extends StatelessWidget {
  // ───────────────────────────────────────────────────────────────
  // DATA
  // ───────────────────────────────────────────────────────────────

  final String path;
  final bool isNetwork;
  final double? width;         // العرض (يمكن أن null ويتكيف)
  final double? height;        // الارتفاع (يمكن أن null ويتكيف)
  final AppImageShape shape;
  final double borderRadius;    // فعّال فقط مع AppImageShape.rounded
  final BoxFit fit;
  final VoidCallback? onTap;
  final String? heroTag;        // لتفعيل Hero animation
  final String? semanticsLabel;
  final Widget? errorWidget;    // custom error widget
  final Widget? loadingWidget;  // custom loading widget

  // ───────────────────────────────────────────────────────────────
  // CONSTRUCTORS
  // ───────────────────────────────────────────────────────────────

  /// صورة من assets
  const AppImage.asset(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.shape = AppImageShape.rectangle,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.onTap,
    this.heroTag,
    this.semanticsLabel,
    this.errorWidget,
    this.loadingWidget,
  }) : isNetwork = false;

  /// صورة من network
  const AppImage.network(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.shape = AppImageShape.rectangle,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.onTap,
    this.heroTag,
    this.semanticsLabel,
    this.errorWidget,
    this.loadingWidget,
  }) : isNetwork = true;

  /// avatar دائري — shortcut شائع
  const AppImage.avatar(
    this.path, {
    super.key,
    this.width = 48,
    this.height = 48,
    this.fit = BoxFit.cover,
    this.onTap,
    this.heroTag,
    this.semanticsLabel,
    this.errorWidget,
    this.loadingWidget,
    bool isNetwork = true,
  })  : isNetwork = isNetwork,
        shape = AppImageShape.circle,
        borderRadius = 0;

  /// banner عرض كامل
  const AppImage.banner(
    this.path, {
    super.key,
    this.height = 200,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.onTap,
    this.heroTag,
    this.semanticsLabel,
    this.errorWidget,
    this.loadingWidget,
    bool isNetwork = true,
  })  : isNetwork = isNetwork,
        shape = AppImageShape.rounded,
        borderRadius = 16;

  /// صورة مربعة (Square)
  const AppImage.square(
    this.path, {
    super.key,
    required double size,
    this.shape = AppImageShape.rectangle,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.onTap,
    this.heroTag,
    this.semanticsLabel,
    this.errorWidget,
    this.loadingWidget,
    bool isNetwork = true,
  })  : isNetwork = isNetwork,
        width = size,
        height = size;

  // ───────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final w = width;
    final h = height;

    if (w == null && h == null) {
      // إذا كان العرض والارتفاع null، نستخدم SizedBox.expand
      // أو نترك الصورة تأخذ حجمها الطبيعي
    }

    Widget image = _buildImage(w, h);

    // ── تطبيق الشكل (clip)
    image = _applyShape(image, w, h);

    // ── Semantics
    if (semanticsLabel != null) {
      image = Semantics(label: semanticsLabel, image: true, child: image);
    }

    // ── Hero animation
    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    // ── onTap
    if (onTap != null) {
      image = GestureDetector(onTap: onTap, child: image);
    }

    return image;
  }

  // ───────────────────────────────────────────────────────────────
  // BUILD IMAGE
  // ───────────────────────────────────────────────────────────────

  Widget _buildImage(double? w, double? h) {
    if (!isNetwork) {
      return Image.asset(
        path,
        width: w == double.infinity ? null : w,
        height: h,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildError(w, h),
      );
    }

    return Image.network(
      path,
      width: w == double.infinity ? null : w,
      height: h,
      fit: fit,
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return loadingWidget ?? _buildShimmer(w, h);
      },
      errorBuilder: (_, __, ___) => errorWidget ?? _buildError(w, h),
    );
  }

  // ───────────────────────────────────────────────────────────────
  // SHAPE CLIPPING
  // ───────────────────────────────────────────────────────────────

  Widget _applyShape(Widget child, double? w, double? h) => switch (shape) {
        AppImageShape.rectangle => SizedBox(
            width: w == double.infinity ? null : w,
            height: h,
            child: child,
          ),

        AppImageShape.rounded => ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: SizedBox(
              width: w == double.infinity ? null : w,
              height: h,
              child: child,
            ),
          ),

        AppImageShape.circle => ClipOval(
            child: SizedBox(
              width: w,
              height: h,
              child: child,
            ),
          ),
      };

  // ───────────────────────────────────────────────────────────────
  // PLACEHOLDER / ERROR
  // ───────────────────────────────────────────────────────────────

  /// Shimmer بسيط للـ loading
  Widget _buildShimmer(double? w, double? h) {
    final width = w;
    final height = h ?? 100;
    final borderRadiusValue = shape == AppImageShape.circle
        ? (width ?? height) / 2
        : shape == AppImageShape.rounded
            ? borderRadius
            : 0.0;
    
    return _ShimmerBox(
      width: width == double.infinity ? null : width,
      height: height,
      borderRadius: borderRadiusValue,
    );
  }

  /// Error fallback
  Widget _buildError(double? w, double? h) {
    final width = w;
    final height = h ?? 100;
    final iconSize = (width ?? height) * 0.4;
    
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.grey.shade400,
        size: iconSize.clamp(20.0, 80.0),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// _ShimmerBox — shimmer animation بدون package خارجي
// ─────────────────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    this.width,
    required this.height,
    this.borderRadius = 0,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_animation.value - 0.3).clamp(0.0, 1.0),
              _animation.value.clamp(0.0, 1.0),
              (_animation.value + 0.3).clamp(0.0, 1.0),
            ],
            colors: const [
              Color(0xFFE0E0E0),  // grey.shade300
              Color(0xFFF5F5F5),  // grey.shade100
              Color(0xFFE0E0E0),  // grey.shade300
            ],
          ),
        ),
      ),
    );
  }
}