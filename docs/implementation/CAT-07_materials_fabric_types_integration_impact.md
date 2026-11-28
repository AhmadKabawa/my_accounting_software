# CAT-07 — Integration impact: Materials and Fabric Types

DATA_MODEL/API source: `docs/backend/DATA_MODEL.md` and CAT-07 descriptive tables spec (checked 2026-11-27).

## Materials

1. **Related feature/entity:** `product_materials` references `materials.id`; its rows store `percentage` and `is_primary`.
2. **Create/select from this flow:** No product composition editing from this screen. Materials are maintained here; product composition selection is a separate catalog/product flow.
3. **Navigation:** Independent `/catalog/materials` route, registered in `MaterialsRoutes`, `route_registry`, `app_go_router`, and the Catalog Hub.
4. **Shared contract/Core:** No new Core capability or cross-feature import. Existing `CrudListScreen`, `CrudListConfig`, `PagedListCubit`, `IApiClient`, `CrudEditorDialog`, and AppKey registry are reused.
5. **Permissions/RLS:** Reads follow table RLS (read true); writes require `masterdata.manage`. The related `product_materials` table is written under `catalog.manage`; this screen does not write it.
6. **Validation/uniqueness:** `name` required ≤100, `code` required ≤50, unique `code`; optional `material_type` is restricted to natural/synthetic/blended. `23505` maps to duplicate; `23503` maps to in-use delete.
7. **Search/filter/sort/aggregation:** Server search on name/code; status and material type filters; server sort on name/code/status with stable id tie-breaker; no aggregate/statistics endpoint required.
8. **Lifecycle:** `is_active` defaults true. Inactive records are retained and should not be offered for new product composition. Delete remains guarded by FK; used records must be deactivated instead.
9. **Backend/API/RPC/Storage:** Existing `/rest/v1/materials` table and RLS are sufficient; no migration, RPC, Storage bucket, or new package required. Update PATCH omits `is_active` unless the editor value changed.
10. **Tests/docs/migration risk:** Query/model tests added. Repository/API, Cubit, Widget, responsive matrix and live Supabase tests remain workspace verification. No migration risk identified from the current schema snapshot.

## Fabric Types

1. **Related feature/entity:** `product_fabrics` references `fabric_types.id`; product-fabric rows include `is_primary` and `notes`.
2. **Create/select from this flow:** No product fabric assignment from this screen; assignments remain in product workflows.
3. **Navigation:** Independent `/catalog/fabric-types` route, registered in `FabricTypesRoutes`, `route_registry`, `app_go_router`, and the Catalog Hub.
4. **Shared contract/Core:** No new Core capability or cross-feature import; existing CRUD and network infrastructure is reused.
5. **Permissions/RLS:** Reads follow table RLS (read true); writes require `masterdata.manage`. Related `product_fabrics` writes use `catalog.manage`; this feature does not write those rows.
6. **Validation/uniqueness:** `name` required ≤100, `code` required ≤50, unique `code`; optional category restricted to knit/woven/fleece. `is_named_fabric` is retained with default false but not exposed because CAT-07 D-DT-3 says its semantics are undefined and must not be shown.
7. **Search/filter/sort/aggregation:** Server search on name/code; status and category filters; server sort on name/code/status with stable id tie-breaker; no aggregate/statistics endpoint required.
8. **Lifecycle:** `is_active` defaults true. Inactive records are retained and should not be offered for new product fabric assignment. FK rejection on delete maps to an in-use/deactivate message.
9. **Backend/API/RPC/Storage:** Existing `/rest/v1/fabric_types` table and RLS are sufficient; no migration, RPC, Storage bucket, or new package required. Update PATCH omits `is_active` unless changed and preserves `is_named_fabric`.
10. **Tests/docs/migration risk:** Query/model tests added. Repository/API, Cubit, Widget, responsive matrix and live Supabase tests remain workspace verification. No migration risk identified from current schema snapshot.

## Shared conclusions

- No migration, RPC, View, Storage change, or new dependency is requested by this implementation.
- Product assignment tables are separate features; the feature-import rule prohibits importing their UI/Cubit/data. Only the FK lifecycle contract is handled here.
- The backend RLS remains authoritative; UI permission gates are presentation only.
