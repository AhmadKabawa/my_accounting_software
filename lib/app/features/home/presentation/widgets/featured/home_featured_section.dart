// ════════════════════════════════════════════════════════════
//  presentation/widgets/featured/home_featured_section.dart
//  Vertical list of featured gear cards
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/domain/entity/product_entity.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/shared/home_section_header.dart';

class HomeFeaturedSection extends StatelessWidget {
  const HomeFeaturedSection({super.key, required this.scrollOffset});

  final double scrollOffset;

  static const _accentColors = [
    Color(0xFF00E5FF),
    Color(0xFF64FFDA),
    Color(0xFF74B9FF),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.featuredProductsState != c.featuredProductsState,
      builder: (_, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            HomeSectionHeader(
              label: 'FEATURED GEAR',
              scrollOffset: scrollOffset,
              revealAt: 1200,
              accentColor: const Color(0xFF74B9FF),
            ),
            const SizedBox(height: 16),
            state.featuredProductsState.maybeWhen(
              loading: () => const _FeaturedShimmer(),
              loaded: (page) =>
                  _FeaturedList(products: page.items.take(5).toList()),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _FeaturedList extends StatelessWidget {
  const _FeaturedList({required this.products});

  final List<ProductEntity> products;

  static const _accentColors = [
    Color(0xFF00E5FF),
    Color(0xFF64FFDA),
    Color(0xFF74B9FF),
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: products.asMap().entries.map((e) {
          final color = _accentColors[e.key % _accentColors.length];
          return Padding(
            padding: EdgeInsets.only(
              bottom: e.key < products.length - 1 ? 12 : 0,
            ),
            child: _FeaturedCard(product: e.value, accentColor: color),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Individual featured card (horizontal strip)
// ─────────────────────────────────────────────

class _FeaturedCard extends StatefulWidget {
  const _FeaturedCard({required this.product, required this.accentColor});

  final ProductEntity product;
  final Color accentColor;

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 100,
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
              // Accent left bar
              Container(
                width: 3,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Icon box
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: widget.accentColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText.raw(
                      widget.product.name,
                      type: AppTextType.titleSmall,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (widget.product.description != null)
                      AppText.raw(
                        widget.product.description!,
                        type: AppTextType.bodySmall,
                        style: TextStyle(color: Colors.white.withOpacity(0.4)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    AppText.raw(
                      '\$${widget.product.effectivePrice.toStringAsFixed(2)}',
                      type: AppTextType.labelMedium,
                      style: TextStyle(
                        color: widget.accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Shimmer
// ─────────────────────────────────────────────

class _FeaturedShimmer extends StatelessWidget {
  const _FeaturedShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          3,
          (i) => Container(
            height: 100,
            margin: EdgeInsets.only(bottom: i < 2 ? 12 : 0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
