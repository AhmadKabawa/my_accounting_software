# Integration impact — CAT-07 Brands enrichment

Feature: catalog/brands  
DATA_MODEL/API source: docs/backend/DATA_MODEL.md snapshot 2026-11-15; docs/backend/BACKEND_REQUESTS.md.

## 1. Related feature/entity
- Products: products.brand_id → brands.id. A Products feature does not currently exist in the app.
- Pricing: price_rules.brand_id and discount_targets(target_type='brand') already exist in schema.
- POS and reports may consume brand/product dimensions later; no implemented CAT-07 integration contract is evidenced.

## 2. Create/select from this flow
- Brands CRUD remains the only flow in scope.
- Do not add «عرض المنتجات», a Slot, placeholder action, or feature abstraction: Products does not exist.
- The existing product-count column and BrandProductsBadge continue to use the pre-existing products(count) request; live PostgREST/RLS behavior is NOT_VERIFIED but this does not justify removing existing UI. New product-presence filters and with/without-products cards remain hidden until verified.

## 3. Navigation
- No cross-feature navigation is added. Future Brands-to-Products navigation is designed when Products exists and follows ADR-0007. ADR-0004 permits importing another feature's routes for navigation only.

## 4. Shared contract/Core
- No Core capability is required for this feature-specific relation.
- Cross-feature communication is deferred to ADR-0007; no imports from Products, Pricing, POS, or Reports internals.

## 5. Permissions and RLS
- Brands read is open to authenticated users; writes require masterdata.manage.
- Product count must obey products RLS and must not leak rows hidden from the current user. Verify with accounts of differing access.
- Pricing remains governed by pricing.manage; this screen does not edit pricing.

## 6. Validation and uniqueness
- brands.name and brands.slug are unique.
- Deletion of a referenced brand is governed by the FK. UI may hide deletion when a verified product_count is positive; database remains authoritative.
- No pricing, POS, or report validation changes.

## 7. Search/filter/sort and aggregation
- Current search is name/slug; status maps to is_active. The matching total/active/inactive statistics card is visually selected for the current status filter.
- The existing product count remains sourced from products(count), without loading product rows. New product-presence filter (all/with/without) and with/without-products stats use PostgREST count requests with an embedded products relation, but stay hidden while live semantics/RLS are NOT_VERIFIED. B-10 asks for SECURITY INVOKER RPC; B-12 asks for products(brand_id) index; B-13 optionally supplies list View/RPC for count sorting.
- Never calculate counts from loaded page or download products into Flutter.

## 8. Lifecycle
- Disabling a brand does not delete it or cascade to products/pricing.
- Product and pricing references remain intact. Future archive/delete semantics require explicit domain policy.
- No POS/report lifecycle changes.

## 9. Backend/API/Storage
- B-10: extend B-03 with brand_stats totals and product counters, SECURITY INVOKER.
- B-11: add created_at and backfill before «newly added» UI.
- B-12: verify/add index products(brand_id).
- B-13: optional list View/RPC with product_count and server sorting if PostgREST cannot provide it.
- No SQL, migration, or Supabase write is performed by this task.

## 10. Tests, docs, migration risks
- Test independent list/stats state and partial failure.
- Test product counts obey RLS and are not derived from page data; live verification remains NOT_VERIFIED.
- Preserve feature-import architecture tests; no direct cross-feature import.
- Backend changes are owned by backend maintainer and must update DATA_MODEL.
