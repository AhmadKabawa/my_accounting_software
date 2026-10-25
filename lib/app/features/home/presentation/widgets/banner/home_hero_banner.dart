// ════════════════════════════════════════════════════════════
//  presentation/widgets/banner/home_hero_banner.dart
//  Stateful slider that auto-plays and syncs to HomeCubit
//  for banner index tracking.
// ════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:accounting_software/app/core/foundation/constants/image_constants.dart';
import 'package:accounting_software/app/core/presentation/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image/app_image.dart';
import 'package:accounting_software/app/features/home/domain/entity/banner_entity.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_cubit.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';
import 'package:accounting_software/app/features/home/presentation/cubit/home_state.dart';
import 'package:accounting_software/app/features/home/presentation/pages/data.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/banner/home_hero_text_content.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/banner/home_stats_bar.dart';
import 'package:accounting_software/app/features/home/presentation/widgets/shared/home_painters.dart';

class HomeHeroBanner extends StatefulWidget {
  const HomeHeroBanner({super.key, required this.scrollOffset});

  final double scrollOffset;

  static const double _bgSpeed = 0.3;
  static const double _fgSpeed = 0.55;
  static const double _textSpeed = 0.12;

  @override
  State<HomeHeroBanner> createState() => _HomeHeroBannerState();
}

