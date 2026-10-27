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
