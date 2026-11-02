import 'package:flutter/material.dart';

import 'components/button_styles.dart';
import 'components/navbar_styles.dart';
// import 'components/card_styles.dart';

class AppStyles {
  final BuildContext context;

  const AppStyles(this.context);

  NavbarStyles get navbar => NavbarStyles(context);
  ButtonStyles get button => ButtonStyles(context);
  // CardStyles get card => CardStyles(context);
}
