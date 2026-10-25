// ════════════════════════════════════════════════════════════
//  presentation/widgets/products/home_product_card.dart
//  Reusable product card used by Best Products & New Products
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image/app_image.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/domain/entity/product_entity.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';

enum ProductCardSize { normal, featured }

class HomeProductCard extends StatefulWidget {
  const HomeProductCard({
    super.key,
    required this.product,
    this.size = ProductCardSize.normal,
    this.accentColor = const Color(0xFF00E5FF),
    this.onTap,
    this.onAddToCart,
  });

  final ProductEntity product;
  final ProductCardSize size;
  final Color accentColor;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  @override
  State<HomeProductCard> createState() => _HomeProductCardState();
}

class _HomeProductCardState extends State<HomeProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return widget.size == ProductCardSize.featured
        ? _buildFeaturedLayout()
        : _buildNormalLayout();
  }

  // ── Featured: horizontal (full-width) ──────────────────────

  Widget _buildFeaturedLayout() {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withOpacity(0.07)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(13),
                ),
                child: Container(
                  width: 130,
                  height: 130,
                  color: widget.accentColor.withOpacity(0.08),
                  child: _productImage(),
                ),
              ),
              // Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _cardBody(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Normal: vertical card ────────────────────────────────────

  Widget _buildNormalLayout() {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withOpacity(0.07)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(13),
                    ),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: widget.accentColor.withOpacity(0.08),
                      child: _productImage(),
                    ),
                  ),
                  if (widget.product.hasDiscount)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _ProductBadge(
                        label:
                            '-${widget.product.discountPercentage.toStringAsFixed(0)}%',
                        color: const Color(0xFFFF6B6B),
                      ),
                    ),
                  if (widget.product.isFeatured && !widget.product.hasDiscount)
                    const Positioned(
                      top: 10,
                      left: 10,
                      child: _ProductBadge(
                        label: 'HOT 🔥',
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                ],
              ),
              // Body
              Padding(padding: const EdgeInsets.all(12), child: _cardBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productImage() {
    final thumb = widget.product.thumbnail;
    if (thumb != null && thumb.isNotEmpty) {
      return AppImage.network(thumb, fit: BoxFit.cover);
    }
    // Fallback icon placeholder
    return Center(
      child: Icon(
        Icons.image_outlined,
        color: widget.accentColor.withOpacity(0.3),
        size: 40,
      ),
    );
  }

  Widget _cardBody({
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Category
        if (widget.product.categoryName != null)
          AppText.raw(
            widget.product.categoryName!.toUpperCase(),
            type: AppTextType.labelSmall,
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              letterSpacing: 1.5,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 4),

        // Name
        AppText.raw(
          widget.product.name,
          type: AppTextType.labelLarge,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Rating
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFD93D), size: 13),
            const SizedBox(width: 3),
            AppText.raw(
              '${widget.product.rating.toStringAsFixed(1)}  (${widget.product.reviewsCount})',
              type: AppTextType.bodySmall,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Price row
        Row(
          children: [
            AppText.raw(
              '\$${widget.product.effectivePrice.toStringAsFixed(0)}',
              type: AppTextType.titleSmall,
              style: TextStyle(
                color: widget.accentColor,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            if (widget.product.hasDiscount) ...[
              const SizedBox(width: 6),
              AppText.raw(
                '\$${widget.product.price.toStringAsFixed(0)}',
                type: AppTextType.bodySmall,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  decoration: TextDecoration.lineThrough,
                  fontSize: 11,
                ),
              ),
            ],
            const Spacer(),
            GestureDetector(
              onTap: widget.onAddToCart,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.accentColor.withOpacity(0.3),
                  ),
                  color: widget.accentColor.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.add_shopping_cart_outlined,
                  color: widget.accentColor,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Product badge (SALE / HOT / NEW / ECO)
// ─────────────────────────────────────────────

class _ProductBadge extends StatelessWidget {
  const _ProductBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
