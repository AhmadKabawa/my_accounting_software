// ════════════════════════════════════════════════════════════
//  presentation/widgets/shared/home_appbar.dart
// ════════════════════════════════════════════════════════════

import 'dart:ui';

import 'package:flutter/material.dart';

class AppAppBar extends StatelessWidget {
  const AppAppBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Stack(
          children: [
            if (value > 0.01)
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 20 * value,
                      sigmaY: 20 * value,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF0A0E1A,
                        ).withOpacity(0.82 * value),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.15 * value),
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            AppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                    color: Colors.white.withOpacity(value),
                  ),
                  children: [
                    const TextSpan(text: 'VAU'),
                    TextSpan(
                      text: 'DE',
                      style: TextStyle(
                        color: const Color(0xFF00E5FF).withOpacity(value),
                      ),
                    ),
                  ],
                ),
              ),
              leading: _NavIconButton(icon: Icons.menu_rounded),
              actions: [
                _NavIconButton(icon: Icons.search_rounded),
                _NavIconButton(icon: Icons.shopping_bag_outlined),
                const SizedBox(width: 4),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable nav icon button
// ─────────────────────────────────────────────

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white.withOpacity(0.85)),
      onPressed: onPressed ?? () {},
      splashRadius: 20,
    );
  }
}
