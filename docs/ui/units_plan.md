# CAT-08 Units — UI plan

- Screen: `/catalog/units`; `CrudListScreen` + `unitsListConfig`; read access open, write permission `Permissions.masterData.manage`.
- Query: server pagination, escaped search over `name`/`symbol`, status and `unit_type` filters, stable `name,id` ordering, 300 ms debounce.
- Columns/cards: name + symbol with symbol direction detected from its text, translated unit type, usage count (`product_variants` + `attributes`), status, `updated_at`.
- Stats: server counts for total/active/inactive; tapping applies status; stats errors do not block list.
- Editor: name ≤100, symbol ≤20, four-value translated type select; `AppValidator`; trimmed dirty check; active=true on create, PATCH status only if changed.
- Capabilities: no details, no bulk, no duplicate, no seed. Hide delete unless both usage counts are known zero; on FK 23503 offer deactivate.
- Explicit omission: no `base_unit_id` or `conversion_factor` in UI, projection, POST or PATCH.
- Tests: model/repository fake-client request and body tests; Cubit latest-request/debounce/empty/error/mutation tests; 360/600/900/1200 RTL/LTR light/dark screen matrix.