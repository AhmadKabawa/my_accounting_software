# CAT-07 — Field coverage: Materials and Fabric Types

DATA_MODEL source: `docs/backend/DATA_MODEL.md` on `integration/catalog-scope-1` (schema snapshot checked 2026-11-27). Standard `+std` fields are included below.

## Materials — `materials`

| field | type | required | default | create | edit | list | search/filter/sort | statistics | related feature/entity | display decision & reason |
|---|---|---|---|---|---|---|---|---|---|---|
| id | bigint identity PK | generated | identity | no | no | row identity only | no | no | product_materials.material_id | Never show internal database ID |
| name | varchar(100) | yes | — | yes | yes | primary | search; sort | none | product_materials | Display as record identity |
| code | varchar(50) | yes | — | yes | yes | primary, LTR | search; sort | none | product_materials | Display as stable human code; unique constraint |
| material_type | varchar(20), enum natural/synthetic/blended | no | null | yes | yes | secondary | filter | none | product_materials | Display localized value; null shown as Not specified |
| description | text | no | null | yes | yes | no | no | none | — | Editor only; secondary detail not required in compact list |
| is_active | boolean | no | true | yes | yes | status | filter; sort | none | new product selection | Show status; create/edit toggle; independent activate/deactivate action |
| updated_at | timestamptz (+std) | no | now() | system | system | no | no | none | sync/audit infrastructure | System metadata; not user-editable |
| uuid | uuid (+std) | yes | gen_random_uuid() | system | immutable | no | no | none | sync infrastructure | Technical sync identity; hidden |
| origin_node_id | bigint (+std) | yes | 1 | system | immutable | no | no | none | sync_nodes | Technical sync metadata; hidden |

## Fabric Types — `fabric_types`

| field | type | required | default | create | edit | list | search/filter/sort | statistics | related feature/entity | display decision & reason |
|---|---|---|---|---|---|---|---|---|---|---|
| id | bigint identity PK | generated | identity | no | no | row identity only | no | none | product_fabrics.fabric_type_id | Never show internal database ID |
| name | varchar(100) | yes | — | yes | yes | primary | search; sort | none | product_fabrics | Display as record identity |
| code | varchar(50) | yes | — | yes | yes | primary, LTR | search; sort | none | product_fabrics | Display as stable human code; unique constraint |
| fabric_category | varchar(30), enum knit/woven/fleece | no | null | yes | yes | secondary | filter | none | product_fabrics | Display localized value; null shown as Not specified |
| is_named_fabric | boolean | no | false | preserve default/existing value | preserve existing value | no | no | none | product_fabrics | **Not exposed in UI** per CAT-07 D-DT-3; semantics are undocumented. Kept in model/draft/JSON and preserved on edit |
| description | text | no | null | yes | yes | no | no | none | — | Editor only; secondary detail not required in compact list |
| is_active | boolean | no | true | yes | yes | status | filter; sort | none | new product selection | Show status; create/edit toggle; independent activate/deactivate action |
| updated_at | timestamptz (+std) | no | now() | system | system | no | no | none | sync/audit infrastructure | System metadata; not user-editable |
| uuid | uuid (+std) | yes | gen_random_uuid() | system | immutable | no | no | none | sync infrastructure | Technical sync identity; hidden |
| origin_node_id | bigint (+std) | yes | 1 | system | immutable | no | no | none | sync_nodes | Technical sync metadata; hidden |

## Shared decisions

- Both tables have a unique constraint on `code`; SQLSTATE `23505` is translated to a localized duplicate-code failure.
- SQLSTATE `23503` on delete is translated to “record is in use; deactivate it instead”.
- Search and filters are server-side; ordering is server-side with stable `id` tie-breaker.
- No statistics are shown: these list specifications do not require a separate aggregate and page-local counts would be misleading.
