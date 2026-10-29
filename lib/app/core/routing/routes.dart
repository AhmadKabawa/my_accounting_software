class AppRoutes {
  // ─────────────────── البداية ───────────────────
  static const splash = RouteItem('/', 'splash');
  static const onboarding = RouteItem('/onboarding', 'onboarding');

  // ─────────────────── المصادقة ───────────────────
  static const login = RouteItem('/login', 'login');
  static const register = RouteItem('/register', 'register');
  // Password recovery: reached by people who cannot sign in, so public.
  static const forgotPassword = RouteItem('/forgot-password', 'forgotPassword');
  static const verifyResetCode = RouteItem(
    '/forgot-password/verify',
    'verifyResetCode',
  );
  static const resetPassword = RouteItem(
    '/forgot-password/reset',
    'resetPassword',
  );

  // ─────────────────── الصفحات الرئيسية ───────────────────
  static const mainPages = RouteItem('/mainPages', 'mainPages');
  static const home = RouteItem('/home', 'home');
  static const profile = RouteItem('/profile', 'profile');
  static const chat = RouteItem('/chat', 'chat');
  static const favorites = RouteItem('/favorites', 'favorites');

  // ─────────────────── المنتجات ───────────────────
  static const products = RouteItem('/products', 'products');
  static const productDetails = RouteItem('/products/:id', 'productDetails');
  static const addProduct = RouteItem('/products/add', 'addProduct');
  static const editProduct = RouteItem('/products/edit/:id', 'editProduct');

  // ─────────────────── الإعدادات ───────────────────
  static const settings = RouteItem('/settings', 'settings');
  static const profileOrders = RouteItem('/profile/orders', 'profileOrders');
  static const profileReviews = RouteItem('/profile/reviews', 'profileReviews');

  /// Every route above. Add new routes here too: `route_guards_test.dart`
  /// fails if a route is missing from this list, or is not classified as
  /// public or protected in `route_guards.dart`.
  static const List<RouteItem> all = [
    splash,
    onboarding,
    login,
    register,
    forgotPassword,
    verifyResetCode,
    resetPassword,
    mainPages,
    home,
    profile,
    chat,
    favorites,
    products,
    productDetails,
    addProduct,
    editProduct,
    settings,
    profileOrders,
    profileReviews,
  ];
}

class RouteItem {
  final String path;
  final String name;

  const RouteItem(this.path, this.name);
}
