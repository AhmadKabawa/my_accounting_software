# CAT-07 Materials + Fabric Types implementation handoff

Branch: `feat/catalog-materials-fabric-types`
Base: `integration/catalog-scope-1`
Status: source implementation committed; awaiting Flutter workspace verification

This branch now contains the Materials and Fabric Types domain, data, presentation, dependency-injection, route, localization and Catalog Hub implementation. The CAT-07 specification and DATA_MODEL.md are the source of truth for fields and constraints; the shared CRUD recipe is the source of truth for wiring.

## Materials (`materials`)

- Required: `name` (max 100), `code` (max 50); unique `code`.
- Optional: `material_type`, `description`.
- `material_type` allowed values: `natural`, `synthetic`, `blended`.
- `is_active` defaults true; code-level behavior must support disabling/reactivating.
- Include search, paging, sorting only on fields supported by the remote query, empty/loading/error states, and permissions per catalog conventions.
- Trim names/codes on submit and prevent duplicate code; use the repository's existing exception/failure translation pipeline. On edit, include `is_active` in PATCH only when changed.
- Display name/code and active status across table/card/grid view modes; type and description are available in the editor and type is filterable.
- SQLSTATE `23505` maps to a duplicate-code message; `23503` maps to an in-use/delete-instead-deactivate message.

## Fabric Types (`fabric_types`)

- Required: `name` (max 100), `code` (max 50); unique `code`.
- Optional: `fabric_category`, `description`.
- `fabric_category` allowed values: `knit`, `woven`, `fleece`.
- `is_named_fabric` is boolean default false. CAT-07 decision D-DT-3 says its meaning is undocumented and the field must not be exposed in UI; the implementation preserves it in the model and on edits, and defaults new rows to false.
- `is_active` defaults true; code-level behavior must support disabling/reactivating.
- Include search, paging, supported sorting, status/category filters, states, permissions and all three data-view modes.
- Bulk activate/deactivate/delete is available through the shared engine; selection starts disabled. Duplicate mode is disabled until a safe unique-code seed is defined.
- SQLSTATE `23505` maps to a duplicate-code message; `23503` maps to an in-use delete failure.
- Trim values on submit and prevent duplicate code using the existing error handling.

## Shared implementation expectations

- Follow existing Brands/Colors patterns and the new CRUD feature recipe; reuse core widgets and `PagedListCubit`, do not create a parallel CRUD engine.
- Keep feature code typed; no `dynamic`, unsafe casts, new packages or raw user-facing strings.
- AppKey/localization registry must be updated for all new labels and messages.
- Use current design tokens/context.ui; no raw color/size literals.
- Feature DI, catalog composition root, routing and Catalog hub entry must be wired consistently with existing features.
- Ensure create/edit forms have correct dirty-state behavior and unsaved-change protection; duplicate mode is disabled by design until a safe seed is defined.
- Do not delete referenced records; follow the existing delete guard/soft-disable convention and backend semantics.
- Do not claim tests/build/analyze have run from this branch. Those checks must be run by the Flutter workspace team.

Field coverage, integration impact and UI/UX implementation decisions are recorded in:
- `CAT-07_materials_fabric_types_field_coverage.md`
- `CAT-07_materials_fabric_types_integration_impact.md`
- `CAT-07_materials_fabric_types_uiux_spec.md`

## Verification checklist for the workspace team

1. Format and analyze; resolve all diagnostics.
2. Run architecture/UI quality tests and feature-import/platform-isolation/localization checks.
3. Unit tests added for query/filter/sort, model mapping, field validation and repository mapping of `23505`/`23503`; add Cubit/widget coverage and run the complete suite.
4. Widget tests for editor dirty-state/guard, active toggle, error/loading/empty states, responsive table/card/grid, RTL/LTR and light/dark.
5. Verify the API/database contract for both tables and uniqueness constraints before merge.
6. Confirm Catalog hub/navigation and DI startup have no duplicate registrations or missing routes.
7. Verify duplicate mode is intentionally disabled in the shared list until a domain-safe duplicate seed flow is added.
8. Report exact test commands/results and commit SHA; keep this branch separate until review.

## Schema confirmation

`docs/backend/DATA_MODEL.md` confirms `materials` columns (`name`, `code`, `material_type`, `description`, `is_active`) and `fabric_types` columns (`name`, `code`, `fabric_category`, `is_named_fabric`, `description`, `is_active`), with unique `code` on both tables. Allowed enum values are confirmed by the schema. `is_named_fabric` is stored as a boolean defaulting to false. CAT-07 D-DT-3 explicitly says not to expose it until its meaning is documented; the editor preserves its existing value without showing a control.
