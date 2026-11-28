# Scope 1 Catalog review — progress

- Branch: `fix/scope-1-catalog-review`
- Target: `integration/catalog-scope-1-combined`
- Starting base: `211a5f89fd5dff74d55dc1035a129b05ea71e222`
- Code head validated by CI: `2b1a40a9121873846d3a58d86f1d11868436d538`
- CI run #2645: formatting and static analysis passed. The feature-branch workflow skipped the full Flutter test suite; no test-suite pass is claimed.

## Step 1 — gap register and evidence

- Attributes screen/list config/route/registry exist; no duplicate screen was created.
- G-1 child action is wired through category row extra actions and covered by category screen tests.
- G-2 parent selector is before category identity fields; the screen test asserts ordering.
- G-3 inactive parent categories are excluded except the currently selected parent; covered by CategoryFormCubit tests.
- G-4 sibling duplicate name remains a non-blocking warning; covered by CategoryFormCubit tests.
- No CAT-07 category behavior changes were needed; the existing implementation was retained.

## Step 2 — category gaps

- Verified existing G-1 through G-4 implementations and focused tests.
- No changes were made to the category tree or editor behavior.

## Step 3 — Catalog Hub

- Hub now presents three list-data groups: product definition, properties/specifications, and descriptive classification.
- Added distinct AppIcons for the catalog areas and a core icon registration test.
- Added widget coverage for the 13 catalog entries, narrow RTL/high-text-scale and desktop LTR/dark layouts, plus route navigation.
- Counts remain intentionally absent where a ready count use case is not available; no placeholder/flickering count was introduced.

## Step 4 — Product type details and deletion

- Loading uses AppSkeleton placeholders rather than an empty-state presentation.
- Load failures use InlineBanner with retry.
- Published-product usage is queried best-effort and shown as an InlineBanner warning; a count-query failure does not block the details page.
- Existing 23503 mapping and the feature-specific delete explanation/deactivate alternative were verified in the current data section and tests; no duplicate generic dialog was added.
- Read-only access remains enforced through `masterData.manage`.

## Step 5 — Materials and fabric types

- Added safe `tryParse(Object?)` parsing to the existing MaterialType and FabricCategory domain enums.
- Models now use the enum parsers rather than private parsing switches.
- Added shared presentation label functions and reused them in list filters and editor dropdowns.
- Added parsing tests for valid, unknown, and null values.

## Step 6 — responsive and Option Sets coverage

- Extended the relevant catalog responsive suites to include 280px layouts with 1.5 text scale while retaining 1200px desktop coverage.
- Added Catalog Hub coverage for 280px RTL/light and 1200px LTR/dark.
- Existing Option Sets widget tests cover list/editor workflows, add/edit/deactivate, and nested options; the responsive matrix now includes the narrow/high-scale case.

## Remaining limitations

- The repository's push workflow intentionally skips the full Flutter test suite on feature branches. Those widget and unit tests were added/updated but were not executed by this workflow.
- No live Supabase/PostgREST verification was performed.
- No merge was performed. Pull request #22 is open against `integration/catalog-scope-1-combined`; it has not been merged.

## Tooling boundary

GitHub API commits and GitHub Actions were used. No local Flutter SDK, local `dart format`, `flutter analyze`, or local `flutter test` command was run.
