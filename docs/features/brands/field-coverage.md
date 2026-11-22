# Field coverage — CAT-07 Brands

Feature: catalog/brands  
DATA_MODEL source/version: docs/backend/DATA_MODEL.md، snapshot 2026-11-15.

| field | type | required | default | create | edit | list | search/filter/sort | statistics | related feature/entity | display decision & reason |
|---|---|---|---|---|---|---|---|---|---|---|
| id | bigint identity | yes/generated | identity | no | no | no | internal row key | no | products.brand_id, price_rules.brand_id, discount_targets | hidden technical identifier |
| name | varchar(150) | yes | none | yes | yes | yes | search ilike; sort asc/desc | no | brands | primary label; unique |
| slug | varchar(150) | yes | none | yes | yes | secondary | search ilike | no | brands | stable secondary identity; unique |
| logo | varchar(500), URL | no | null | yes | yes | visual logo | no | no | Storage | show image; upload or HTTP(S) URL |
| description | text | no | null | yes | yes | secondary | no | no | brands | explanatory content; not a filter |
| is_active | boolean | no | true | default | separate toggle | status badge | status filter | active/inactive | brands | lifecycle state; not an editor field |
| updated_at | timestamptz (+std) | system | trigger | no | no | no | no | no | update lifecycle | hidden technical timestamp |
| uuid | uuid (+std sync) | system | generated | no | no | no | no | no | synchronization | hidden synchronization identity |
| origin_node_id | bigint (+std sync) | system | configured node | no | no | no | no | no | sync_nodes | hidden synchronization provenance |
| created_at | absent | n/a | n/a | unavailable | unavailable | unavailable | unavailable | unavailable | brands | do not infer from updated_at; defer «المضافة حديثاً» to B-11 |
| product_count | derived, not brands column | products(count) in the existing brands list request | n/a | n/a | n/a | existing table column and BrandProductsBadge restored from vscode | filter hidden while live count semantics are NOT_VERIFIED | with/without products cards hidden while NOT_VERIFIED | products.brand_id → brands.id | pre-existing derived count source; never load product rows or infer from current page |

## Decisions and gaps
- All persisted brands fields are covered. id, updated_at, uuid and origin_node_id are system fields and remain hidden.
- name, slug, logo and description are create/edit fields. is_active remains a separate toggle. System fields are never sent in write payloads.
- Search covers name and slug; status filter covers is_active. There is no sort_order in DATA_MODEL, so no manual ordering.
- created_at does not exist. Do not synthesize it from updated_at; defer «المضافة حديثاً» until B-11 is implemented and confirmed.
- product_count is derived from the pre-existing products(count) request. The table column and BrandProductsBadge are existing behavior restored from vscode; lack of live PostgREST/RLS verification (NOT_VERIFIED) is not grounds to remove them. New with/without-product filters and statistic cards remain hidden until their count requests are verified. B-10/B-12/B-13 record backend work.
- price_rules.brand_id and discount_targets(target_type='brand') are integration references only; no pricing navigation or behavior is added.
- No SQL, migration, or Supabase write is performed.
