/// Permission codes currently defined by public.permissions in the ERP database.
/// Unknown future codes are ignored until the application explicitly supports them.
abstract final class KnownPermissionCodes {
  static const values = <String>{
    'accounting.manage', 'accounting.post', 'accounting.view', 'audit.view',
    'balance.adjust', 'catalog.manage', 'costs.manage', 'costs.view',
    'discount.exceptional', 'finance.expenses', 'finance.manage',
    'finance.payments', 'finance.view', 'fx.rate.manage', 'fx.rate.manual',
    'hr.manage', 'hr.view', 'inventory.adjust', 'inventory.transfer',
    'inventory.transfer.approve', 'inventory.view',
    'inventory.view_other_branches', 'masterdata.manage', 'org.manage',
    'owner.transactions', 'parties.manage', 'parties.quick_add',
    'parties.view', 'payment.cancel', 'pos.manage', 'pos.session',
    'pricing.manage', 'purchasing.create', 'purchasing.post',
    'purchasing.return', 'purchasing.view', 'reconcile.cash', 'reports.view',
    'sales.create', 'sales.discount', 'sales.post', 'sales.return',
    'sales.view', 'settings.manage', 'users.manage',
    'warehouse.central.access',
  };
}
