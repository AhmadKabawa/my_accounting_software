# Audit status (branch `claude/foundation-fixes`)

Verification level: **static review only**. The Flutter SDK could not be downloaded
in the authoring environment, so `flutter pub get`, `dart format`, `flutter analyze`,
`flutter test` and every platform build were **not run**. New tests were written but
never executed. Run them before merging.

| ID | Status | Notes |
| --- | --- | --- |
| B1 | fixed | `.env` no longer bundled; `assets/images/` now tracked so the declared directory exists. The image files themselves are still missing (see open items). |
| B2 | not reproduced | `build_runner`, `freezed`, `json_serializable`, `hive_generator` are already in `dev_dependencies`. Generated files were not regenerated. |
| B3 | not reproduced | `test/widget_test.dart` was already replaced on `main`. |
| B4 | not reproduced | Static scan of all imports found no case mismatches. Needs a Linux build to confirm. |
| B5 | confirmed, different cause | `LoginScreen`/`SignupScreen` bodies are fully commented out (empty `Scaffold`); there is no provider error because there is no UI. `AuthCubit` is now a single instance. |
| B6 | not reproduced | `INTERNET` is already in the main manifest. |
| F1 | fixed | Refresh token is stored as a refresh token. Test added. |
| F2 | fixed | Bare Dio for refresh, single-flight, no double refresh. Tests added. |
| F3 | fixed | GoTrue `/auth/v1/*` endpoints; `verifyResetCode` is unsupported by Supabase (use `confirmNewPassword`). |
| F4 | fixed | Supabase adapter + response mapper. Sign-up that requires e-mail confirmation returns a parse failure (decision needed). |
| F5 | partly fixed | `AuthCubit`/`SplashCubit` are singletons shared by router and screens. `redirect` stays disabled: enabling it before a working login screen exists would trap users. |
| F6 | fixed | Unrouted `UnimplementedError` stub removed. |
| F7 | open | `HomeCubit` is store-template code; redefine as an accounting dashboard once the domain/API exists. |
| F8 | fixed | Debug buttons only when `kDebugMode`. |
| F9 | open | `AppConfig.googleClientId` is a placeholder; per-platform setup needed. |
| Q1 | open | Hive is unencrypted. |
| Q2 | open | 41 Dart files are unreachable from `main.dart` (home sections, old auth widgets, `home_screen copy.dart`, `realtime/*`, …). Not deleted: needs owner decision. |
| Q3 | fixed | Only GET/HEAD/OPTIONS (or `extra.idempotent`) are retried. Tests added. |
| Q5-Q7, S3 | open | Unused deps unchecked; no CI; `applicationId` is `com.example.accounting_software` and release uses the debug signing config. |
| S1, S2 | fixed | Hardcoded URL/key removed, config via `--dart-define-from-file`. The removed key was an `anon` key (not a secret) so no rotation is required, but it remains in git history. |
| S4 / A1 | open | `hive_manager.dart` and `cache_manager.dart` in `core` import `UserModel` from `features/auth`. |
| A7 | open | All six onboarding keys point to `onboarding.title1`; the copy is still the sports-store text. |


## Branch `claude/audit-fixes` (second audit list, items 1-20)

Verification level: **static review only** (Flutter SDK unavailable). Nothing was
formatted, analysed, built or run, and every test below was written but never
executed. Run `dart format`, `flutter analyze` and `flutter test` before merging.

| # | Status | Notes |
| --- | --- | --- |
| 1 | fixed | `resolveRedirect` pure function, deny-by-default; `route_guards` no longer imports the router. Redirect enabled, app starts at `/`. |
| 2 | fixed | `NetworkInfoImpl` uses `connectivity_plus` only. |
| 3 | fixed | `GOOGLE_CLIENT_ID` read once in `EnvConfig` (dart-define), null when unset. |
| 4 | fixed | `LanguageInterceptor` enabled; `AppLanguageProvider` reads `LocaleCubit`. |
| 5 | not done | `Money` type: not in the requested set. |
| 6 | fixed | `TokenManager.sessionCleared` -> `AuthCubit`; `getCurrentUser` clears the session only on 401/403. |
| 7 | fixed | Recursive redaction in `LoggerInterceptor`. |
| 8 | fixed | Type-checked responses, `fromJsonList`, every exception mapped. |
| 10 | fixed | Splash `init()` idempotent, waits for `AuthCubit.checkAuthentication()`. |
| 11 | fixed | Sequential token writes with rollback; `saveTokens` for refresh. Not atomic. |
| 12 | fixed | Tests for `LanguageInterceptor`, `BaseCubit`, plus the new code. Hand-written fakes. |
| 13 | fixed | `EffectMixin` holds effects until the first listener. |
| 16 | fixed | Unused data models with `Color`/`IconData` removed. |
| 17 | fixed | Component themes take the built `TextTheme` instead of `Theme.of(context)`. |
| 18 | fixed | Duplicated padding/radius logic in `responsive_helper.dart` shared. |
| 19 | partly fixed | Path parameters encoded. `/products/...` paths still do not match Supabase; needs the real API contract. |
| 20 | reviewed | No `core` -> `features`, `data` -> `presentation` or `domain` -> Flutter/Dio imports found. Removed two empty files (`constants/test`, commented-out `check_auth_usecase.dart`). 34 files are still unreachable from `main.dart` (see Q2) and were left for the owner. |

Behaviour changes to be aware of: the redirect is now active (splash -> onboarding
-> login), `TokenManager` is no longer `const`, `AuthCubit` and `DioService`
constructors take one new required argument each, and the app bar, chips, buttons
and inputs now use the app text styles instead of Material defaults.
