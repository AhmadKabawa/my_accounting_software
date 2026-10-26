import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/constants/image_constants.dart';
import 'package:accounting_software/app/features/home/domain/entity/banner_entity.dart';
import 'package:accounting_software/app/features/home/domain/entity/category_entity.dart';

// ─────────────────────────────────────────────
//  Color constants (shared across data & widgets)
// ─────────────────────────────────────────────

const kAccentCyan = Color.fromARGB(255, 0, 213, 255);
const kAccentTeal = Color(0xFF64FFDA);
const kAccentBlue = Color(0xFF74B9FF);
const kAccentRed = Color(0xFFFF6B6B);
const kAccentYellow = Color(0xFFFFD93D);
const kDark = Color(0xFF0A0E1A);
const kDarkSurface = Color(0xFF0D1832);

// ─────────────────────────────────────────────
//  Parallax speed constants
// ─────────────────────────────────────────────
const double kParallaxBgSpeed = 0.3;
const double kParallaxFgSpeed = 0.55;
const double kParallaxTextSpeed = 0.12;

// ─────────────────────────────────────────────
//  Banners
// ─────────────────────────────────────────────
final List<HeroBannerEntity> homeBanners = <HeroBannerEntity>[
  HeroBannerEntity(
    bgImage: AppPathImages.banner.path,
    personImage: AppPathImages.banner2.path,
    badge: 'NEW COLLECTION 2025',
    titleLine1: 'WELCOME\nTO ',
    titleAccent: 'VAUDE',
    subtitle: 'Gear crafted for every adventure\n— from summit to trail.',
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

// // ─────────────────────────────────────────────
// //  Categories
// // ─────────────────────────────────────────────
// final homeCategories = <CategoryEntity>[
//   const CategoryEntity(
//     label: 'Hiking',id: "2",
//     icon: Icons.terrain_rounded,
//     accentColor: kAccentCyan,
//    productCount: 2
//   ),
//   const CategoryEntity(
//     label: 'Cycling',
//     icon: Icons.directions_bike_rounded,
//     color: kAccentTeal,
//     imageUrl: null,
//   ),
//   const CategoryEntity(
//     label: 'Running',
//     icon: Icons.directions_run_rounded,
//     color: kAccentRed,
//     imageUrl: null,
//   ),
//   const CategoryEntity(
//     label: 'Climbing',
//     icon: Icons.social_distance_rounded,
//     color: kAccentYellow,
//     imageUrl: null,
//   ),
//   const CategoryEntity(
//     label: 'Snow',
//     icon: Icons.ac_unit_rounded,
//     color: kAccentBlue,
//     imageUrl: null,
//   ),
//   const CategoryEntity(
//     label: 'Swimming',
//     icon: Icons.pool_rounded,
//     color: Color(0xFF48DBFB),
//     imageUrl: null,
//   ),
// ];

// // ─────────────────────────────────────────────
// //  Sport cards (horizontal list below categories)
// // ─────────────────────────────────────────────
// final homeSportCards = <CategoryEntity>[
//   CategoryEntity(
//     label: 'Yoga',
//     icon: Icons.self_improvement_rounded,
//     color: kAccentTeal,
//     imageUrl: AppPathImages.yoga2.path,
//   ),
//   CategoryEntity(
//     label: 'Hiking',
//     icon: Icons.terrain_rounded,
//     color: kAccentCyan,
//     imageUrl: AppPathImages.sports1.path,
//   ),
//   CategoryEntity(
//     label: 'Cycling',
//     icon: Icons.directions_bike_rounded,
//     color: kAccentTeal,
//     imageUrl: AppPathImages.sports2.path,
//   ),
//   CategoryEntity(
//     label: 'Running',
//     icon: Icons.directions_run_rounded,
//     color: kAccentRed,
//     imageUrl: AppPathImages.sports1.path,
//   ),
//   CategoryEntity(
//     label: 'Climbing',
//     icon: Icons.social_distance_rounded,
//     color: kAccentYellow,
//     imageUrl: AppPathImages.sports2.path,
//   ),
// ];
