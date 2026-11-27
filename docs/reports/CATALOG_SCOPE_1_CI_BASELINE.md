# CAT Scope 1 — CI baseline and triage

> Baseline captured from GitHub Actions. This is a diagnostic record, not a claim that any failure has been fixed. A root cause is marked **unresolved** where the available run output proves only the symptom; tests must not be weakened to make the baseline green.

- Baseline run: [45918456946](https://github.com/AhmadKabawa/my_accounting_software/actions/runs/45918456946)
- Analyze and Test job: Analyze succeeded; test step failed.
- Result: **1413 passed, 20 failed**.
- Previous Categories run: [45889013226](https://github.com/AhmadKabawa/my_accounting_software/actions/runs/45889013226).
- Comparison: the 12 Categories failures below were already present in run 45889013226. The other 8 failures are newly observed in run 45918456946.
- CI's Auto-format Dart job succeeded. No Flutter command was run locally.

## Failed tests

| # | Test | Classification / observed cause | Required correction | Verification |
|---:|---|---|---|---|
| 1 | `test/features/catalog/categories/domain/category_tree_test.dart` — derives known no-product statistic and sorts flat results | **Pre-existing Categories failure.** Actual IDs were `[2, 3, 1]`, expected `[2, 3]`. Whether the parent row should be included depends on the specified meaning of “without products”; root cause not yet established. | Compare the test fixture and CAT-07 usage-filter semantics; fix implementation or test only if the specification proves the expectation wrong. | Pending |
| 2 | `test/features/catalog/categories/presentation/categories_screen_test.dart` — adding a subcategory saves once and reloads the tree | **Pre-existing Categories failure.** Flutter test exception; detailed stack not captured in the compact test summary. | Trace editor launch/save callback and test harness. | Pending |
| 3 | Same file — adding a subcategory to a leaf uses the same editor flow | **Pre-existing Categories failure.** Flutter test exception. | Trace leaf row action and shared editor flow. | Pending |
| 4 | Same file — category editor uploads a selected image and saves its URL | **Pre-existing Categories failure.** Expected one upload, observed zero. | Trace image picker/uploader wiring and test fake. | Pending |
| 5 | Same file — category image upload shows a clear Storage permission error | **Pre-existing Categories failure.** Expected one upload/error path, observed zero. | Trace uploader invocation before changing assertions. | Pending |
| 6 | Same file — desktop row opens side details panel and child navigation works | **Pre-existing Categories failure.** Details lookup for “Grandchild” found no widget; rendering exception also occurred. | Trace details panel content, expanded tree state and layout exception. | Pending |
| 7 | Same file — read-only users see no write actions in rows or details | **Pre-existing Categories failure.** RenderFlex overflow by 5 px. | Correct responsive layout without weakening permission assertions. | Pending |
| 8 | Same file — Tab reaches a category row and Enter opens its details | **Pre-existing Categories failure.** RenderFlex overflow by 5 px. | Correct row layout while preserving keyboard semantics. | Pending |
| 9 | Same file — details panel closes with Escape | **Pre-existing Categories failure.** RenderFlex overflow by 5 px. | Correct panel layout; retain Escape behavior. | Pending |
| 10 | Same file — level and usage filters are local on the full page | **Pre-existing Categories failure.** Expected category ID `[1]`, actual result empty. | Trace filter state/query mapping and fixture semantics. | Pending |
| 11 | Same file — details panel edit then add-child uses the shared editor flow | **Pre-existing Categories failure.** Rendering exception in the details/editor flow. | Trace panel layout and editor launch context. | Pending |
| 12 | Same file — changing filters clears a details selection outside results | **Pre-existing Categories failure.** RenderFlex overflow by 5 px. | Correct layout without changing selection-reset contract. | Pending |
| 13 | `test/localization/key_registry_test.dart` — every enum implementing AppKey is registered | **Confirmed registry omission.** `SizeSystemFailureKeys` exists under `catalog/size_systems/shared/domain/failures` but was absent from `allKeys` and its imports. | Add its import and enum values to `lib/app/localization/key_registry.dart`; preserve the registry test unchanged. | Pending CI |
| 14 | `test/architecture/ui_quality_gate_test.dart` — P-06 presentation files stay under line limit | **New implementation violation.** One or more presentation files exceed the enforced line limit; exact offender paths need the complete assertion payload. The architecture test is protected. | Split the offending feature presentation files by responsibility; do not edit the gate. | Pending |
| 15 | Same file — P-08 no hard-coded placeholder text or string concatenation | **New implementation violation.** One or more feature presentation files violate the text rule; exact paths need the complete assertion payload. | Replace literals/concatenation with registered bilingual AppKeys and arguments; do not edit the gate. | Pending |
| 16 | Same file — P-10 list pages use ListPageTemplate | **New implementation violation.** One or more list pages bypass the required list engine; exact paths need the complete assertion payload. | Route the affected list through CrudListScreen/ListPageTemplate; do not edit the gate. | Pending |
| 17 | `test/features/catalog/product_types/domain/product_type_test.dart` — any product or relationship locks code and blocks deletion | **New contract disagreement.** Test expects a relationship to lock the code; current ProductType comment says only product usage locks code, while relationships still block deletion. Specification must decide which contract is authoritative. | Read CAT-07 product-types specification and align model/test with it; do not relax the test by assumption. | Pending |
| 18 | Same file — unknown usage blocks deletion and locks code | **New contract disagreement.** Test expects unknown usage to lock code; current model locks code when productCount is unknown, but not necessarily when only a relationship count is unknown. | Verify specification's unknown-count and code-lock semantics; then correct model or test. | Pending |
| 19 | `test/features/catalog/product_types/data/product_types_remote_data_source_test.dart` — 400 on embedded counts retries without counts and leaves usage unknown | **New data-contract mismatch.** Test expects null after the fallback request but receives count `3`. It is not yet established whether the fallback response is valid authoritative count data or stale embedded data retained incorrectly. | Inspect both requests and response mapping; preserve unknown as null whenever the retry cannot prove the count. | Pending |
| 20 | `test/core/presentation/widgets/app_sidebar/app_sidebar_children_test.dart` — catalog destination children point at the real routes | **Confirmed stale test expectation.** `appDestinations` already contains eight catalog child routes, while the assertion listed only five. This is a test maintenance defect, not a destination implementation defect. | Extend the existing assertion to include Product Types, Tags and Sports via their route constants; keep the exact-route assertion intact. | Pending CI |

## CI interpretation

- Analyze completed successfully in the baseline run.
- The 20 failures are test failures, not an Analyze failure.
- The 12 Categories failures are inherited from run 45889013226; they are not newly introduced by the integration commit.
- The remaining 8 are new in run 45918456946. “New” describes when they first appear in the supplied baseline, not proof that every one was caused by the merge.
- No test was deleted, skipped, weakened, or changed in this baseline capture.
- No fix is claimed in this document. Each row remains pending until a commit and a subsequent CI run prove the result.

## Limitation of this capture

The available GitHub job summary provides the failure names and selected assertion output, but not the complete per-test diagnostic context for all 12 Categories failures and the architecture-gate offender paths. Those details must be retrieved before assigning a definitive root cause. The specification remains authoritative over guesses.
