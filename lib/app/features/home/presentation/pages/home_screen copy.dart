import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:accounting_software/app/core/foundation/constants/image_constants.dart';
import 'package:accounting_software/app/core/presentation/responsive/extension/ui_extension.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_image/app_image.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_text/app_text.dart';

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
const _kCyan = Color.fromARGB(255, 0, 255, 47);
const _kDark = Color(0xFF0A0E1A);
const _kDarkSurface = Color(0xFF0D1832);

// ─────────────────────────────────────────────
//  Static Data
// ─────────────────────────────────────────────
class _CategoryData {
  const _CategoryData({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;
}

const _categories = [
  _CategoryData(label: 'Hiking', icon: Icons.terrain_rounded, color: _kCyan),
  _CategoryData(
    label: 'Cycling',
    icon: Icons.directions_bike_rounded,
    color: Color(0xFF64FFDA),
  ),
  _CategoryData(label: 'Hiking', icon: Icons.terrain_rounded, color: _kCyan),
  _CategoryData(
    label: 'Cycling',
    icon: Icons.directions_bike_rounded,
    color: Color(0xFF64FFDA),
  ),
  _CategoryData(label: 'Hiking', icon: Icons.terrain_rounded, color: _kCyan),
  _CategoryData(
    label: 'Cycling',
    icon: Icons.directions_bike_rounded,
    color: Color(0xFF64FFDA),
  ),
  _CategoryData(label: 'Hiking', icon: Icons.terrain_rounded, color: _kCyan),
  _CategoryData(
    label: 'Cycling',
    icon: Icons.directions_bike_rounded,
    color: Color(0xFF64FFDA),
  ),
  _CategoryData(
    label: 'Running',
    icon: Icons.directions_run_rounded,
    color: Color(0xFFFF6B6B),
  ),
  _CategoryData(
    label: 'Climbing',
    icon: Icons.social_distance_rounded,
    color: Color(0xFFFFD93D),
  ),
  _CategoryData(
    label: 'Snow',
    icon: Icons.ac_unit_rounded,
    color: Color(0xFF74B9FF),
  ),
];

class _FeaturedItem {
  const _FeaturedItem({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.icon,
    required this.accentColor,
  });
  final String name;
  final String subtitle;
  final String price;
  final IconData icon;
  final Color accentColor;
}

final _featuredItems = [
  const _FeaturedItem(
    name: 'Vaude Tremalzo',
    subtitle: "Men's Trail Jacket · Lightweight",
    price: '\$189.00',
    icon: Icons.shield_outlined,
    accentColor: _kCyan,
  ),
  const _FeaturedItem(
    name: 'Vaude Moab AM',
    subtitle: 'MTB Shorts · Enduro Cut',
    price: '\$115.00',
    icon: Icons.directions_bike_rounded,
    accentColor: Color(0xFF64FFDA),
  ),
  const _FeaturedItem(
    name: 'Vaude Shuksan',
    subtitle: 'Winter Gloves · -15°C',
    price: '\$74.00',
    icon: Icons.back_hand_outlined,
    accentColor: Color(0xFF74B9FF),
  ),
];

// ─────────────────────────────────────────────
//  Banner Data Model
// ─────────────────────────────────────────────
class HeroBannerData {
  final String bgImage;
  final String personImage;
  final String badge;
  final String titleLine1;
  final String titleLine2;
  final String titleAccent;
  final String subtitle;
  final String statNumber1;
  final String statLabel1;
  final String statNumber2;
  final String statLabel2;
  final String statNumber3;
  final String statLabel3;
  final Color accentColor;

  const HeroBannerData({
    required this.bgImage,
    required this.personImage,
    required this.badge,
    required this.titleLine1,
    required this.titleLine2,
    required this.titleAccent,
    required this.subtitle,
    required this.statNumber1,
    required this.statLabel1,
    required this.statNumber2,
    required this.statLabel2,
    required this.statNumber3,
    required this.statLabel3,
    this.accentColor = _kCyan,
  });
}

final banners = [
  HeroBannerData(
    bgImage: AppPathImages.banner.path,
    personImage: AppPathImages.banner2.path,
    badge: 'NEW COLLECTION 2025',
    titleLine1: 'WELCOME\nTO ',
    titleLine2: '',
    titleAccent: 'VAUDE',
    subtitle: 'Gear crafted for every adventure\n— from summit to trail.',
    statNumber1: '500+',
    statLabel1: 'PRODUCTS',
    statNumber2: '40+',
    statLabel2: 'COUNTRIES',
    statNumber3: '1974',
    statLabel3: 'FOUNDED',
    accentColor: const Color.fromARGB(255, 0, 213, 255),
  ),
  HeroBannerData(
    bgImage: AppPathImages.bannerB.path,
    personImage: AppPathImages.sports1.path,
    badge: 'SUMMER DROP 2025',
    titleLine1: 'RIDE\nTHE ',
    titleLine2: '',
    titleAccent: 'TRAIL',
    subtitle: 'MTB & cycling gear built\nfor the toughest terrain.',
    statNumber1: '120+',
    statLabel1: 'BIKE GEAR',
    statNumber2: '98%',
    statLabel2: 'RATED',
    statNumber3: 'ECO',
    statLabel3: 'CERTIFIED',
    accentColor: Color(0xFF64FFDA),
  ),
  HeroBannerData(
    bgImage: AppPathImages.bannerB.path,
    personImage: AppPathImages.sports2.path,
    badge: 'WINTER READY',
    titleLine1: 'CONQUER\nTHE ',
    titleLine2: '',
    titleAccent: 'COLD',
    subtitle: 'Premium winter gear\nbuilt to perform at -20°C.',
    statNumber1: '-20°C',
    statLabel1: 'RATED',
    statNumber2: '3-IN-1',
    statLabel2: 'LAYERS',
    statNumber3: '100%',
    statLabel3: 'WINDPROOF',
    accentColor: Color(0xFF74B9FF),
  ),
];

// ─────────────────────────────────────────────
//  HomeScreen
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _appBarProgress = 0.0;
  double _scrollOffset = 0.0;

  static const double _appBarFadeDistance = 160.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
      backgroundColor: context.ui.theme.colors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _GlassAppBar(progress: _appBarProgress),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _HeroBanner(scrollOffset: _scrollOffset)),
          SliverToBoxAdapter(
            child: _ContentSection(scrollOffset: _scrollOffset),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Hero Banner — Orchestrated Slider
// ─────────────────────────────────────────────
class _HeroBanner extends StatefulWidget {
  const _HeroBanner({required this.scrollOffset});
  final double scrollOffset;

  // Parallax speeds — kept as-is per request
  static const double _bgSpeed = 0.3;
  static const double _fgSpeed = 0.55;
  static const double _textSpeed = 0.12;

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner>
    with TickerProviderStateMixin {
  int _current = 0;
  int _previous = 0;
  Timer? _timer;

  // Separate controllers for each animated layer
  late AnimationController _bgCtrl; // background crossfade
  late AnimationController _fgCtrl; // foreground person slide+fade
  late AnimationController _textCtrl; // text content
  late AnimationController _statsCtrl; // stats bar
  late AnimationController _dotCtrl; // dot indicator pulse

  // Derived animations
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

    // Background: slow crossfade
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);

    // Foreground person: slide in from bottom-right + fade
    _fgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fgSlide = Tween<Offset>(
      begin: const Offset(0.08, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fgCtrl, curve: Curves.easeOutCubic));
    _fgFade = CurvedAnimation(parent: _fgCtrl, curve: Curves.easeOut);

    // Text: slide up + fade + subtle scale
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

    // Stats bar: slide up with delay
    _statsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _statsSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOutBack));
    _statsFade = CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut);

    // Dot indicator
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Kick off the initial entrance animations
    _playEntrance();

    // Auto-play timer
    _timer = Timer.periodic(_autoPlayDuration, (_) => _next());
  }

  void _playEntrance() {
    _bgCtrl.forward(from: 0);
    _fgCtrl.forward(from: 0);
    _textCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _statsCtrl.forward(from: 0);
    });
  }

  Future<void> _transitionTo(int index) async {
    if (index == _current) return;

    // 1. Fade out text & stats quickly
    await Future.wait([_textCtrl.reverse(), _statsCtrl.reverse()]);

    // 2. Swap fg person (slide out old, prepare new)
    await _fgCtrl.reverse();

    setState(() {
      _previous = _current;
      _current = index;
    });

    // 3. Crossfade bg + slide in new person + re-enter text
    _bgCtrl.forward(from: 0);
    _fgCtrl.forward(from: 0);
    _textCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _statsCtrl.forward(from: 0);
    });
    _dotCtrl.forward(from: 0).then((_) => _dotCtrl.reverse());
  }

  void _next() => _transitionTo((_current + 1) % banners.length);
  void _goTo(int i) {
    _timer?.cancel();
    _transitionTo(i).then((_) {
      _timer = Timer.periodic(_autoPlayDuration, (_) => _next());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bgCtrl.dispose();
    _fgCtrl.dispose();
    _textCtrl.dispose();
    _statsCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = context.ui.screen.width();
    final sh = context.ui.screen.height();
    final isMobile = context.ui.screen.isMobile;

    final ratio = AppAspectRatio.bannerImage.of(context);
    final calculated = sw / ratio;
    final heroHeight = calculated.clamp(380.0, sh * 0.8);

    final bgOffset = widget.scrollOffset * _HeroBanner._bgSpeed;
    final fgOffset = widget.scrollOffset * _HeroBanner._fgSpeed;
    final textOffset = widget.scrollOffset * _HeroBanner._textSpeed;
    final heroOpacity = (1.0 - widget.scrollOffset / (heroHeight * 0.65)).clamp(
      0.0,
      1.0,
    );

    final current = banners[_current];
    final previous = banners[_previous];

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: sh * 0.8, minHeight: 380.0),
      child: SizedBox(
        height: heroHeight,
        child: Opacity(
          opacity: heroOpacity,
          child: ClipRect(
            child: Stack(
              children: [
                // ── Layer 1: Previous background (always visible beneath) ──
                PositionedDirectional(
                  top: -bgOffset,
                  start: 0,
                  end: 0,
                  height: heroHeight + 80,
                  child: context.ui.dir.transformFlip(
                    isRtlChild: AppPathImages.banner.isRtl,
                    child: AppImage.asset(previous.bgImage, fit: BoxFit.cover),
                  ),
                ),

                // ── Layer 2: New background crossfades in ──
                PositionedDirectional(
                  top: -bgOffset,
                  start: 0,
                  end: 0,
                  height: heroHeight + 80,
                  child: FadeTransition(
                    opacity: _bgFade,
                    child: context.ui.dir.transformFlip(
                      isRtlChild: AppPathImages.banner.isRtl,
                      child: AppImage.asset(current.bgImage, fit: BoxFit.cover),
                    ),
                  ),
                ),

                // ── Layer 3: Grid texture ──
                Positioned.fill(child: const _GridOverlay()),

                // ── Layer 4: Radial glows (accent color animated) ──
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
                          child: _RadialGlow(
                            radius: 320,
                            color: color.withOpacity(0.08),
                          ),
                        ),
                        Positioned(
                          right: sw * 0.35,
                          top: heroHeight * 0.15,
                          child: _RadialGlow(
                            radius: 200,
                            color: color.withOpacity(0.05),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // ── Layer 5: Foreground person (slide + fade) ──
                PositionedDirectional(
                  end: context.ui.grid.value<double>(
                    mobile: sw * 0.02,
                    tablet: sw * 0.04,
                  ),
                  bottom: 0,
                  height: heroHeight * 0.88,
                  width: context.ui.grid.value<double>(
                    mobile: sw * 0.55,
                    tablet: sw * 0.44,
                  ),
                  child: Transform.translate(
                    offset: Offset(0, -fgOffset * 0.3),
                    child: SlideTransition(
                      position: _fgSlide,
                      child: FadeTransition(
                        opacity: _fgFade,
                        child: context.ui.dir.transformFlip(
                          isRtlChild: AppPathImages.banner.isRtl,
                          child: Image.asset(
                            current.personImage,
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Layer 6: Depth gradient (L→R) ──
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: AlignmentDirectional.centerEnd,
                        end: AlignmentDirectional.centerStart,
                        colors: [
                          Colors.transparent,
                          context.ui.theme.colors.shadow.withOpacity(
                            context.ui.theme.value(dark: 0.6, light: 0.4),
                          ),
                        ],
                        stops: const [0.35, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── Layer 7: Bottom fade ──
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: heroHeight * 0.14,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          context.ui.theme.colors.surface.withOpacity(
                            context.ui.theme.value(dark: 1, light: 0.9),
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Layer 8: Desktop category chips ──
                if (!isMobile)
                  PositionedDirectional(
                    end: 24,
                    top: kToolbarHeight + 16,
                    child: _VerticalCategoryChips(),
                  ),

                // ── Layer 9: Hero text (slide up + fade + scale) ──
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
                          child: _HeroTextContent(
                            isMobile: isMobile,
                            data: current,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Layer 10: Stats bar (slide up + fade) ──
                if (!isMobile)
                  Positioned(
                    bottom: 28,
                    left: sw * 0.07,
                    child: SlideTransition(
                      position: _statsSlide,
                      child: FadeTransition(
                        opacity: _statsFade,
                        child: _StatsBar(data: current),
                      ),
                    ),
                  ),

                // ── Layer 11: Dot indicators ──
                PositionedDirectional(
                  bottom: isMobile ? 18 : 26,
                  start: isMobile ? 32 : sw * 0.07,
                  // left: isMobile ? 0 : null,
                  // top: isMobile ? 0 : null,
                  child: _DotIndicators(
                    count: banners.length,
                    current: _current,
                    accentColor: current.accentColor,
                    onTap: _goTo,
                    isMobile: isMobile,
                  ),
                ),

                // ── Layer 12: Scroll indicator (mobile, on left side) ──
                // if (isMobile)
                //   Positioned(
                //     bottom: 18,
                //     left: 0,
                //     right: sw * 0.42,
                //     child: const _ScrollIndicator(),
                //   ),
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

// ─────────────────────────────────────────────
//  Grid Overlay
// ─────────────────────────────────────────────
class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kCyan.withOpacity(0.035)
      ..strokeWidth = 0.5;
    const step = 42.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────
//  Radial Glow
// ─────────────────────────────────────────────
class _RadialGlow extends StatelessWidget {
  const _RadialGlow({required this.radius, required this.color});
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Hero Text Content — now receives slide data
// ─────────────────────────────────────────────
class _HeroTextContent extends StatelessWidget {
  const _HeroTextContent({required this.isMobile, required this.data});
  final bool isMobile;
  final HeroBannerData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge
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

        // Heading
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

        // Subtitle
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

        // Buttons
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _CyanButton(
              label: 'EXPLORE NOW',
              icon: Icons.arrow_forward_rounded,
              accentColor: data.accentColor,
              onPressed: () {},
            ),
            _GhostButton(label: 'VIEW CATALOG', onPressed: () {}),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Cyan CTA Button — now takes accentColor
// ─────────────────────────────────────────────
class _CyanButton extends StatefulWidget {
  const _CyanButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.accentColor = _kCyan,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color accentColor;

  @override
  State<_CyanButton> createState() => _CyanButtonState();
}

class _CyanButtonState extends State<_CyanButton> {
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
            color: _hovered
                ? widget.accentColor.withOpacity(0.22)
                : widget.accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor
                  : widget.accentColor.withOpacity(0.55),
              width: 1.0,
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

// ─────────────────────────────────────────────
//  Ghost Button — unchanged
// ─────────────────────────────────────────────
class _GhostButton extends StatefulWidget {
  const _GhostButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> {
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

// ─────────────────────────────────────────────
//  Vertical Category Chips (Desktop) — unchanged
// ─────────────────────────────────────────────
class _VerticalCategoryChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(20 * (1 - v), 0),
          child: child,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _categories
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DesktopCatChip(data: c),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DesktopCatChip extends StatefulWidget {
  const _DesktopCatChip({required this.data});
  final _CategoryData data;

  @override
  State<_DesktopCatChip> createState() => _DesktopCatChipState();
}

class _DesktopCatChipState extends State<_DesktopCatChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered
                  ? widget.data.color.withOpacity(0.35)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.data.icon,
                color: widget.data.color.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              AppText.raw(
                widget.data.label.toUpperCase(),
                type: AppTextType.labelSmall,
                style: TextStyle(
                  color: Colors.white.withOpacity(_hovered ? 0.75 : 0.45),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
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
//  Stats Bar — now receives data
// ─────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.data});
  final HeroBannerData data;

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

// ─────────────────────────────────────────────
//  Scroll Indicator — unchanged
// ─────────────────────────────────────────────
class _ScrollIndicator extends StatefulWidget {
  const _ScrollIndicator();

  @override
  State<_ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<_ScrollIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 22,
            ),
            const SizedBox(height: 2),
            AppText.raw(
              'SCROLL',
              type: AppTextType.labelSmall,
              style: TextStyle(
                color: Colors.white.withOpacity(0.2),
                letterSpacing: 3,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Glass AppBar — unchanged
// ─────────────────────────────────────────────
class _GlassAppBar extends StatelessWidget {
  const _GlassAppBar({required this.progress});
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
                        color: context.ui.theme.colors.surface.withOpacity(
                          0.82 * value,
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: context.ui.theme.colors.onSurface
                                .withOpacity(0.15 * value),
                            width: 2,
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
              title: AppText.raw(
                'VAUDE',
                type: AppTextType.displaySmall,
                style: TextStyle(
                  color: context.ui.theme.colors.onSurface.withOpacity(value),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
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

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({required this.icon, this.onPressed});
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: context.ui.theme.colors.onSurface.withOpacity(0.85),
      ),
      onPressed: onPressed ?? () {},
      splashRadius: 20,
    );
  }
}

// ─────────────────────────────────────────────
//  Content Section — unchanged
// ─────────────────────────────────────────────
class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.scrollOffset});
  final double scrollOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.ui.theme.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          _SectionHeader(
            label: 'SHOP BY CATEGORY',
            scrollOffset: scrollOffset,
            revealAt: 400,
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                shrinkWrap: true,

                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _CategoryCard(data: _categories[i]),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Container(
            height: 300,
            // color: Colors.deepPurpleAccent,
            child: ListView.separated(
              shrinkWrap: true,

              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) =>
                  Align(child: _SportCard(data: _categories[i])),
            ),
          ),
          const SizedBox(height: 44),
          _SectionHeader(
            label: 'FEATURED GEAR',
            scrollOffset: scrollOffset,
            revealAt: 800,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: _featuredItems
                  .asMap()
                  .entries
                  .map(
                    (e) => Padding(
                      padding: EdgeInsets.only(
                        bottom: e.key < _featuredItems.length - 1 ? 14 : 0,
                      ),
                      child: _FeaturedCard(item: e.value),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.scrollOffset,
    required this.revealAt,
  });
  final String label;
  final double scrollOffset;
  final double revealAt;

  @override
  Widget build(BuildContext context) {
    final revealed = scrollOffset >= revealAt - 200;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                color: _kCyan,
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
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.data});
  final _CategoryData data;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.ui.theme.colors;
    return MouseRegion(
      onEnter: (_) => setState(() => _pressed = true),
      onExit: (_) => setState(() => _pressed = false),

      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          padding: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: Offset(2, 2),
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
              ),
            ],
            border: Border.all(
              color: _pressed ? colors.primary : colors.surfaceContainerHigh,
            ),
            borderRadius: BorderRadius.circular(34),
            color: colors.surfaceContainerHigh,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: context.ui.padding.all(AppSpacing.sm),

                decoration: BoxDecoration(
                  color: _pressed ? colors.primary : colors.surface,

                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.data.icon,
                  color: _pressed ? colors.onPrimary : colors.primary,
                  size: 24,
                ),
              ),

              // context.ui.spacing.gap(AppSpacing.sm, axis: Axis.horizontal),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AppText.raw(
                  widget.data.label,
                  type: AppTextType.labelSmall,
                  style: TextStyle(
                    color: context.ui.theme.colors.onSurface,
                    fontWeight: FontWeight.w600,
                    // letterSpacing: 0.5,
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

class _SportCard extends StatefulWidget {
  const _SportCard({required this.data});
  final _CategoryData data;

  @override
  State<_SportCard> createState() => _SportCardState();
}

class _SportCardState extends State<_SportCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.ui.theme.colors;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 120,
        height: 200,
        transform: Matrix4.identity()
          ..scale(_pressed ? 0.96 : 1.0), // تأثير الضغط
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              offset: const Offset(2, 2),
              color: colors.shadow,
              blurRadius: 8,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // الصورة الأصلية
            Image.network(
              AppPathImages.yoga2.path, // استخدام الرابط من البيانات
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: colors.primary,
                  child: const Icon(Icons.error),
                );
              },
            ),

            // التدرج الغامق لتحسين النص
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

                      Colors.black.withOpacity(0.99),
                    ],
                    // stops: const [0.0, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // محتوى البطاقة (نص الرياضة)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'yoga',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // أيقونة أو نص علوي
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.white),
                      Text("16"),
                      Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(Icons.arrow_right),
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

class GradientBlurImage extends StatelessWidget {
  final String imageUrl;

  const GradientBlurImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Positioned.fill(child: CustomPaint(painter: GradientBlurPainter())),
        ],
      ),
    );
  }
}

class GradientBlurPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // تدرج من أسفل (أبيض معتم) إلى أعلى (شفاف)
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.transparent,
        Colors.white.withOpacity(0.5),
        Colors.white,
      ],
      stops: const [0.0, 0.5, 0.8, 1.0],
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// مع تطبيق BackdropFilter بشكل صحيح:
class FullGradientBlur extends StatelessWidget {
  final String imageUrl;

  const FullGradientBlur({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(imageUrl, fit: BoxFit.cover),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.white,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  const _FeaturedCard({required this.item});
  final _FeaturedItem item;

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 112,
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withOpacity(0.07)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? widget.item.accentColor.withOpacity(0.3)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: widget.item.accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: widget.item.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.item.icon,
                  color: widget.item.accentColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText.raw(
                      widget.item.name,
                      type: AppTextType.titleMedium,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppText.raw(
                      widget.item.subtitle,
                      type: AppTextType.bodySmall,
                      style: TextStyle(color: Colors.white.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 8),
                    AppText.raw(
                      widget.item.price,
                      type: AppTextType.titleSmall,
                      style: TextStyle(
                        color: widget.item.accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HexagonShape extends StatelessWidget {
  const HexagonShape({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipPath(
        clipper: HexagonClipper(),
        child: Container(
          width: 100,
          height: 100,
          color: Colors.transparent,
          child: CustomPaint(painter: BorderPainter()),
        ),
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double cut = 20;

    Path path = Path();

    path.moveTo(cut, 0);

    path.lineTo(size.width - cut, 0);

    path.lineTo(size.width, size.height / 2);

    path.lineTo(size.width - cut, size.height);

    path.lineTo(cut, size.height);

    path.lineTo(0, size.height / 2);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    double cut = 20;

    path.moveTo(cut, 0);

    path.lineTo(size.width - cut, 0);

    path.lineTo(size.width, size.height / 2);

    path.lineTo(size.width - cut, size.height);

    path.lineTo(cut, size.height);

    path.lineTo(0, size.height / 2);

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
