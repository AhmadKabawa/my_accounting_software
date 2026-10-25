// ════════════════════════════════════════════════════════════
//  presentation/widgets/shared/home_section_header.dart
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

const _kCyan = Color(0xFF00E5FF);

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.label,
    required this.scrollOffset,
    required this.revealAt,
    this.accentColor = _kCyan,
    this.actionLabel,
    this.onActionTap,
  });

  final String label;
  final double scrollOffset;
  final double revealAt;
  final Color accentColor;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final revealed = scrollOffset >= revealAt - 200;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: revealed ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (_, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - v)),
            child: child,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            AppText.raw(
              label,
              type: AppTextType.labelLarge,
              style: const TextStyle(
                color: Colors.white,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (actionLabel != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: onActionTap,
                child: AppText.raw(
                  '$actionLabel →',
                  type: AppTextType.labelSmall,
                  style: TextStyle(
                    color: accentColor.withOpacity(0.7),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
