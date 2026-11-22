# CAT-07 — Brands enrichment: screen UI/UX specification

> Status: implementation specification based on the existing CAT-07 contract and brands DATA_MODEL snapshot 2026-11-15. Live PostgREST embedded-count behavior is NOT_VERIFIED until checked against Supabase.

## 1. Screen information
- Code/name: CAT-07 / Brands.
- Unit: Catalog / Brands; existing /catalog/brands route.
- Platform: Flutter web responsive; preserve mobile/tablet/desktop.
- This is a coherent work unit for brand master-data lifecycle and its direct product relation.

## 2. Goal and outcome
- Manage brand identity/status, understand product coverage, and filter the list.
- Acceptance: server-derived counts, independently refreshable from paginated list, clickable stats filters, stable panel filters in RTL/LTR and light/dark.

## 3. Sources of truth
- Existing screen decisions: docs/design/specs/CAT-07_brands.md.
- Data model: docs/backend/DATA_MODEL.md (2026-11-15).
- Backend requests: docs/backend/BACKEND_REQUESTS.md.
- Feature integration: ADR-0007; cross-feature import restriction: ADR-0004.
- Core: CORE_MAP.md, CORE_USAGE.md, DESIGN_SYSTEM.md.
- Unknown: live PostgREST embedded count and exact RLS-visible product totals.

## 4. Users and permissions
- Read: authenticated users, subject to RLS.
- Create/update/toggle/delete: masterdata.manage; server RLS remains authoritative.
- UI permission gates are usability only, not authorization.

## 5. Main scenarios
- Search by name/slug and filter by active state. The existing products(count) field remains the source for the pre-existing product-count column and badge; live PostgREST/RLS behavior is NOT_VERIFIED. Product-presence filtering and with/without-products cards remain hidden until their count queries are verified.
- Click a statistics card to apply its corresponding filter and show a chip; visually select the card matching the current filter.
- Create/update/delete/toggle; refresh stats after each successful mutation.
- Stats failure must not block list loading; list failure must not hide stats.

## 6. Data and sources
| Data | Source | Fields/relation | RLS | Reason |
|---|---|---|---|---|
| Brand list | public.brands | id,name,slug,logo,description,is_active,products(count) | authenticated read | list and product count |
| Stats | brand_stats RPC (future) | total,active,inactive,with_products,without_products, optional most_used_brand | SECURITY INVOKER | server aggregation |
| Product relation | public.products | products.brand_id → brands.id | product RLS | count only; never fetch rows |

Current stats fallback reads total and active using two count requests; inactive = total - active. The existing list request already includes products(count), which remains the source for the existing product-count column and mobile badge; it is not a newly introduced count source. Live PostgREST relation-count semantics and RLS visibility are NOT_VERIFIED. Do not hide the pre-existing column/badge solely because live verification is unavailable. Product-presence filters and with/without-products cards remain hidden until their separate count requests are verified; B-10 remains the target aggregate RPC.

## 7. Information displayed
| Element | Priority | Source | Placement | Reason |
|---|---|---|---|---|
| Brand name and slug | primary | brands | table/mobile card | identify row |
| Logo | primary | brands.logo | table/mobile card | visual identification |
| Status | primary | brands.is_active | table/mobile card | lifecycle |
| Description | secondary | brands.description | roomy layouts/details | supporting context |
| Product count | secondary | existing products(count) in brands list request | table/mobile card (existing behavior restored) | coverage; live PostgREST/RLS NOT_VERIFIED |
| Total/active/inactive | summary | count/RPC | clickable stats cards | overview |
| With/without products | summary | count requests via PostgREST embedded products relation, only after live verification; B-10 target | hidden while NOT_VERIFIED | identify coverage gaps |

Do not display id, uuid, origin_node_id, updated_at, or invented created_at.

## 8. Actions
| Action | Condition | Permission | API/effect | Reason |
|---|---|---|---|---|
| Create/edit | permitted user | masterdata.manage | POST/PATCH brands | maintain master data |
| Activate/deactivate | current status | masterdata.manage | PATCH is_active | separate lifecycle action |
| Delete | no linked products; FK final authority | masterdata.manage | DELETE brands | protect references |
| Stats-card click | verified metric | authenticated read | apply matching list filter | fast narrowing |

## 9. Components and rationale
- Reuse ListPageTemplate, AppDataTable, FilterBar, SearchableDropdown, AppCard/AppBadge, AppIcon and existing responsive card.
- Status/product filters use SearchableDropdown panel mode; options exclude all sentinel; null maps to all.
- No new Core component, dependency, cross-feature import, fake action, or Products navigation.

