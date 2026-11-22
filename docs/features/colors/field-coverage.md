# Colors — field coverage

Feature: Catalog / Colors  
DATA_MODEL source/version: `docs/backend/DATA_MODEL.md`, extracted from Supabase on 2026-11-15.

| field | type | required | default | create | edit | list | search/filter/sort | statistics | related feature/entity | display decision & reason |
|---|---|---|---|---|---|---|---|---|---|---|
| `id` | bigint identity PK | generated | identity | no | no | no | internal identity only | no | product_color_components FK | Keep internal; never ask the user to enter it. |
| `name` | varchar(100) | yes | none | yes | yes | yes | search; name sort | no | product color composition | Main human-readable color name. |
| `code` | varchar(50) UNIQUE | yes | none | yes | yes | yes | search; code sort | no | API/business reference | User-managed stable short code; uniqueness is enforced by the database. |
| `hex_code` | varchar(9), nullable | no | null | yes | yes | swatch + HEX text/copy | search | no | AppColorSwatch / AppColorPicker | Accepts `#RRGGBB` or `#RRGGBBAA`; preserve alpha when editing an existing 8-digit value. |
| `is_active` | boolean | no | true | default | toggle | status label | status filter | active/inactive counts | product color selection | Inactive colors remain in historical product compositions but should not be offered for new selections. |
| `sort_order` | integer | no | 0 | yes | yes | not a primary column | default ordering, then name | no | catalog ordering | Keep editable in the form and use for default list order; avoid exposing it as a prominent column. |
| `updated_at` | timestamptz (standard sync column) | generated | now()/trigger | no | no | no | no | no | synchronization/audit | Technical metadata; not needed for the color-management workflow. |
| `uuid` | uuid (standard sync column) | generated | gen_random_uuid() | no | no | no | no | no | synchronization | Technical identity; not a user-editable field. |
| `origin_node_id` | bigint (standard sync column) | generated | 1 | no | no | no | no | no | sync_nodes | Technical synchronization metadata; not user-facing. |
| `created_at` | absent from DATA_MODEL | n/a | n/a | n/a | n/a | no | no | no | none | Do not implement “recently added” or infer creation time. Backend request B-23 asks whether this field should exist. |

## Coverage decisions

- The editor covers the user-managed fields: name, code, optional HEX, and sort order.
- List search is server-side across `name`, `code`, and `hex_code`; status is a server-side filter.
- Default ordering is `sort_order` ascending with name as a stable tie-breaker. Explicit sorting is available for name and code.
- The HEX swatch is a visual aid, not the sole representation: show the color name and HEX value, with a copy action.
- The table does not have a `products.color_id` field. Product usage is represented through `product_colors` → `product_color_components.color_id`.
- **NOT_VERIFIED:** Do not show product usage, used/unused statistics, or a product-presence filter until the embedded PostgREST relation/count is verified against live RLS. Track backend support in B-20–B-22.
- A color referenced by `product_color_components` cannot be deleted because of the FK. The UI should prefer deactivation; map SQLSTATE `23503` to a translated user-facing message.
- Read access is open in the documented RLS policy; writes require `masterdata.manage`. UI permission checks are presentation only; RLS remains authoritative.