class _HomeHeroBannerState extends State<HomeHeroBanner>
    with TickerProviderStateMixin {
  int _current = 0;
  int _previous = 0;
  Timer? _timer;

  late AnimationController _bgCtrl;
  late AnimationController _fgCtrl;
  late AnimationController _textCtrl;
  late AnimationController _statsCtrl;

  late Animation<double> _bgFade;
  late Animation<Offset> _fgSlide;
  late Animation<double> _fgFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _textScale;
  late Animation<Offset> _statsSlide;
  late Animation<double> _statsFade;

  static const _autoPlayDuration = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();
    _buildAnimations();
    _playEntrance();
    _timer = Timer.periodic(_autoPlayDuration, (_) => _next(context));
  }

  void _buildAnimations() {
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);

    _fgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fgSlide = Tween<Offset>(
      begin: const Offset(0.08, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fgCtrl, curve: Curves.easeOutCubic));
    _fgFade = CurvedAnimation(parent: _fgCtrl, curve: Curves.easeOut);

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textScale = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _statsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _statsSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOutBack));
    _statsFade = CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut);
  }

  void _playEntrance() {
    _bgCtrl.forward(from: 0);
    _fgCtrl.forward(from: 0);
    _textCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _statsCtrl.forward(from: 0);
    });
  }

  Future<void> _transitionTo(BuildContext ctx, int index) async {
    if (index == _current) return;

    await Future.wait([_textCtrl.reverse(), _statsCtrl.reverse()]);
    await _fgCtrl.reverse();

    setState(() {
      _previous = _current;
      _current = index;
    });

    ctx.read<HomeCubit>().changeBannerIndex(index);

    _bgCtrl.forward(from: 0);
    _fgCtrl.forward(from: 0);
    _textCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _statsCtrl.forward(from: 0);
    });
  }

  void _next(BuildContext ctx) {
    final banners = context.read<HomeCubit>().state.bannersState.dataOrNull;
    if (banners == null || banners.isEmpty) return;
    _transitionTo(ctx, (_current + 1) % banners.length);
  }

  void _goTo(BuildContext ctx, int i) {
    _timer?.cancel();
    _transitionTo(ctx, i).then((_) {
      _timer = Timer.periodic(_autoPlayDuration, (_) => _next(ctx));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bgCtrl.dispose();
    _fgCtrl.dispose();
    _textCtrl.dispose();
    _statsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (p, c) => p.bannersState != c.bannersState,
      builder: (ctx, state) {
        final banners =
            state.bannersState.dataOrNull ??
            [
              HeroBannerEntity(
                bgImage: AppPathImages.banner.path,
                personImage: AppPathImages.banner2.path,
                badge: 'NEW COLLECTION 2025',
                titleLine1: 'WELCOME\nTO ',
                titleAccent: 'VAUDE',
                subtitle:
                    'Gear crafted for every adventure\n— from summit to trail.',
                statNumber1: '500+',
                statLabel1: 'PRODUCTS',
                statNumber2: '40+',
                statLabel2: 'COUNTRIES',
                statNumber3: '1974',
                statLabel3: 'FOUNDED',
                accentColor: kAccentCyan,
              ),
              HeroBannerEntity(
                bgImage: AppPathImages.bannerB.path,
                personImage: AppPathImages.sports1.path,
                badge: 'SUMMER DROP 2025',
                titleLine1: 'RIDE\nTHE ',
                titleAccent: 'TRAIL',
                subtitle: 'MTB & cycling gear built\nfor the toughest terrain.',
                statNumber1: '120+',
                statLabel1: 'BIKE GEAR',
                statNumber2: '98%',
                statLabel2: 'RATED',
                statNumber3: 'ECO',
                statLabel3: 'CERTIFIED',
                accentColor: kAccentTeal,
              ),
              HeroBannerEntity(
                bgImage: AppPathImages.bannerB.path,
                personImage: AppPathImages.sports2.path,
                badge: 'WINTER READY',
                titleLine1: 'CONQUER\nTHE ',
                titleAccent: 'COLD',
                subtitle: 'Premium winter gear\nbuilt to perform at -20°C.',
                statNumber1: '-20°C',
                statLabel1: 'RATED',
                statNumber2: '3-IN-1',
                statLabel2: 'LAYERS',
                statNumber3: '100%',
                statLabel3: 'WINDPROOF',
                accentColor: kAccentBlue,
              ),
            ];
        if (banners.isEmpty) return const SizedBox.shrink();

        return _buildBanner(ctx, banners);
      },
    );
  }

  Widget _buildBanner(BuildContext ctx, List<HeroBannerEntity> banners) {
    final sw = context.ui.screen.width();
    final sh = context.ui.screen.height();
    final isMobile = context.ui.screen.isMobile;

    final heroHeight = (sw / 1.6).clamp(380.0, sh * 0.8);
    final bgOffset = widget.scrollOffset * HomeHeroBanner._bgSpeed;
    final fgOffset = widget.scrollOffset * HomeHeroBanner._fgSpeed;
    final textOffset = widget.scrollOffset * HomeHeroBanner._textSpeed;
    final heroOpacity = (1.0 - widget.scrollOffset / (heroHeight * 0.65)).clamp(
      0.0,
      1.0,
    );

    final current = banners[_current.clamp(0, banners.length - 1)];
    final previous = banners[_previous.clamp(0, banners.length - 1)];

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: sh * 0.8, minHeight: 380.0),
      child: SizedBox(
        height: heroHeight,
        child: Opacity(
          opacity: heroOpacity,
          child: ClipRect(
            child: Stack(
              children: [
                // ── Layer 1: Previous background ────────────────
                PositionedDirectional(
                  top: -bgOffset,
                  start: 0,
                  end: 0,
                  height: heroHeight + 80,
                  child: AppImage.asset(previous.bgImage, fit: BoxFit.cover),
                ),

                // ── Layer 2: New background crossfade ───────────
                PositionedDirectional(
                  top: -bgOffset,
                  start: 0,
                  end: 0,
                  height: heroHeight + 80,
                  child: FadeTransition(
                    opacity: _bgFade,
                    child: AppImage.asset(current.bgImage, fit: BoxFit.cover),
                  ),
                ),

                // ── Layer 3: Grid texture ───────────────────────
                const Positioned.fill(child: HomeGridOverlay()),

                // ── Layer 4: Accent glows ───────────────────────
                AnimatedBuilder(
                  animation: _bgFade,
                  builder: (_, __) {
                    final color = Color.lerp(
                      previous.accentColor,
                      current.accentColor,
                      _bgFade.value,
                    )!;
                    return Stack(
                      children: [
                        Positioned(
                          left: -100,
                          bottom: -80,
                          child: HomeRadialGlow(
                            radius: 320,
                            color: color.withOpacity(0.08),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // ── Layer 5: Person image ───────────────────────
                PositionedDirectional(
                  end: isMobile ? sw * 0.02 : sw * 0.04,
                  bottom: 0,
                  height: heroHeight * 0.88,
                  width: isMobile ? sw * 0.55 : sw * 0.44,
                  child: Transform.translate(
                    offset: Offset(0, -fgOffset * 0.3),
                    child: SlideTransition(
                      position: _fgSlide,
                      child: FadeTransition(
                        opacity: _fgFade,
                        child: Image.asset(
                          current.personImage,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Layer 6: Depth gradient ─────────────────────
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  top: 0,
                  bottom: 0,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.centerEnd,
                        end: AlignmentDirectional.centerStart,
                        colors: [Colors.transparent, Color(0xB30A0E1A)],
                        stops: [0.35, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── Layer 7: Bottom fade ────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: heroHeight * 0.14,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFF0A0E1A), Colors.transparent],
                      ),
                    ),
                  ),
                ),

                // ── Layer 8: Hero text ──────────────────────────
                PositionedDirectional(
                  start: isMobile ? sw * 0.06 : sw * 0.07,
                  bottom: isMobile
                      ? heroHeight * 0.14 - textOffset
                      : heroHeight * 0.16 - textOffset,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? sw * 0.72 : sw * 0.48,
                    ),
                    child: SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textFade,
                        child: ScaleTransition(
                          scale: _textScale,
                          alignment: Alignment.bottomLeft,
                          child: HomeHeroTextContent(
                            isMobile: isMobile,
                            data: current,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Layer 9: Stats bar (desktop) ────────────────
                if (!isMobile)
                  Positioned(
                    bottom: 28,
                    left: sw * 0.07,
                    child: SlideTransition(
                      position: _statsSlide,
                      child: FadeTransition(
                        opacity: _statsFade,
                        child: HomeStatsBar(data: current),
                      ),
                    ),
                  ),

                // ── Layer 10: Dot indicators ────────────────────
                PositionedDirectional(
                  bottom: isMobile ? 18 : 26,
                  start: isMobile ? 32 : sw * 0.07,
                  child: _DotIndicators(
                    count: banners.length,
                    current: _current,
                    accentColor: current.accentColor,
                    onTap: (i) => _goTo(ctx, i),
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Dot Indicators
// ─────────────────────────────────────────────

class _DotIndicators extends StatelessWidget {
  const _DotIndicators({
    required this.count,
    required this.current,
    required this.accentColor,
    required this.onTap,
    required this.isMobile,
  });

  final int count;
  final int current;
  final Color accentColor;
  final ValueChanged<int> onTap;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: isMobile
          ? MainAxisAlignment.center
          : MainAxisAlignment.end,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? accentColor : Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(3),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : [],
            ),
          ),
        );
      }),
    );
  }
}
