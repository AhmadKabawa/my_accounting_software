// ════════════════════════════════════════════════════════════
//  presentation/widgets/categories/home_categories_section.dart
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/features/home/domain/entity/category_entity.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/shared/home_section_header.dart';

class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({super.key, required this.scrollOffset});

  final double scrollOffset;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) =>
          p.categoriesState != c.categoriesState ||
          p.selectedCategoryId != c.selectedCategoryId,
      builder: (ctx, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            HomeSectionHeader(
              label: 'SHOP BY CATEGORY',
              scrollOffset: scrollOffset,
              revealAt: 400,
              actionLabel: 'SEE ALL',
              onActionTap: () {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: state.categoriesState.maybeWhen(
                loading: () => const _CategoriesShimmer(),
                loaded: (cats) => _CategoriesList(
                  categories: cats,
                  selectedId: state.selectedCategoryId,
                  onSelect: (id) => ctx.read<HomeCubit>().selectCategory(id),
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
//  Categories horizontal list
// ─────────────────────────────────────────────

class _CategoriesList extends StatelessWidget {
  const _CategoriesList({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<CategoryEntity> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, i) => _CategoryChip(
        data: categories[i],
        isSelected: categories[i].id == selectedId,
        onTap: () => onSelect(categories[i].id),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Single category chip
// ─────────────────────────────────────────────

class _CategoryChip extends StatefulWidget {
  const _CategoryChip({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryEntity data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected || _pressed;

    return MouseRegion(
      onEnter: (_) => setState(() => _pressed = true),
      onExit: (_) => setState(() => _pressed = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: isActive
                  ? widget.data.accentColor
                  : Colors.white.withOpacity(0.1),
            ),
            borderRadius: BorderRadius.circular(34),
            color: isActive
                ? widget.data.accentColor.withOpacity(0.1)
                : const Color(0xFF111F3A),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive
                      ? widget.data.accentColor
                      : const Color(0xFF0A0E1A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.data.icon,
                  color: isActive
                      ? const Color(0xFF0A0E1A)
                      : widget.data.accentColor,
                  size: 18,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  widget.data.label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(isActive ? 1 : 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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
//  Shimmer placeholder
// ─────────────────────────────────────────────

class _CategoriesShimmer extends StatelessWidget {
  const _CategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) => Container(
        width: 110,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(34),
        ),
      ),
    );
  }
}
