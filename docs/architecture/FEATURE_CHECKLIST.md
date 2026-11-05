# Feature Delivery Checklist

> Operational checklist for implementing a feature in this repository.  
> Global engineering expectations live in `AGENTS.md`; architecture decisions and Core boundaries live in `ARCHITECTURE_RULES.md`. This file turns those rules into a repeatable feature review.

## 1. Scope and acceptance criteria

- [ ] Describe the user problem and the expected outcome.
- [ ] Define the feature's in-scope and out-of-scope behavior.
- [ ] List normal, empty, loading, validation, permission-denied, and failure states where applicable.
- [ ] Identify affected routes, roles, data entities, external services, and platform constraints.
- [ ] Resolve ambiguities that could affect financial balances, stock, permissions, or data ownership before implementation.

## 2. Architecture and data flow

- [ ] Keep feature-specific code inside `lib/app/features/<feature>/`.
- [ ] Use `data`, `domain`, and `presentation` only where each layer has a real responsibility; do not add empty layers or placeholder files.
- [ ] Keep business rules and calculations out of Widgets and Core UI.
- [ ] Keep Domain independent of Flutter, Dio, storage implementations, and Presentation.
- [ ] Keep Data independent of Presentation.
- [ ] Reuse existing Core APIs after checking their actual signatures and tests; do not create parallel helpers or services.
- [ ] Document any deliberate deviation from the established architecture and its reason.

## 3. Domain and data

- [ ] Model business concepts and invariants explicitly.
- [ ] Define repository contracts in Domain and implementations in Data when a repository boundary is needed.
- [ ] Keep DTO/JSON mapping and remote/local data-source details in Data.
- [ ] Convert infrastructure exceptions to the project's `Failure` contract at the repository boundary.
- [ ] Avoid leaking raw Dio, Supabase, Hive, or Flutter types into Domain.
- [ ] Handle pagination, sorting, filtering, and empty responses explicitly where relevant.

## 4. State, dependency injection, and lifecycle

- [ ] Keep each Cubit/Bloc focused on one feature responsibility.
- [ ] Put persistent screen data in State and one-time UI actions in Effects.
- [ ] Use `BaseCubit`/Effects consistently where appropriate; do not emit navigation or transient messages as persistent state.
- [ ] Choose `registerFactory`, `registerLazySingleton`, or `registerSingleton` according to actual lifetime and state-sharing requirements.
- [ ] Ensure each created Cubit/Bloc is closed by its owner and subscriptions/controllers are disposed.
- [ ] Register feature dependencies in that feature's DI module and let `lib/app/app_di.dart` coordinate initialization.
- [ ] Avoid duplicate registrations and hidden global mutable state.

## 5. UI, routing, localization, and permissions

- [ ] Use existing design-system widgets and `context.ui` APIs where they cover the requirement.
- [ ] Support the required screen sizes, RTL/LTR direction, and light/dark themes.
- [ ] Put user-facing text in the shared translation keys and both supported language maps.
- [ ] Define routes in `AppRoutes`, add them to `AppRoutes.all`, classify them in route guards, and connect them in the router.
- [ ] Treat UI permission checks as presentation guidance only; enforce authorization on the server and through RLS.
- [ ] Do not expose a control that appears functional when its action is not implemented.

## 6. Network, storage, and security

- [ ] Use the shared `IApiClient`/Dio setup and `AppEndpoints`; do not create a Dio client inside a feature.
- [ ] Handle authentication expiry, cancellation, connectivity, and malformed responses deliberately.
- [ ] Do not retry financial writes automatically. An explicit idempotency opt-in is safe only when the server guarantees duplicate suppression.
- [ ] Store tokens only through the secure-storage/token-management path.
- [ ] Never include service-role credentials or server secrets in the Flutter client or repository.
- [ ] Do not assume local-to-cloud fallback is synchronization; define durable queuing, duplicate prevention, and conflict policy before implementing cross-database sync.

## 7. Accounting and inventory integrity

Apply these checks whenever the feature touches money, invoices, payments, balances, stock, returns, or exchange rates.

- [ ] Avoid binary floating-point for financial amounts; use the project's approved exact representation.
- [ ] Preserve the original currency and amount; never aggregate currencies without a recorded exchange rate.
- [ ] Derive balances from posted documents, movements, payments, allocations, and adjustments rather than editable totals.
- [ ] Keep posted financial documents auditable; use reversal/correction flows instead of silent mutation.
- [ ] Make posting and stock mutations atomic on the trusted server side where applicable.
- [ ] Protect against duplicate submissions and repeated financial effects.
- [ ] Cover partial payments, overpayments/advances, refunds, returns, and rounding boundaries where relevant.

## 8. Tests and verification

- [ ] Add focused unit tests for domain rules and calculations.
- [ ] Add repository/data tests for mapping, exception conversion, and API edge cases.
- [ ] Add Cubit/Bloc tests for loading, success, failure, cancellation, and emitted Effects.
- [ ] Add widget tests for important user interactions and visible states.
- [ ] Add route/permission tests when navigation or access changes.
- [ ] Run `dart format`, `flutter analyze`, and relevant tests when the Flutter SDK is available.
- [ ] Record commands actually run and their results. Mark unavailable checks as `NOT_RUN`; never imply success without execution.

## 9. Completion review

- [ ] No dead/commented-out implementation, placeholder action, unexplained `TODO`, or unused dependency was added.
- [ ] Documentation and examples match the implemented API.
- [ ] Changed files and behavioral impact are summarized.
- [ ] Known limitations, untested platforms, and follow-up work are recorded.
- [ ] The change is committed on the intended feature branch and is not merged into the base branch without authorization.
