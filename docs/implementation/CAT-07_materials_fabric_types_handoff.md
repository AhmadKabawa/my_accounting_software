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
- Trim names/codes on submit and prevent duplicate code; use the repository's existing exception/failure translation pipeline.
- Display name/code and active status across table/card/grid view modes; type and description are available in the editor and type is filterable.
- SQLSTATE `23505` maps to a duplicate-code message; `23503` maps to an in-use delete failure.

## Fabric Types (`fabric_types`)

- Required: `name` (max 100), `code` (max 50); unique `code`.
- Optional: `fabric_category`, `description`.
- `fabric_category` allowed values: `knit`, `woven`, `fleece`.
- `is_named_fabric` is specified as boolean, default false; do not silently omit this field from entity/editor/query/display where applicable.
- `is_active` defaults true; code-level behavior must support disabling/reactivating.
- Include search, paging, supported sorting, status/category filters, states, permissions and all three data-view modes.
- SQLSTATE `23505` maps to a duplicate-code message; `23503` maps to an in-use delete failure.
- Trim values on submit and prevent duplicate code using the existing error handling.

## Shared implementation expectations

- Follow existing Brands/Colors patterns and the new CRUD feature recipe; reuse core widgets and `PagedListCubit`, do not create a parallel CRUD engine.
- Keep feature code typed; no `dynamic`, unsafe casts, new packages or raw user-facing strings.
- AppKey/localization registry must be updated for all new labels and messages.
- Use current design tokens/context.ui; no raw color/size literals.
- Feature DI, catalog composition root, routing and Catalog hub entry must be wired consistently with existing features.
- Ensure edit/create/duplicate forms have correct dirty-state behavior and unsaved-change protection.
- Do not delete referenced records; follow the existing delete guard/soft-disable convention and backend semantics.
- Do not claim tests/build/analyze have run from this branch. Those checks must be run by the Flutter workspace team.

## Verification checklist for the workspace team

1. Format and analyze; resolve all diagnostics.
2. Run architecture/UI quality tests and feature-import/platform-isolation/localization checks.
3. Unit tests for query/filter/sort, create/edit validation, normalization, error mapping and duplicate seeds.
4. Widget tests for editor dirty-state/guard, active toggle, error/loading/empty states, responsive table/card/grid, RTL/LTR and light/dark.
5. Verify the API/database contract for both tables and uniqueness constraints before merge.
6. Confirm Catalog hub/navigation and DI startup have no duplicate registrations or missing routes.
7. Verify duplicate mode is intentionally disabled in the shared list until a domain-safe duplicate seed flow is added.
7. Report exact test commands/results and commit SHA; keep this branch separate until review.

## Schema confirmation

`docs/backend/DATA_MODEL.md` confirms `materials` columns (`name`, `code`, `material_type`, `description`, `is_active`) and `fabric_types` columns (`name`, `code`, `fabric_category`, `is_named_fabric`, `description`, `is_active`), with unique `code` on both tables. Allowed enum values are confirmed by the schema. `is_named_fabric` is stored and editable as a boolean defaulting to false; no additional business meaning has been invented.
