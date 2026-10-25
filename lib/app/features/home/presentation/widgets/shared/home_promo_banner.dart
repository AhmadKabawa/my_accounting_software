// ════════════════════════════════════════════════════════════
//  presentation/widgets/shared/home_promo_banner.dart
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

class HomePromoBanner extends StatelessWidget {
  const HomePromoBanner({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF00E5FF).withOpacity(0.12),
              const Color(0xFF64FFDA).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative bg text
            Positioned(
              right: -10,
              top: -10,
              child: Text(
                'ECO',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00E5FF).withOpacity(0.05),
                  height: 1,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.raw(
                  '🌿 SUSTAINABILITY CAMPAIGN',
                  type: AppTextType.labelSmall,
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 8),
                AppText.raw(
                  'Green Gear Initiative',
                  type: AppTextType.titleLarge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                AppText.raw(
                  '100% recycled materials · Carbon neutral shipping · Certified B-Corp',
                  type: AppTextType.bodySmall,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    AppText.raw(
                      'LEARN MORE',
                      type: AppTextType.labelMedium,
                      style: const TextStyle(
                        color: Color(0xFF00E5FF),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF00E5FF),
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
