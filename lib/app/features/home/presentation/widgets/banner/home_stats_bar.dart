// ════════════════════════════════════════════════════════════
//  presentation/widgets/banner/home_stats_bar.dart
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/domain/entity/banner_entity.dart';

class HomeStatsBar extends StatelessWidget {
  const HomeStatsBar({super.key, required this.data});

  final HeroBannerEntity data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(number: data.statNumber1, label: data.statLabel1),
        _StatDivider(),
        _Stat(number: data.statNumber2, label: data.statLabel2),
        _StatDivider(),
        _Stat(number: data.statNumber3, label: data.statLabel3),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.raw(
          number,
          type: AppTextType.titleLarge,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        AppText.raw(
          label,
          type: AppTextType.labelSmall,
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            letterSpacing: 1.5,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 28),
      color: Colors.white.withOpacity(0.12),
    );
  }
}
