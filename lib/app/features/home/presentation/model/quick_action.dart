import 'package:accounting_software/app/core/access/permission.dart';
import 'package:accounting_software/app/core/access/permissions.dart';
import 'package:accounting_software/app/core/localization/translations/app_key.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icon_data.dart';
import 'package:accounting_software/app/core/presentation/widgets/app_icon/app_icons.dart';
import 'package:accounting_software/app/features/home/presentation/localization/home_keys.dart';

/// The shortcuts on the home screen. The enum value is the action's identity
/// (what the cubit receives); the label is only what is shown for it.
enum QuickAction {
  newSale,
  newPurchase,
  receivePayment,
  customers,
  reports;

  AppKey get label => switch (this) {
    QuickAction.newSale => HomeKeys.newSale,
    QuickAction.newPurchase => HomeKeys.newPurchase,
    QuickAction.receivePayment => HomeKeys.receivePayment,
    QuickAction.customers => HomeKeys.customers,
    QuickAction.reports => HomeKeys.reports,
  };

  AppIconData get icon => switch (this) {
    QuickAction.newSale => AppIcons.sale,
    QuickAction.newPurchase => AppIcons.purchase,
    QuickAction.receivePayment => AppIcons.payment,
    QuickAction.customers => AppIcons.customers,
    QuickAction.reports => AppIcons.reports,
  };

  /// Who sees the action (visibility only; the server enforces it).
  Permission get permission => switch (this) {
    QuickAction.newSale => Permissions.sales.create,
    QuickAction.newPurchase => Permissions.purchases.create,
    QuickAction.receivePayment => Permissions.payments.create,
    QuickAction.customers => Permissions.customers.view,
    QuickAction.reports => Permissions.reports.view,
  };
}
