# CAT-07 Brands — Phase 1 Implementation Notes

## Scope
Only the Brands tab of CAT-07. Do not implement categories, colors, sizes, product types, units, or other master-data tabs in this branch.

## Verified repository contracts (branch `vscode`)
- v1 scope lists CAT-07 as the first master-data screen and explicitly says Brands are the first table pilot.
- Component work order places CAT-07 after AUTH-04 and calls for the DataTable pilot using the existing Core components.
- Existing widgets include `AppDataTable`, `FilterBar`, `SearchableDropdown`, `AppButton`, `AppTextField`, `AppEmptyState`, `AppSkeleton`, and `InlineBanner`.
- Brands DB columns: `id`, `name` (required, varchar 150), `slug` (required, varchar 150), `logo` (nullable, varchar 500), `description` (nullable text), `is_active` (default true), standard update timestamp. Unique constraints on name and slug.
- RLS: read is open per catalog documentation; writes require `masterdata.manage`. UI permission is not a replacement for RLS.
- `masterdata.manage` is already present in known permission codes. `Permissions.masterData` is available.

## Required screen behavior
- List/table: brand name, slug, active status, logo preview when available.
- Search: name and slug.
- Filters: status (active/inactive); do not invent other filter semantics.
- Create: name (required), slug (required), description (optional), logo (optional).
- Validate required fields and surface duplicate name/slug/database errors without silently retrying writes.
- Loading, empty, error/retry, and success feedback.
- Read-only users can view but cannot create; write actions gated by `masterdata.manage`.
- Responsive web, RTL/LTR, light/dark.

## Implemented on `feat/cat07-brands-phase1`
- Added a Brands list screen using `ListPageTemplate`, `FilterBar`, `AppDataTable`, `AppTextField`, and `AppButton`.
- Added the Brand model and feature-owned REST endpoint contract for the existing Supabase/PostgREST API client.
- Added create, edit, and delete requests; server-side pagination and search by name/slug.
- Added Arabic/English feature keys and registered them in the app localization key registry.
- Added the Brands route as a shell branch and a navigation destination. Read access remains available; mutation controls use `masterdata.manage` and database RLS remains authoritative.
- The screen uses the shared `IApiClient` from GetIt. It does not depend on the commented Supabase singleton initialization.

## Known gaps for the maintainer review
- Status filtering and logo preview are not yet implemented; the current list shows name, slug, and active state.
- The edit dialog currently uses Arabic literal text for a few dialog-only labels; feature field labels use the bilingual key system.
- API error feedback is currently represented through the shared list error/retry state; mutation failures remain in the dialog without a detailed server message.
- No Flutter compile, formatter, analyzer, test, or manual run was performed, as explicitly requested.

## Verification requested from maintainer
When ready, run:
- `dart format --set-exit-if-changed .`
- `flutter analyze --no-fatal-infos`
- `flutter test`
- Manual responsive checks at 360, 600, 900, and 1200 container widths; RTL/LTR; light/dark; read-only and manage-permission accounts; empty, populated, loading, and network-error states.
