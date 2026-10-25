// ════════════════════════════════════════════════════════════
//  presentation/screens/home_screen.dart
//  Root screen — owns scroll controller + AppBar fade logic.
//  Delegates each visual section to its own widget.
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_appbar/app_appbar.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/banner/home_hero_banner.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/categories/home_categories_section.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/featured/home_featured_section.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/products/home_best_products_section.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/products/home_new_products_section.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/shared/home_promo_banner.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/sport_cards/hone_sport_cards_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  double _appBarProgress = 0.0;
  double _scrollOffset = 0.0;

  static const double _appBarFadeDistance = 160.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Kick off all data loads
    context.read<HomeCubit>().init();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final progress = (offset / _appBarFadeDistance).clamp(0.0, 1.0);
    if (offset != _scrollOffset || progress != _appBarProgress) {
      setState(() {
        _scrollOffset = offset;
        _appBarProgress = progress;
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppAppBar(progress: _appBarProgress),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero banner slider ──────────────────────────────
          SliverToBoxAdapter(
            child: HomeHeroBanner(scrollOffset: _scrollOffset),
          ),

          // // // ── Categories + Sport cards ────────────────────────
          SliverToBoxAdapter(
            child: HomeCategoriesSection(scrollOffset: _scrollOffset),
          ),
          // SliverToBoxAdapter(
          //   child: HomeSportCardsSection(scrollOffset: _scrollOffset),
          // ),

          // // ── Best products grid ──────────────────────────────
          // SliverToBoxAdapter(
          //   child: HomeBestProductsSection(scrollOffset: _scrollOffset),
          // ),

          // // ── Promo banner ────────────────────────────────────
          // const SliverToBoxAdapter(child: HomePromoBanner()),

          // // ── New products horizontal list ────────────────────
          // SliverToBoxAdapter(
          //   child: HomeNewProductsSection(scrollOffset: _scrollOffset),
          // ),

          // // ── Featured gear list ──────────────────────────────
          // SliverToBoxAdapter(
          //   child: HomeFeaturedSection(scrollOffset: _scrollOffset),
          // ),

          // const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}
