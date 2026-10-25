// ════════════════════════════════════════════════════════════
//  presentation/widgets/products/home_best_products_section.dart
//  2-column grid — first card spans full width (featured)
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/features/home/domain/entity/product_entity.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/products/home_product_card.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/shared/home_section_header.dart';

class HomeBestProductsSection extends StatelessWidget {
  const HomeBestProductsSection({super.key, required this.scrollOffset});

  final double scrollOffset;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.bestProductsState != c.bestProductsState,
      builder: (ctx, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            HomeSectionHeader(
              label: 'BEST PRODUCTS',
              scrollOffset: scrollOffset,
              revealAt: 600,
              accentColor: const Color(0xFF64FFDA),
              actionLabel: 'VIEW ALL',
              onActionTap: () {},
            ),
            const SizedBox(height: 16),
            state.bestProductsState.maybeWhen(
              loading: () => const _BestProductsShimmer(),
              loaded: (page) => _BestProductsGrid(products: page.items),
              error: (msg) => _ErrorState(message: msg),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Grid layout
// ─────────────────────────────────────────────

class _BestProductsGrid extends StatelessWidget {
  const _BestProductsGrid({required this.products});

  final List<ProductEntity> products;

  // Map index → accent color for visual variety
  static const _accentColors = [
    Color(0xFF00E5FF),
    Color(0xFF64FFDA),
    Color(0xFF74B9FF),
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
  ];

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const _EmptyState();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // First product spans full width (featured style)
          if (products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HomeProductCard(
                product: products[0],
                size: ProductCardSize.featured,
                accentColor: _accentColors[0],
                onTap: () {},
                onAddToCart: () {},
              ),
            ),

          // Remaining in 2-column grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: (products.length - 1).clamp(0, 4),
            itemBuilder: (_, i) {
              final product = products[i + 1];
              final color = _accentColors[(i + 1) % _accentColors.length];
              return HomeProductCard(
                product: product,
                accentColor: color,
                onTap: () {},
                onAddToCart: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Loading shimmer
// ─────────────────────────────────────────────

class _BestProductsShimmer extends StatelessWidget {
  const _BestProductsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Featured shimmer
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 12),
          // Grid shimmer
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No products available',
          style: TextStyle(color: Colors.white38),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(message, style: const TextStyle(color: Color(0xFFFF6B6B))),
      ),
    );
  }
}
