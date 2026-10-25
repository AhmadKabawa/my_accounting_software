// ════════════════════════════════════════════════════════════
//  presentation/widgets/banner/home_hero_text_content.dart
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';
import 'package:accounting_software/app/features/home/domain/entity/banner_entity.dart';

class HomeHeroTextContent extends StatelessWidget {
  const HomeHeroTextContent({
    super.key,
    required this.isMobile,
    required this.data,
  });

  final bool isMobile;
  final HeroBannerEntity data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Badge ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: data.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: data.accentColor.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.accentColor,
                  boxShadow: [
                    BoxShadow(color: data.accentColor, blurRadius: 6),
                  ],
                ),
              ),
              AppText.raw(
                data.badge,
                type: AppTextType.labelSmall,
                style: TextStyle(
                  color: data.accentColor,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 14 : 18),

        // ── Heading ───────────────────────────────────────────
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: DefaultTextStyle.of(context).style.fontFamily,
              fontSize: isMobile ? 46 : 62,
              fontWeight: FontWeight.w900,
              height: 0.88,
              letterSpacing: -2,
            ),
            children: [
              TextSpan(
                text: data.titleLine1,
                style: const TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: data.titleAccent,
                style: TextStyle(color: data.accentColor),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 14 : 18),

        // ── Subtitle ──────────────────────────────────────────
        AppText.raw(
          data.subtitle,
          type: AppTextType.bodyMedium,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 0.3,
            height: 1.6,
          ),
        ),
        SizedBox(height: isMobile ? 24 : 30),

        // ── CTAs ──────────────────────────────────────────────
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _HeroCyanButton(
              label: 'EXPLORE NOW',
              icon: Icons.arrow_forward_rounded,
              accentColor: data.accentColor,
              onPressed: () {},
            ),
            _HeroGhostButton(label: 'VIEW CATALOG', onPressed: () {}),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  CTA Buttons (banner-specific)
// ─────────────────────────────────────────────

class _HeroCyanButton extends StatefulWidget {
  const _HeroCyanButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.accentColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color accentColor;

  @override
  State<_HeroCyanButton> createState() => _HeroCyanButtonState();
}

class _HeroCyanButtonState extends State<_HeroCyanButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
            color: widget.accentColor.withOpacity(_hovered ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor
                  : widget.accentColor.withOpacity(0.55),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.raw(
                widget.label,
                type: AppTextType.labelMedium,
                style: TextStyle(
                  color: widget.accentColor,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Icon(widget.icon, color: widget.accentColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroGhostButton extends StatefulWidget {
  const _HeroGhostButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_HeroGhostButton> createState() => _HeroGhostButtonState();
}

class _HeroGhostButtonState extends State<_HeroGhostButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Colors.white.withOpacity(_hovered ? 0.35 : 0.18),
            ),
          ),
          child: AppText.raw(
            widget.label,
            type: AppTextType.labelMedium,
            style: TextStyle(
              color: Colors.white.withOpacity(_hovered ? 0.9 : 0.55),
              letterSpacing: 1.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
