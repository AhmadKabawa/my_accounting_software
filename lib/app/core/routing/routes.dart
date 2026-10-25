class AppRoutes {
  // ─────────────────── البداية ───────────────────
  static const splash = RouteItem('/', 'splash');
  static const onboarding = RouteItem('/onboarding', 'onboarding');

  // ─────────────────── المصادقة ───────────────────
  static const login = RouteItem('/login', 'login');
  static const register = RouteItem('/register', 'register');

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
  // static const productDetails = RouteItem('/products/:id', 'productDetails');
}

class RouteItem {
  final String path;
  final String name;

  const RouteItem(this.path, this.name);
}
