import 'package:dartz/dartz.dart';
import 'package:accounting_software/app/core/error/error_handling/exceptions/api_exception.dart';
import 'package:accounting_software/app/core/services/network/api_client_interface.dart';
import 'package:accounting_software/app/core/services/network/api_end_points.dart';
import 'package:accounting_software/app/core/foundation/types/api_result.dart';
import 'package:accounting_software/app/features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';
import 'package:accounting_software/app/features/auth/data/models/auth_result/auth_result_model.dart';
import 'package:accounting_software/app/features/auth/data/models/user/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required IApiClient apiClient,
    required GoogleSignIn googleSignIn,
  }) : _apiClient = apiClient,
       _googleSignIn = googleSignIn;

  final IApiClient _apiClient;
  final GoogleSignIn _googleSignIn;

  // ── Authentication ────────────────────────────────────────────

  @override
  Future<ApiResult<AuthResultModel>> login({
    required String email,
    required String password,
  }) => _apiClient.post(
    AppEndpoints.auth.login,
    data: {'email': email, 'password': password},
    requiresAuth: false,
    fromJson: AuthResultModel.fromJson,
  );

  @override
  Future<ApiResult<AuthResultModel>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) => _apiClient.post(
    AppEndpoints.auth.register,
    data: {
      'email': email,
      'password': password,
      'data': {
        // ← name و phone داخل data object
        'full_name': name,
        if (phone != null) 'phone': phone,
      },
    },
    requiresAuth: false,
    fromJson: AuthResultModel.fromJson,
  );

  @override
  Future<ApiResult<UserModel>> getCurrentUser() => _apiClient.get(
    AppEndpoints.auth.getCurrentUser,
    fromJson: UserModel.fromJson, // ← الـ Model يتعامل مع { user: {} }
  );

  @override
  Future<ApiResult<AuthResultModel>> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();

      if (account == null) {
        return ApiFailure(ApiException.cancelled());
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if (idToken == null) {
        return ApiFailure(ApiException.unknown());
      }

      return _apiClient.post(
        AppEndpoints.auth.googleSignIn,
        data: {'id_token': idToken, 'access_token': accessToken},
        requiresAuth: false,
        fromJson: AuthResultModel.fromJson,
      );
    } catch (e) {
      return ApiFailure(
        ApiException.unknown(serverMessage: e.toString() ?? ""),
      );
    }
  }

  @override
  Future<ApiResult<Unit>> logout() =>
      _apiClient.post<Unit>(AppEndpoints.auth.logout, fromJson: (_) => unit);

  // ── Password Management ───────────────────────────────────────

  @override
  Future<ApiResult<Unit>> sendResetCode({required String email}) =>
      _apiClient.post<Unit>(
        AppEndpoints.auth.sendResetCode,
        data: {'email': email},
        requiresAuth: false,
        fromJson: (_) => unit,
      );

  @override
  Future<ApiResult<Unit>> verifyResetCode({
    required String email,
    required String code,
  }) => _apiClient.post<Unit>(
    AppEndpoints.auth.verifyResetCode,
    data: {'email': email, 'code': code},
    requiresAuth: false,
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<Unit>> resetPassword({
    required String token,
    required String newPassword,
  }) => _apiClient.post<Unit>(
    AppEndpoints.auth.resetPassword,
    data: {
      'token': token,
      'new_password': newPassword,
      'new_password_confirmation': newPassword,
    },
    requiresAuth: false,
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _apiClient.post<Unit>(
    AppEndpoints.auth.changePassword,
    data: {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPassword,
    },
    fromJson: (_) => unit,
  );

  @override
  Future<ApiResult<Unit>> confirmNewPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _apiClient.post<Unit>(
    AppEndpoints.auth.confirmNewPassword,
    data: {
      'email': email,
      'code': code,
      'new_password': newPassword,
      'new_password_confirmation': newPassword,
    },
    requiresAuth: false,
    fromJson: (_) => unit,
  );

  // ── Profile Management ────────────────────────────────────────

  @override
  Future<ApiResult<UserModel>> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) => _apiClient.put(
    AppEndpoints.auth.updateProfile,
    data: {
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (phone != null) 'phone': phone,
    },
    fromJson: UserModel.fromJson,
  );
}

// * وايضا لا تنسى الترجمة     ولا شكل النص get
/**

 * 
 * @override
Future<ApiResult<AuthResultModel>> signInWithGoogle() async {
  try {
    await _googleSignIn.signOut();
    final account = await _googleSignIn.signIn();

    // ✅ المستخدم ألغى → ApiException بدل hardcoded
    if (account == null) {
      return ApiFailure(ApiException.cancelled());
    }

    final auth        = await account.authentication;
    final idToken     = auth.idToken;
    final accessToken = auth.accessToken;

    // ✅ فشل الـ token → ApiException بدل hardcoded
    if (idToken == null) {
      return ApiFailure(ApiException.unknown());
    }

    return _apiClient.post(
      ApiEndpoints.googleSignIn,
      data: {'id_token': idToken, 'access_token': accessToken},
      options: Options(extra: {'requiresAuth': false}),
      fromJson: _parseAuthResponse,
    );

  } catch (e) {
    // ✅ أي خطأ غير متوقع → ApiException بدل hardcoded
    return ApiFailure(ApiException.unknown(e.toString()));
  }
}
```

---
*/

//طريقة افضل لعدم ستخدامالانترنت فحص

/**@override
Future<Either<Failure, PaginatedResult<ProductEntity>>> getProducts(
  GetProductsParams params,
) async {

  // ── 1. حاول تجيب من الـ API أولاً ──────────────
  final result = await _remote.getProducts(params);

  return result.fold(
    // ── 2. فشل الـ API ───────────────────────────
    (exception) async {
      final failure = ExceptionMapper.map(exception);

      // ── 3. ما في نت — رجّع Cache لو موجود ──────
      if (failure is NoInternetFailure) {
        final cached = await _local.getCachedProducts();

        if (cached.isNotEmpty) {
          // ✅ رجّع Cache مع إشارة أنه قديم
          return Right(
            _toPaginatedResult(cached, params, isStale: true),
          );
        }
      }

      // ── 4. في نت لكن API فشل، أو ما في cache ───
      return Left(failure);
    },

    // ── 5. نجح الـ API — احفظ وارجع ─────────────
    (data) async {
      await _local.cacheProducts(data.items.cast<ProductModel>());
      return Right(data);
    },
  );
} */
