import 'package:flutter/material.dart';

import 'components/navbar_styles.dart';
// import 'components/card_styles.dart';

class AppStyles {
  final BuildContext context;

  const AppStyles(this.context);

  NavbarStyles get navbar => NavbarStyles( context);
  // CardStyles get card => CardStyles(context);
}