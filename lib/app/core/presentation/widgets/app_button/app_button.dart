// // ─────────────────────────────────────────────────────────────────
// // advanced_patterns.dart
// // أنماط متقدمة وأمثلة عملية
// // ─────────────────────────────────────────────────────────────────

// import 'package:flutter/material.dart';
// import 'adaptive_responsive_helper.dart';
// import 'app_text.dart';
// import 'app_responsive_configs.dart';

// // ═══════════════════════════════════════════════════════════════
// // 1️⃣ CUSTOM BUTTON WIDGET
// // ═══════════════════════════════════════════════════════════════

// enum AppButtonSize {
//   small,
//   medium,
//   large,
// }

// enum AppButtonStyle {
//   primary,
//   secondary,
//   outline,
//   text,
// }

// class AppButton extends StatefulWidget {
//   final String label;
//   final VoidCallback? onPressed;
//   final AppButtonSize size;
//   final AppButtonStyle style;
//   final IconData? icon;
//   final bool isLoading;
//   final bool isEnabled;
//   final double? width;

//   const AppButton(
//     this.label, {
//     Key? key,
//     this.onPressed,
//     this.size = AppButtonSize.medium,
//     this.style = AppButtonStyle.primary,
//     this.icon,
//     this.isLoading = false,
//     this.isEnabled = true,
//     this.width,
//   }) : super(key: key);

//   @override
//   State<AppButton> createState() => _AppButtonState();
// }

// class _AppButtonState extends State<AppButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final padding = _getPadding(context);
//     final radius = _getRadius(context);
//     final fontSize = _getFontSize(context);

//     return GestureDetector(
//       onTapDown: (_) => _controller.forward(),
//       onTapUp: (_) => _controller.reverse(),
//       onTapCancel: () => _controller.reverse(),
//       onTap: widget.isEnabled && !widget.isLoading
//           ? widget.onPressed
//           : null,
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           final scale = 1.0 - (_controller.value * 0.05);
//           return Transform.scale(scale: scale, child: child);
//         },
//         child: Container(
//           width: widget.width,
//           padding: padding,
//           decoration: BoxDecoration(
//             borderRadius: radius,
//             color: _getBackgroundColor(context),
//             border: _getBorder(context),
//             boxShadow: widget.style != AppButtonStyle.text
//                 ? [
//                     BoxShadow(
//                       color: _getPrimaryColor(context)
//                           .withOpacity(widget.isEnabled ? 0.3 : 0.1),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ]
//                 : null,
//           ),
//           child: widget.isLoading
//               ? SizedBox(
//                   height: fontSize,
//                   width: fontSize,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation(
//                       _getTextColor(context),
//                     ),
//                   ),
//                 )
//               : Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (widget.icon != null) ...[
//                       Icon(
//                         widget.icon,
//                         size: fontSize,
//                         color: _getTextColor(context),
//                       ),
//                       SizedBox(width: AppSpacing.sm),
//                     ],
//                     AppText(
//                       widget.label,
//                       type: AppTextType.labelMd,
//                       color: _getTextColor(context),
//                       weight: FontWeight.w600,
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }

//   EdgeInsets _getPadding(BuildContext context) {
//     return switch (widget.size) {
//       AppButtonSize.small => ARh.adaptiveResponsivePadding(
//         context,
//         mobile: AppPaddingConfig(h: AppSpacing.md, v: AppSpacing.xs),
//         tablet: AppPaddingConfig(h: AppSpacing.lg, v: AppSpacing.sm),
//       ),
//       AppButtonSize.medium => ARh.adaptiveResponsivePadding(
//         context,
//         mobile: AppPaddingConfig(h: AppSpacing.lg, v: AppSpacing.sm),
//         tablet: AppPaddingConfig(h: AppSpacing.xl, v: AppSpacing.md),
//       ),
//       AppButtonSize.large => ARh.adaptiveResponsivePadding(
//         context,
//         mobile: AppPaddingConfig(h: AppSpacing.xl, v: AppSpacing.md),
//         tablet: AppPaddingConfig(h: AppSpacing.xxl, v: AppSpacing.lg),
//       ),
//     };
//   }

//   BorderRadius _getRadius(BuildContext context) {
//     final radius = ARh.adaptiveResponsiveRadius(
//       context,
//       mobile: AppRadiusConfig(all: AppRadius.md),
//       tablet: AppRadiusConfig(all: AppRadius.lg),
//     );
//     return radius;
//   }

//   double _getFontSize(BuildContext context) {
//     return switch (widget.size) {
//       AppButtonSize.small => AppFontSize.sm,
//       AppButtonSize.medium => AppFontSize.md,
//       AppButtonSize.large => AppFontSize.lg,
//     };
//   }

//   Color _getPrimaryColor(BuildContext context) {
//     return Theme.of(context).colorScheme.primary;
//   }

//   Color? _getBackgroundColor(BuildContext context) {
//     if (!widget.isEnabled) {
//       return Theme.of(context).colorScheme.surfaceContainer;
//     }