## 10. Search, filters, sort
- Search: name and slug; server ilike with escaped values; debounce only in BrandsListCubit.
- Status options: active/inactive; null means all; all is allOptionLabel, not an option.
- Product-presence filter (all/with products/without products): hidden while embedded-resource count semantics and RLS are NOT_VERIFIED. When verified, use PostgREST count requests with an embedded products relation filter; do not load product rows. B-10 is the target aggregate RPC, not a prerequisite to retain the existing product-count field.
- Chips represent active filters; clear-all resets search and both filters.
- Sort remains name only. created_at sort waits for B-11. Product-count sort waits for B-13 if unsupported by PostgREST.
- Counts never depend on loaded page.

## 11. Table and mobile list
- Preserve name/logo/slug, status, existing product-count column and mobile BrandProductsBadge, and existing row actions.
- Product count comes from the pre-existing products(count) request. Live PostgREST/RLS verification is NOT_VERIFIED; this is not a reason to remove the existing UI.
- Keep row actions as icon actions with tooltips; no placeholder buttons.
- No sort_order.

## 12. Forms
- Create/edit: name, slug, logo, description.
- Do not expose system fields or is_active in editor.
- is_active remains a separate toggle; name/slug uniqueness is server-enforced.
- Logo remains upload or HTTP(S) URL per existing contract.

## 13. States
- Initial/loading/content/error and empty/no-results remain distinct.
- Distinguish no brands and no filtered results with separate AppEmptyState content. The all-brands-have-no-products state remains hidden until the full product-count aggregate is verified.
- Stats loading/failure is independent; retain last successful stats on refresh failure.
- If relation counts are not verified, hide only new product-presence filters and with/without-products cards/chips; retain the pre-existing product-count column and badge sourced from products(count).

## 14. State transitions
- Keep existing route and list context.
- After successful create/update/delete/toggle, refresh stats independently of list refresh.
- Stats-card click updates filter and resets page to first.
- Clearing a filter removes its chip and restores all state.

## 15. Responsive
- 360: mobile cards and panel filters.
- 600: compact list/card transition per Core.
- 900: adapt table/filter controls to available width.
- 1200: full table and secondary columns.
- Use ScreenEngine/context.ui; no new breakpoints or magic numbers.

## 16. RTL/LTR
- Use existing BrandsKeys ar/en and directional layout.
- Panel dropdown label must update after selection/clearing in both directions.
- Keep slug and URL readable as LTR content within RTL.

## 17. Light/Dark
- Use context.ui theme and semantic colors only.
- AppIcon tone meanings follow DESIGN_SYSTEM.md.
- Verify panel, chips, cards and empty states in both themes.

## 18. Core and design system
- Reuse SearchableDropdown panel mode, FilterBar, AppIcon(tone:), AppBadge, AppCard, ListPageTemplate, AppEmptyState and tokens.
- No Core expansion requested.
- AppIconTone meanings are in DESIGN_SYSTEM.md; _knownDebt in icon_tone_test remains empty.

## 19. API
| Operation | Endpoint/query | Notes |
|---|---|---|
| List | GET /rest/v1/brands | products(count), server filters/search, pagination |
| Stats fallback | GET /rest/v1/brands + Prefer count | existing total and active requests |
| Stats target | POST /rest/v1/rpc/brand_stats | B-10; SECURITY INVOKER; one aggregate row |
| Create/update/toggle/delete | existing brands REST endpoints | preserve payload and RLS |

Live PostgREST and RLS verification is NOT_VERIFIED. Preserve the pre-existing products(count) display; do not expose new product-presence filters/cards or the all-without-products empty state until verified.

## 20. Open decisions and deferrals
- B-10: stats RPC with product counters and optional most_used_brand.
- B-11: created_at/backfill; «المضافة حديثاً» deferred.
- B-12: products(brand_id) index verification.
- B-13: optional list View/RPC for count sorting.
- Products navigation, Pricing, POS and Reports integration are future work under ADR-0007.

## 21. Implementation and tests
- Unit: independent stats/list state, mutation refresh, partial failure, mapping and malformed count cases.
- Widget: stats-card filtering, panel filters including null/all, label refresh, empty states and product-count visibility guard.
- Architecture: run test/architecture; do not alter _knownDebt.
- Commands: dart format --set-exit-if-changed ., flutter analyze --no-fatal-infos, flutter test. Report only actual results.
- Supabase live verification: NOT_VERIFIED; no SQL, migration, or Supabase write.
