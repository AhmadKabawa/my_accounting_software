# Colors — integration impact

Feature: Catalog / Colors  
DATA_MODEL/API source: `docs/backend/DATA_MODEL.md` (2026-11-15), `docs/backend/BACKEND_REQUESTS.md`, ADR-0004, Core map/usage.

## Ten integration checks

1. **Related feature/entity:** Products use a product-level color composition. `product_colors` belongs to `products`; `product_color_components.color_id` references `colors.id`. The documented schema has no `products.color_id`.
2. **Create/select from this flow:** Color management creates and edits reference colors. The future product editor may select existing colors. Creating a new color from the product flow remains a proposal in [ADR-0007](../../architecture/ADR/0007-feature-integration-contracts.md); do not implement a cross-feature contract until that ADR is accepted. This task does not build the Products feature or its integration.
3. **Navigation route:** No new route is required in this Colors task. Product-editor navigation is not in scope.
4. **Shared contract/Core capability:** The future product editor should use Core `SearchableDropdown` and `AppColorSwatch`. `onAddNew` may be used only if the create-from-product flow is approved under the proposed ADR-0007. No feature-to-feature import is allowed under ADR-0004; no Colors Cubit/page/data import into Products.
5. **Permissions/RLS:** Colors are readable under the documented open read policy; writes require `masterdata.manage`. Product composition writes require `catalog.manage`. The server/RLS enforces both; hiding controls is not authorization.
6. **Validation/uniqueness:** `colors.code` is UNIQUE. `hex_code` is nullable and accepts `#RRGGBB` or `#RRGGBBAA`. Component rows reference `colors.id`; do not invent a direct product FK.
7. **Search/filter/sort/aggregation:** Colors search by name/code/HEX and filter by active state. Product counts and usage aggregation must be server-side. **NOT_VERIFIED:** live embedded relation/RLS behavior is not verified; see B-20–B-22.
8. **Lifecycle:** A used color is protected from deletion by the component FK (SQLSTATE `23503`). Deactivation preserves the reference and should be the user-facing alternative. Inactive colors should not be offered for new product composition selections; historical records remain readable.
9. **Backend/API/RPC:** B-20 requests `color_stats`; B-21 requests an index on `product_color_components(color_id)`; B-22 requests product counts/list aggregation; B-23 asks about `created_at`; B-24 asks for a stable delete-used error contract. No SQL or Supabase write is part of this frontend branch.
10. **Tests/docs/migration risks:** Cover component mapping, FK delete rejection, status lifecycle, future product selection contract, and server aggregation/RLS. This task does not add migrations, product fields, product screens, or feature-to-feature imports.

## Explicit scope boundary

**No Products feature implementation or integration is required in this branch.** The current work only documents the future contract. The future product screen must select colors through `product_color_components`, not through a nonexistent `products.color_id`; it should consume Core UI capabilities rather than import the Colors feature. Creation from the product screen is still proposed, not an approved implementation contract (ADR-0007).