//     return switch (widget.style) {
//       AppButtonStyle.primary => _getPrimaryColor(context),
//       AppButtonStyle.secondary =>
//         Theme.of(context).colorScheme.secondaryContainer,
//       AppButtonStyle.outline => Colors.transparent,
//       AppButtonStyle.text => Colors.transparent,
//     };
//   }

//   Border? _getBorder(BuildContext context) {
//     return switch (widget.style) {
//       AppButtonStyle.outline => Border.all(
//         color: _getPrimaryColor(context),
//         width: 2,
//       ),
//       AppButtonStyle.text => null,
//       _ => null,
//     };
//   }

//   Color _getTextColor(BuildContext context) {
//     if (!widget.isEnabled) {
//       return Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
//     }

//     return switch (widget.style) {
//       AppButtonStyle.primary => Theme.of(context).colorScheme.onPrimary,
//       AppButtonStyle.secondary =>
//         Theme.of(context).colorScheme.onSecondaryContainer,
//       AppButtonStyle.outline => _getPrimaryColor(context),
//       AppButtonStyle.text => _getPrimaryColor(context),
//     };
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // 2️⃣ CUSTOM INPUT FIELD WIDGET
// // ═══════════════════════════════════════════════════════════════

// class AppInputField extends StatefulWidget {
//   final String label;
//   final String? hintText;
//   final TextEditingController? controller;
//   final TextInputType keyboardType;
//   final bool obscureText;
//   final IconData? prefixIcon;
//   final IconData? suffixIcon;
//   final String? Function(String?)? validator;
//   final ValueChanged<String>? onChanged;
//   final int maxLines;
//   final int minLines;

//   const AppInputField({
//     Key? key,
//     required this.label,
//     this.hintText,
//     this.controller,
//     this.keyboardType = TextInputType.text,
//     this.obscureText = false,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.validator,
//     this.onChanged,
//     this.maxLines = 1,
//     this.minLines = 1,
//   }) : super(key: key);

//   @override
//   State<AppInputField> createState() => _AppInputFieldState();
// }

// class _AppInputFieldState extends State<AppInputField> {
//   late FocusNode _focusNode;
//   late bool _isFocused;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = FocusNode();
//     _isFocused = false;
//     _focusNode.addListener(_onFocusChange);
//   }

//   void _onFocusChange() {
//     setState(() => _isFocused = _focusNode.hasFocus);
//   }

//   @override
//   void dispose() {
//     _focusNode.removeListener(_onFocusChange);
//     _focusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final radius = ARh.adaptiveResponsiveRadius(
//       context,
//       mobile: AppRadiusConfig(all: AppRadius.md),
//       tablet: AppRadiusConfig(all: AppRadius.lg),
//     );

//     final padding = ARh.adaptiveResponsivePadding(
//       context,
//       mobile: AppPaddingConfig(h: AppSpacing.md, v: AppSpacing.sm),
//       tablet: AppPaddingConfig(h: AppSpacing.lg, v: AppSpacing.md),
//     );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AppText(
//           widget.label,
//           type: AppTextType.labelMd,
//         ),
//         SizedBox(height: AppSpacing.xs),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: radius,
//             border: Border.all(
//               color: _isFocused
//                   ? Theme.of(context).colorScheme.primary
//                   : Colors.grey.shade300,
//               width: _isFocused ? 2 : 1,
//             ),
//             color: Theme.of(context).colorScheme.surfaceContainer,
//           ),
//           child: TextField(
//             controller: widget.controller,
//             focusNode: _focusNode,
//             keyboardType: widget.keyboardType,
//             obscureText: widget.obscureText,
//             maxLines: widget.maxLines,
//             minLines: widget.minLines,
//             onChanged: widget.onChanged,
//             decoration: InputDecoration(
//               contentPadding: padding,
//               hintText: widget.hintText,
//               hintStyle: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
//               ),
//               prefixIcon: widget.prefixIcon != null
//                   ? Icon(
//                       widget.prefixIcon,
//                       color: _isFocused
//                           ? Theme.of(context).colorScheme.primary
//                           : Theme.of(context).colorScheme.onSurface,
//                     )
//                   : null,
//               suffixIcon: widget.suffixIcon != null
//                   ? Icon(
//                       widget.suffixIcon,
//                       color: _isFocused
//                           ? Theme.of(context).colorScheme.primary
//                           : Theme.of(context).colorScheme.onSurface,
//                     )
//                   : null,
//               border: InputBorder.none,
//               errorText: widget.validator?.call(widget.controller?.text),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // 3️⃣ CUSTOM CARD WIDGET WITH HEADER & FOOTER
// // ═══════════════════════════════════════════════════════════════

// class AppCardAdvanced extends StatelessWidget {
//   final String? title;
//   final Widget body;
//   final Widget? footer;
//   final VoidCallback? onTap;
//   final Color? backgroundColor;
//   final bool clickable;

