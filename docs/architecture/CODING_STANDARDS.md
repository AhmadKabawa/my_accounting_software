# Coding Standards

> This guide defines practical Dart/Flutter conventions for this repository.  
> Read `AGENTS.md` for the repository-wide engineering rules and `ARCHITECTURE_RULES.md` for layer boundaries and Core decisions. If guidance overlaps, those two documents are authoritative.

## 1. Naming and file organization

- Use `UpperCamelCase` for types, `lowerCamelCase` for members, and `snake_case.dart` for Dart files.
- Name files after their primary public type or responsibility; avoid vague names such as `helper.dart`, `utils.dart`, or `common.dart` when a precise name is possible.
- Keep feature code under `lib/app/features/<feature>/` and shared infrastructure under `lib/app/core/`.
- Keep one primary public responsibility per file. Small tightly coupled declarations may remain together when that improves discoverability.
- Keep generated files generated; edit their source annotations/models instead of hand-editing generated output.

## 2. Dart style and API design

- Follow `dart format` and the enabled analyzer rules.
- Prefer immutable fields and `const` constructors where appropriate.
- Use explicit types at public API boundaries; allow inference for obvious local values.
- Prefer named parameters when a call has multiple optional or same-typed arguments.
- Keep functions focused and avoid hidden side effects in getters.
- Use sealed classes/enums or other explicit types for finite states instead of loosely related strings.
- Avoid `dynamic`, force unwraps, and broad casts unless the boundary requires them and the reason is clear.
- Do not add an abstraction solely to wrap one trivial call; introduce interfaces when they provide a real boundary, test seam, or replaceable implementation.

## 3. Imports and dependencies

- Use package imports for project code and keep imports grouped consistently.
- Import the narrowest owning file; do not rely on accidental transitive exports.
- Avoid circular imports and cross-feature imports that bypass a public contract.
- Reuse existing Core services and utilities before introducing a package or a parallel implementation.
- Keep dependency registration in the owning DI module; do not instantiate service-locator registrations inside Widgets or repositories.

## 4. Layer responsibilities

- **Presentation:** Widgets, user interaction, view state, and translation/display of messages.
- **Domain:** business rules, entities, repository contracts, and use cases; no Flutter or infrastructure implementation dependencies.
- **Data:** DTOs, data sources, repository implementations, serialization, and mapping infrastructure failures into domain failures.
- **Core:** stable cross-cutting infrastructure and shared design-system capabilities, not feature business rules.
- Do not move code between layers merely to make the folder tree look uniform. Use only layers that serve a real purpose.

## 5. State and asynchronous work

- Keep durable screen data in State; use Effects for one-time navigation, dialogs, and transient messages.
- Prefer the project's `BaseCubit`, `EffectMixin`, and `BlocEffectListener` contracts rather than introducing another event channel.
- Handle errors explicitly; do not swallow exceptions or expose infrastructure exceptions to Widgets.
- Check lifecycle/mounted state before using a BuildContext after an asynchronous gap.
- Cancel requests and subscriptions when their owning Cubit/Widget is closed or disposed.
- Do not start asynchronous work from constructors. Expose an explicit initialization method or use the established lifecycle owner.

## 6. Errors and user messages

- Convert infrastructure exceptions at the Data/repository boundary using the existing error-mapping path.
- Carry `Failure`/`AppKey` through application state and Effects; translate at the presentation boundary.
- Do not translate a message in a repository or store already translated UI strings in domain state.
- Do not catch an error only to rethrow it unchanged; add context, map it, or let it propagate.

## 7. Network and persistence

- Use the shared API client and endpoint definitions.
- Keep request/response serialization in Data models.
- Do not log access tokens, passwords, secrets, or sensitive financial data.
- Use secure storage for credentials/tokens and preferences for non-sensitive settings.
- Retry only operations that are safe to repeat. Financial writes require server-enforced idempotency before any retry opt-in.

## 8. Financial values

- Never use `double` as the persisted or authoritative representation of money.
- Preserve currency identity and the exchange rate used for conversions.
- Do not derive balances from manually editable aggregate fields.
- Treat posted documents and ledger movements as auditable records; correct them through explicit reversal/adjustment flows.
- Keep business calculations out of UI code and execute authoritative posting/validation on the trusted server.

## 9. Tests and comments

- Test observable behavior, edge cases, and failure paths—not private implementation details.
- Keep tests deterministic; isolate network, clock, storage, and other external dependencies.
- Name tests by behavior and expected outcome.
- Comments should explain intent, constraints, or non-obvious trade-offs; do not narrate obvious code.
- Remove obsolete commented-out implementations rather than keeping them as an informal archive.
- Preserve comments that explain security, financial idempotency, lifecycle, or compatibility constraints.
- A test is not evidence of success until it has actually been run; report unavailable checks honestly.

## 10. Before submitting

- Run formatting, analysis, and relevant tests where the SDK/toolchain is available.
- Review the diff for unrelated changes, generated-file edits, secrets, dead code, and stale documentation.
- Update the architecture map or usage examples when a shared API or its contract changes.
- Summarize changed files, behavior, checks run, and remaining limitations.
