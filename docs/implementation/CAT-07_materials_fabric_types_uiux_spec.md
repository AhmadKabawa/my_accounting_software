# CAT-07 UI/UX implementation spec — Materials and Fabric Types

**Status:** implementation specification aligned to the current CAT-07 descriptive-table draft and DATA_MODEL; not a new owner approval.  
**Routes:** `/catalog/materials`, `/catalog/fabric-types`  
**Scope:** two independent CRUD pages using the existing shared CRUD engine; no generic dynamic form renderer.

## Goal and users

Allow a user with `masterdata.manage` to create, edit, activate/deactivate and delete unused material/fabric-type records. Read access follows backend RLS. The Catalog Hub is the entry point.

## Data and fields

See [field coverage](CAT-07_materials_fabric_types_field_coverage.md). Required identity is name + code. Material type and fabric category are optional enum filters and editor fields. Fabric `is_named_fabric` remains persisted but hidden until its meaning is documented (D-DT-3).

## List behavior

- Shared `CrudListScreen` with table/cards/grid, server paging, search, sort, empty/loading/error and permission behavior.
- Columns: name, code, secondary material type/category, status. Fabric's `is_named_fabric` is deliberately not shown.
- Search: name/code. Filters: status plus material type/category. Sort: name/code/status. Stable tie-break: id.
- Explicit selection mode and bulk activate/deactivate/delete are supported; selection starts off. Duplicate mode is disabled until a safe unique-code seed is specified.
- No statistics cards: no aggregate endpoint is specified, and page-local counts are not a truthful total.

## Editor behavior

- Uses `showAppFormDialog` + `CrudEditorDialog`, shared unsaved-change guard, fixed actions and scrollable body.
- Name (100), code (50, LTR), optional enum, description, active switch. Fabric also preserves hidden `is_named_fabric` unchanged (new records default false).
- Create sends the selected active value. Edit sends `is_active` only when changed; activate/deactivate actions send only `is_active`.
- Unique code conflict (`23505`) is localized. FK restriction (`23503`) tells the user to deactivate instead.
- External form values (active/type/category) participate in dirty state and reset to their original values.

## Responsive, direction and theme

The shared CRUD engine owns responsive table/cards/grid and page scrolling. Code is rendered/entered LTR; names/descriptions follow app direction. Existing AppText/AppTextField/AppCard/CrudList components and design tokens are reused; no local colors, sizes or new Core component.

## Navigation and permissions

Both routes are children of the Catalog shell branch, appear as Catalog Hub cards, and are registered in route registry and app router. UI write controls use `Permissions.masterData.manage`; server RLS is authoritative.

## Verification still required

Run formatting, `flutter analyze --no-fatal-infos`, all tests and the architecture/UI quality suite in the Flutter workspace. Add/verify fake API/repository, Cubit and responsive Widget tests; visually inspect 360/600/900/1200, RTL/LTR, light/dark. No Flutter command or live Supabase operation is claimed from this branch.
