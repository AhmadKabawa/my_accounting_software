# CAT-07 Brands — Phase 1 Implementation Notes

## Scope
Only the Brands tab of CAT-07. Categories, colors, sizes, product types, units, and other master-data tabs remain out of scope.

## Repository and database contracts
- Brands are the first CAT-07 master-data screen and the pilot for the shared list/table components.
- Existing Core components are reused: `ListPageTemplate`, `FilterBar`, `AppDataTable`, `AppEmptyState`, `AppImage`, `InlineBanner`, `AppButton`, and `AppTextField`.
- Brands columns: `id`, `name` (required, varchar 150), `slug` (required, varchar 150), `logo` (nullable, varchar 500), `description` (nullable text), `is_active` (default true), and timestamps.
- Brand name and slug are unique. The UI handles HTTP 409 / PostgreSQL unique-violation feedback with a localized duplicate-value message.
- Catalog read access is available to read-only users. Writes require `masterdata.manage`; UI gates are convenience only and database RLS remains authoritative.

## Implemented on `feat/cat07-brands-phase1`
- Brand domain model and feature-owned PostgREST endpoint/select contract.
- Brands list with server-side pagination, ordering, and search across name and slug.
- Server-side status filter for all / active / inactive, displayed through the shared `FilterBar` and removable active-filter chip.
- Logo thumbnails in the list and a live logo preview in the editor, using Core `AppImage`.
- Create, edit, and delete operations through the shared `IApiClient`; no silent write retries.
- Required name and slug validation; name/slug/logo database-length limits; lowercase Latin slug format validation; HTTP(S) logo URL validation.
- Slug assistance: Latin names can populate a suggested slug; Arabic names receive a localized instruction to enter an English slug manually.
- Localized save errors, duplicate name/slug feedback, delete failure feedback, load/retry state, and distinct empty/no-results states.
- Arabic/English feature keys registered in the app localization key registry. Dialog copy is localized; no hard-coded Arabic UI labels remain in the feature screen.
- Brands route registered in the shell and route catalogue; read-only users can open the list while create/edit/delete controls are gated by `masterdata.manage`.
- The screen uses the existing GetIt `IApiClient`, not the commented Supabase singleton initialization.

## Deliberate boundaries
- The logo field accepts a public HTTP(S) image URL; uploading image files/storage integration is not part of this phase.
- Arabic-to-Latin transliteration is not guessed. Users enter the slug manually for Arabic brand names.
- Delete is a hard delete request; referential constraints and RLS on the database remain authoritative. A failed delete is surfaced without retrying the write automatically.
- Duplicate detection uses the PostgREST unique-conflict HTTP status and PostgreSQL unique-violation code when exposed by the shared exception.

## Maintainer verification still required
No Flutter formatter, analyzer, tests, build, or app run was performed, as explicitly requested. Please verify:
1. `dart format --set-exit-if-changed .`
2. `flutter analyze --no-fatal-infos`
3. `flutter test`
4. Manual behavior at 360 / 600 / 900 / 1200 widths, RTL and LTR, light and dark themes.
5. Read-only and manage-permission users; empty and populated datasets; search, status filter, pagination; invalid logo URL; duplicate name/slug; failed load/save/delete; and image loading/error fallback.
