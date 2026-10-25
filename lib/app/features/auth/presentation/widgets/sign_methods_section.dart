import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:accounting_software/app/core/foundation/constants/image_constants.dart';
import 'package:accounting_software/app/core/presentation/theme/logic/theme_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignMethodsSection extends StatelessWidget {
  const SignMethodsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconSignWith(images: AppPathImages.facebook, onPressed: () {}),
        IconSignWith(images: AppPathImages.apple, onPressed: () {}),
        IconSignWith(images: AppPathImages.google, onPressed: () {}),
      ],
    );
  }
}

class IconSignWith extends StatelessWidget {
  const IconSignWith({
    super.key,
    required this.images,
    required this.onPressed,
  });
  final void Function()? onPressed;
  final String images;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      height: 60,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.colors.onSurface.withAlpha(50),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: SvgPicture.asset(
          images,
          height: 32,
          width: 32,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onBackground,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

//
