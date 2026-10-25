// ════════════════════════════════════════════════════════════
//  presentation/widgets/products/home_new_products_section.dart
//  Horizontal scroll with load-more trigger at the end
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/features/home/domain/entity/product_entity.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/products/home_product_card.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/shared/home_section_header.dart';

class HomeNewProductsSection extends StatelessWidget {
  const HomeNewProductsSection({super.key, required this.scrollOffset});

  final double scrollOffset;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.newProductsState != c.newProductsState,
      builder: (ctx, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            HomeSectionHeader(
              label: 'NEW ARRIVALS',
              scrollOffset: scrollOffset,
              revealAt: 1000,
              accentColor: const Color(0xFF74B9FF),
              actionLabel: 'SEE ALL',
              onActionTap: () {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: state.newProductsState.maybeWhen(
                loading: () => _NewProductsShimmer(),
                loaded: (page) => _NewProductsList(
                  products: page.items,
                  hasMore: page.hasNextPage,
                  onLoadMore: () => ctx.read<HomeCubit>().loadMoreNewProducts(),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Horizontal list with load-more
// ─────────────────────────────────────────────

class _NewProductsList extends StatefulWidget {
  const _NewProductsList({
    required this.products,
    required this.hasMore,
    required this.onLoadMore,
  });

  final List<ProductEntity> products;
  final bool hasMore;
  final VoidCallback onLoadMore;

  @override
  State<_NewProductsList> createState() => _NewProductsListState();
}

class _NewProductsListState extends State<_NewProductsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (widget.hasMore) widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.products.length + (widget.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        if (i == widget.products.length) {
          return const _LoadMoreIndicator();
        }
        return SizedBox(
          width: 155,
          child: HomeProductCard(
            product: widget.products[i],
            accentColor: const Color(0xFF74B9FF),
            onTap: () {},
            onAddToCart: () {},
          ),
        );
      },
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: const Color(0xFF74B9FF).withOpacity(0.5),
        ),
      ),
    );
  }
}

class _NewProductsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => Container(
        width: 155,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
