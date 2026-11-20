# CAT-07 Brands — Phase 1 Implementation Notes

## Scope
CAT-07 is treated as a master-data hub with tabs. Per S49, its initial logical tabs are Brands, Categories, and Product Types. The current implementation phase prioritizes rebuilding Brands as the first fully functional pilot; Categories and Product Types must not appear as fake or inert controls before their own behavior is specified and implemented. The wider CAT-07 areas in ERP_Screen_Navigation_Map (colors, size systems, units, descriptive tables, properties/options, and type relationships) remain separately scoped extensions.

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
- Brands route is nested at `/catalog/brands`; the shell exposes the parent Catalog module, and the page shows a Catalog → Brands breadcrumb. Read-only users can open the list while create/edit/delete controls are gated by `masterdata.manage`.
- The screen uses the existing GetIt `IApiClient`, not the commented Supabase singleton initialization.
- The list presents brand identity as a single visual unit (logo, name, slug), uses status badges, responsive mobile cards, and server-side sorting. The editor groups identity, logo, and additional details; the list template now supports an optional breadcrumb.


## Brand data model — current scope and future decisions

The current database contract exposes only the fields listed above. The UI intentionally does not invent or send extra columns.

Useful candidates to evaluate in a later schema decision (not part of this implementation):
- Official website URL: useful only if staff need a canonical brand reference.
- Country of origin: useful only if the store maintains verified origin data; it must not be inferred from the brand name.
- Localized display names: consider separate Arabic/English names if the same brand must be searched and displayed in both languages.
- External reference/code: useful only if a supplier feed, marketplace, or integration needs a stable external identifier.

Do not turn the brand record into a supplier/manufacturer profile. Supplier data belongs to the supplier domain. Product/model assignment and a usage count on the brand list should be added only after the actual foreign-key relationship and its query cost are confirmed. No database migration is included here.

## Navigation and UX direction

The owner selected the CAT-07 hub-and-tabs direction, overriding the earlier Brands-only navigation proposal. The existing `/catalog/brands` path must remain a working deep link to the Brands tab. The hub path and sibling route registration are to be finalized after checking the current route registry. S49 defines the initial logical tabs (Brands, Categories, Product Types); the wider CAT-07 domains in the navigation map are future extensions. Do not expose inert tabs or fake menu entries: a tab becomes visible when its page has an explicit, implemented state and scope.

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
