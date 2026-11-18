import 'package:accounting_software/app/core/access/permission.dart';

/// Typed names for the permission codes returned by public.get_my_access().
/// Keep these identifiers aligned with public.permissions; do not invent
/// module.action combinations that are absent from the server catalog.
abstract final class Permissions {
  static const sales = SalesPermissions();
  static const purchases = PurchasingPermissions();
  static const purchasing = PurchasingPermissions();
  static const inventory = InventoryPermissions();
  static const customers = PartiesPermissions();
  static const suppliers = PartiesPermissions();
  static const parties = PartiesPermissions();
  static const payments = FinancePermissions();
  static const finance = FinancePermissions();
  static const journal = AccountingPermissions();
  static const accounting = AccountingPermissions();
  static const reports = ReportsPermissions();
  static const settings = SettingsPermissions();
  static const users = UsersPermissions();
  static const organization = OrganizationPermissions();
  static const catalog = CatalogPermissions();
  static const costs = CostsPermissions();
  static const discounts = DiscountPermissions();
  static const fxRates = FxRatePermissions();
  static const hr = HrPermissions();
  static const pos = PosPermissions();
  static const pricing = PricingPermissions();
  static const payment = PaymentPermissions();
  static const reconcile = ReconcilePermissions();
  static const audit = AuditPermissions();
  static const balance = BalancePermissions();
  static const owner = OwnerPermissions();
  static const masterData = MasterDataPermissions();
  static const warehouse = WarehousePermissions();
}

final class SalesPermissions {
  const SalesPermissions();
  Permission get view => const Permission('sales.view');
  Permission get create => const Permission('sales.create');
  Permission get discount => const Permission('sales.discount');
  Permission get post => const Permission('sales.post');
  Permission get returnDocument => const Permission('sales.return');
  Permission get all => Permission.module('sales');
}

final class PurchasingPermissions {
  const PurchasingPermissions();
  Permission get view => const Permission('purchasing.view');
  Permission get create => const Permission('purchasing.create');
  Permission get post => const Permission('purchasing.post');
  Permission get returnDocument => const Permission('purchasing.return');
  Permission get all => Permission.module('purchasing');
}

final class InventoryPermissions {
  const InventoryPermissions();
  Permission get view => const Permission('inventory.view');
  Permission get adjust => const Permission('inventory.adjust');
  Permission get transfer => const Permission('inventory.transfer');
  Permission get transferApprove =>
      const Permission('inventory.transfer.approve');
  Permission get viewOtherBranches =>
      const Permission('inventory.view_other_branches');
  Permission get all => Permission.module('inventory');
}

final class PartiesPermissions {
  const PartiesPermissions();
  Permission get view => const Permission('parties.view');
  Permission get manage => const Permission('parties.manage');
  Permission get quickAdd => const Permission('parties.quick_add');
  Permission get all => Permission.module('parties');
}

final class FinancePermissions {
  const FinancePermissions();
  Permission get view => const Permission('finance.view');
  Permission get manage => const Permission('finance.manage');
  Permission get payments => const Permission('finance.payments');
  Permission get expenses => const Permission('finance.expenses');
  Permission get all => Permission.module('finance');
}

final class AccountingPermissions {
  const AccountingPermissions();
  Permission get view => const Permission('accounting.view');
  Permission get manage => const Permission('accounting.manage');
  Permission get post => const Permission('accounting.post');
  Permission get all => Permission.module('accounting');
}

final class ReportsPermissions {
  const ReportsPermissions();
  Permission get view => const Permission('reports.view');
  Permission get all => Permission.module('reports');
}

final class SettingsPermissions {
  const SettingsPermissions();
  Permission get manage => const Permission('settings.manage');
  Permission get all => Permission.module('settings');
}

final class UsersPermissions {
  const UsersPermissions();
  Permission get manage => const Permission('users.manage');
  Permission get all => Permission.module('users');
}

final class OrganizationPermissions {
  const OrganizationPermissions();
  Permission get manage => const Permission('org.manage');
  Permission get all => Permission.module('org');
}

final class CatalogPermissions {
  const CatalogPermissions();
  Permission get manage => const Permission('catalog.manage');
  Permission get all => Permission.module('catalog');
}

final class CostsPermissions {
  const CostsPermissions();
  Permission get view => const Permission('costs.view');
  Permission get manage => const Permission('costs.manage');
  Permission get all => Permission.module('costs');
}

final class DiscountPermissions {
  const DiscountPermissions();
  Permission get exceptional => const Permission('discount.exceptional');
}

final class FxRatePermissions {
  const FxRatePermissions();
  Permission get manage => const Permission('fx.rate.manage');
  Permission get manual => const Permission('fx.rate.manual');
}

final class HrPermissions {
  const HrPermissions();
  Permission get view => const Permission('hr.view');
  Permission get manage => const Permission('hr.manage');
}

final class PosPermissions {
  const PosPermissions();
  Permission get manage => const Permission('pos.manage');
  Permission get session => const Permission('pos.session');
}

final class PricingPermissions {
  const PricingPermissions();
  Permission get manage => const Permission('pricing.manage');
}

final class PaymentPermissions {
  const PaymentPermissions();
  Permission get cancel => const Permission('payment.cancel');
}

final class ReconcilePermissions {
  const ReconcilePermissions();
  Permission get cash => const Permission('reconcile.cash');
}

final class AuditPermissions {
  const AuditPermissions();
  Permission get view => const Permission('audit.view');
}

final class BalancePermissions {
  const BalancePermissions();
  Permission get adjust => const Permission('balance.adjust');
}

final class OwnerPermissions {
  const OwnerPermissions();
  Permission get transactions => const Permission('owner.transactions');
}

final class MasterDataPermissions {
  const MasterDataPermissions();
  Permission get manage => const Permission('masterdata.manage');
}

final class WarehousePermissions {
  const WarehousePermissions();
  Permission get centralAccess => const Permission('warehouse.central.access');
}