//   const AppCardAdvanced({
//     Key? key,
//     this.title,
//     required this.body,
//     this.footer,
//     this.onTap,
//     this.backgroundColor,
//     this.clickable = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final radius = ARh.adaptiveResponsiveRadius(
//       context,
//       mobile: AppRadiusConfig(all: AppRadius.lg),
//       tablet: AppRadiusConfig(all: AppRadius.xl),
//     );

//     final padding = ARh.adaptiveResponsivePadding(
//       context,
//       mobile: AppPaddingConfig(all: AppSpacing.lg),
//       tablet: AppPaddingConfig(all: AppSpacing.xl),
//     );

//     return GestureDetector(
//       onTap: clickable ? onTap : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           borderRadius: radius,
//           color: backgroundColor ??
//               Theme.of(context).colorScheme.surfaceContainer,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (title != null) ...[
//               Padding(
//                 padding: padding,
//                 child: AppText(
//                   title!,
//                   type: AppTextType.headingMd,
//                 ),
//               ),
//               Divider(
//                 height: 1,
//                 color: Colors.grey.shade300,
//               ),
//             ],
//             Padding(
//               padding: padding,
//               child: body,
//             ),
//             if (footer != null) ...[
//               Divider(
//                 height: 1,
//                 color: Colors.grey.shade300,
//               ),
//               Padding(
//                 padding: padding,
//                 child: footer!,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // 4️⃣ RESPONSIVE GRID WIDGET
// // ═══════════════════════════════════════════════════════════════

// class AppResponsiveGrid extends StatelessWidget {
//   final List<Widget> children;
//   final int mobileColumns;
//   final int tabletColumns;
//   final int desktopColumns;
//   final double spacing;

//   const AppResponsiveGrid({
//     Key? key,
//     required this.children,
//     this.mobileColumns = 1,
//     this.tabletColumns = 2,
//     this.desktopColumns = 3,
//     this.spacing = 16.0,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     int columns;

//     if (width < 600) {
//       columns = mobileColumns;
//     } else if (width < 900) {
//       columns = tabletColumns;
//     } else {
//       columns = desktopColumns;
//     }

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: columns,
//         mainAxisSpacing: spacing,
//         crossAxisSpacing: spacing,
//       ),
//       itemCount: children.length,
//       itemBuilder: (context, index) => children[index],
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // 5️⃣ CUSTOM BADGE WIDGET
// // ═══════════════════════════════════════════════════════════════

// enum AppBadgeStyle {
//   primary,
//   success,
//   warning,
//   error,
//   info,
// }

// class AppBadge extends StatelessWidget {
//   final String label;
//   final AppBadgeStyle style;
//   final bool outline;

//   const AppBadge(
//     this.label, {
//     Key? key,
//     this.style = AppBadgeStyle.primary,
//     this.outline = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final color = _getColor(context);
//     final radius = BorderRadius.circular(AppRadius.xl);

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: radius,
//         color: outline ? Colors.transparent : color.withOpacity(0.2),
//         border: Border.all(
//           color: color,
//           width: outline ? 1.5 : 0,
//         ),
//       ),
//       padding: EdgeInsets.symmetric(
//         horizontal: AppSpacing.md,
//         vertical: AppSpacing.xs,
//       ),
//       child: AppText(
//         label,
//         type: AppTextType.labelSm,
//         color: color,
//         weight: FontWeight.w600,
//       ),
//     );
//   }

//   Color _getColor(BuildContext context) {
//     return switch (style) {
//       AppBadgeStyle.primary => Theme.of(context).colorScheme.primary,
//       AppBadgeStyle.success => Colors.green,
//       AppBadgeStyle.warning => Colors.orange,
//       AppBadgeStyle.error => Colors.red,
//       AppBadgeStyle.info => Colors.blue,
//     };
//   }
// }

// // ═══════════════════════════════════════════════════════════════
// // USAGE EXAMPLES
// // ═══════════════════════════════════════════════════════════════

// /*
// // AppButton
// AppButton(
//   'Click Me',
//   onPressed: () => print('Clicked'),
//   style: AppButtonStyle.primary,
//   size: AppButtonSize.large,
//   icon: Icons.send,
// )

// // AppInputField
// AppInputField(
//   label: 'Email',
//   hintText: 'Enter your email',
//   keyboardType: TextInputType.emailAddress,
//   prefixIcon: Icons.email,
// )

// // AppCardAdvanced
// AppCardAdvanced(
//   title: 'Card Title',
//   body: AppText('Card content here', type: AppTextType.bodyMd),
//   footer: Row(
//     children: [
//       AppBadge('New', style: AppBadgeStyle.success),
//       SizedBox(width: AppSpacing.md),
//       AppBadge('Featured', style: AppBadgeStyle.primary),
//     ],
//   ),
// )

// // AppResponsiveGrid
// AppResponsiveGrid(
//   children: List.generate(
//     6,
//     (i) => AppCardAdvanced(
//       body: Center(
//         child: AppText('Item ${i + 1}', type: AppTextType.bodyMd),
//       ),
//     ),
//   ),
// )
// */