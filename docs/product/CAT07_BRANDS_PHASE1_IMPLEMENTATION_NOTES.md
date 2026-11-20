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

## Integration findings / blocker before safe code integration
The repository is reachable through GitHub API editing tools, but this execution environment has no local checkout or Flutter SDK. Remote file creation/editing is possible; compiling and checking cross-file Flutter integration is not. The reviewed route composition and service-locator structure require further inspection before safely registering a new screen. The Supabase initialization line in `main.dart` is currently commented, so a brands datasource must not assume a ready Supabase singleton.

## Verification requested from maintainer
After implementation, run:
- `dart format --set-exit-if-changed .`
- `flutter analyze --no-fatal-infos`
- `flutter test`
- Manual responsive checks at 360, 600, 900, and 1200 container widths; RTL/LTR; light/dark; read-only and manage-permission accounts; empty, populated, loading, and network-error states.
