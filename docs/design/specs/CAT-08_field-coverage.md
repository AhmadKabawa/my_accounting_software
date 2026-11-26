# CAT-08 — Field coverage

> Basis: CAT-07_units.md, CAT-07_attributes_options.md, and the current DATA_MODEL.md. These specifications remain drafts; unresolved backend semantics are not silently promoted to confirmed behavior.

## Units

| Field | Type / constraint | Add | Edit | List / detail | Search / filter / sort | Related feature / decision |
|---|---|---|---|---|---|---|
| id | integer PK | generated | immutable | internal | none | referenced by product variants and attributes |
| updated_at | timestamptz (`+std`) | server managed | server managed | last-updated column | sort/display only | use the shared date/time renderer; never client-derived |
| name | varchar(100), required | required | editable | primary | search; sort name | non-unique |
| symbol | varchar(20), required, unique | required | editable | primary beside name | search | duplicate maps to 23505 |
| unit_type | varchar(30), CHECK weight/length/volume/piece | required select | editable select | translated | filter by type | fixed four-value domain |
| is_active | boolean | server default | status action | status | status filter | inactive units excluded from new selections |
| base_unit_id | self FK, nullable | omitted | omitted | hidden | none | decision-26: no conversion UI |
| conversion_factor | numeric, default 1, positive | omitted | omitted | hidden | none | decision-26: no conversion UI |

Usage counts: product_variants and attributes. If usage is unknown, deletion must be blocked; if used, hide delete and offer deactivate. No local-page-derived aggregate statistics.

## Option sets

| Field | Type / constraint | Add | Edit | List / detail | Search / filter / sort | Related feature / decision |
|---|---|---|---|---|---|---|
| id | integer PK | generated | immutable | internal | none | referenced by attributes and product type links |
| name | varchar(100), required | required | editable | primary | search; sort name | |
| code | varchar(50), required, unique | required | editable | primary | search | duplicate maps to 23505 |
| selection_type | single/multiple, default single | required select | editable only before use | primary | filter if needed | lock after first use (D-AT-3) |
| is_active | boolean | server default | status action | status | status filter | |
| options | related rows | nested editor | nested editor | count and detail list | name/code search; sort sort_order then name | options loaded only when set opens |
| option.id | integer PK | generated | immutable | internal | none | |
| option.option_set_id | FK required | parent context | immutable | parent context | none | |
| option.name | varchar(100), required | required | editable | primary | search | |
| option.code | varchar(50), required | required | editable | primary | search | unique within option_set_id |
| option.sort_order | integer | default/assigned order | editable | visible order | sort ascending | |
| option.is_active | boolean | server default | status action | status | active options for new assignment | |

Group usage count comes from product_type_option_sets. Do not expose delete when options exist or usage exists. Option deletion is intentionally not exposed until a safe usage contract is verified. Unknown usage blocks destructive actions.

## Attributes

| Field | Type / constraint | Add | Edit | List / detail | Search / filter / sort | Related feature / decision |
|---|---|---|---|---|---|---|
| id | integer PK | generated | immutable | internal | none | |
| name | varchar(150), required | required | editable | primary | search; sort name | |
| code | varchar(80), required, unique | required | editable | primary | search | duplicate maps to 23505 |
| data_type | CHECK text/number/boolean/date/json/option | required select | lock after use | translated | filter by type | |
| unit_id | nullable FK units | optional; relevant to number | editable | secondary label | no | show picker only for number |
| option_set_id | nullable FK option_sets | required iff data_type=option | conditional | secondary label | no | clear when type changes away from option |
| is_filterable | boolean default false | toggle | editable | indicator | filter true/false | |
| is_active | boolean | server default | status action | status | status filter | ERP27 may reject new assignments when inactive |
| is_required | boolean | omitted | omitted | hidden | none | D-AT-1 unresolved in source; requiredness belongs to product type mapping |
| is_variant_option | boolean | omitted | omitted | hidden | none | D-AT-2 unresolved |

Attribute usage count comes from product_type_attributes. Do not delete when used; block data_type changes after use (D-AT-3). Do not infer usage from currently loaded list rows.

## Explicit exclusions

- No unit conversion fields or conversion behavior.
- No product-type attribute assignment workflow (later stage).
- No product value entry workflow (product feature).
- No is_required or is_variant_option editor controls until their semantics are decided.
- No statistics computed from the current page; aggregate statistics must be server-derived.
