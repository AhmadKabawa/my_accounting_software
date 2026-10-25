// ════════════════════════════════════════════════════════════
//  presentation/widgets/sport_cards/home_sport_cards_section.dart
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/features/home/domain/entity/category_entity.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';

class HomeSportCardsSection extends StatelessWidget {
  const HomeSportCardsSection({super.key, required this.scrollOffset});

  final double scrollOffset;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.categoriesState != c.categoriesState,
      builder: (_, state) {
        final cats = state.categoriesState.dataOrNull ?? [];
        // Exclude the "All" category for the card view
        final sportCats = cats.where((c) => c.id != 'all').toList();

        return SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            itemCount: sportCats.isEmpty ? 5 : sportCats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              if (sportCats.isEmpty) return const _SportCardShimmer();
              return _SportCard(data: sportCats[i]);
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Single sport card
// ─────────────────────────────────────────────

class _SportCard extends StatefulWidget {
  const _SportCard({required this.data});

  final CategoryEntity data;

  @override
  State<_SportCard> createState() => _SportCardState();
}

class _SportCardState extends State<_SportCard> {
  bool _pressed = false;

  // Map category id → gradient colors
  static const _gradients = <String, List<Color>>{
    'hiking': [Color(0xFF0D3B2E), Color(0xFF1A6B52)],
    'cycling': [Color(0xFF0D2B3E), Color(0xFF1A5270)],
    'running': [Color(0xFF3E1A0D), Color(0xFF7A3520)],
    'climbing': [Color(0xFF1A1A3E), Color(0xFF35358A)],
    'snow': [Color(0xFF0D2A3E), Color(0xFF1A5A7A)],
    'yoga': [Color(0xFF2E0D3B), Color(0xFF6B1A6B)],
  };

  static const _emojis = <String, String>{
    'hiking': '⛺',
    'cycling': '🚴',
    'running': '🏃',
    'climbing': '🧗',
    'snow': '❄️',
    'yoga': '🧘',
  };

  @override
  Widget build(BuildContext context) {
    final colors =
        _gradients[widget.data.id] ??
        [const Color(0xFF1A1A2E), const Color(0xFF16213E)];
    final emoji = _emojis[widget.data.id] ?? '🏅';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 130,
        height: 200,
        transform: Matrix4.identity()..scale(_pressed ? 0.96 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Emoji centered
            Center(child: Text(emoji, style: const TextStyle(fontSize: 52))),

            // Bottom gradient
            Positioned(
              top: 100,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.92),
                    ],
                  ),
                ),
              ),
            ),

            // Label & meta
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.data.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white.withOpacity(0.6),
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.data.productCount}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SportCardShimmer extends StatelessWidget {
  const _SportCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
