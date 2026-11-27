# CAT-08 Attributes — UI plan

## Implementation status — 2026-11-26

Status: presentation implementation is present on `feat/cat08-attributes-screen`; it is not merge-ready until CI, live Supabase and browser checks are complete.

- Implemented: Domain-owned lookup choice models; Attributes-owned unit/option-set reads; paged list Cubit; independent server-statistics Cubit; list screen/config; editor and lookup widgets; duplicate flow; usage locks; 23503 deactivate fallback; translated business-error mapping.
- Implemented: router page, Catalog hub card, sidebar destination, DI registrations and sidebar assertions. The list config remains below the 250-line limit; the page delegates layout to `CrudListScreen`.
- Tests added (not yet claimed passing): repository query/body/count/error tests; model usage-count tests; Cubit debounce/race/page-reset/delete-guard tests; editor trim/lock/type-change/duplicate/option-set-required tests; 360/600/900/1200 × RTL/LTR × light/dark screen matrix with stats-failure isolation.
- CI: run 45927564334 had Auto-format and Analyze successful; its full test job was still running at last check. Run 45927763102 for the then-current head was queued. No green full-suite result is claimed.
- Live Supabase: unverified. Confirm the PostgREST relationships used by `product_type_attributes(count)` and `product_attribute_values(count)`, plus `Content-Range` count behavior for all four statistics.
- Chrome: unverified. Manually inspect 360 and 1200 px, RTL/LTR and light/dark, especially editor selectors, duplicate of used/inactive records, row actions and the FK 23503 fallback.
- Backend: no new RPC/View/endpoint is currently requested. The implementation uses existing REST tables and PostgREST embedded counts; request a backend view/RPC only if live schema/policies cannot supply those counts reliably.

- Screen: `/catalog/attributes`; `CrudListScreen` + feature-owned config; write permission `Permissions.masterData.manage`.
- List: server search by name/code; status, data type and filterable filters; stable name/id order; columns name+code, translated type, unit or option-set label, filterable state, linked product-type count, status.
- Stats: server total/active/inactive/filterable; stats errors do not block list.
- Editor: name ≤150, code ≤80, six translated data types, optional unit for number, required option set for option, filterable and active. `is_required`/`is_variant_option` stay hidden.
- Invariant: option_set_id is non-null iff data_type=option. Changing type clears unit_id and option_set_id. Unit and option-set lookup reads belong to Attributes; active choices for new assignments and current inactive choice retained during edit.
- Lock data_type and option_set_id when product_type_attributes or product_attribute_values count is positive/unknown; hide delete when used/unknown; FK 23503 offers deactivate.
- Duplicate=true, bulk=false, no details panel. Duplicate copies type/unit/set/filterable, resets active, and generates unique `-copy` code within 80 chars.
- Deactivation confirmation warns that ERP27 rejects new values; map ERP27/ERP28/23514/23505 to translated failure keys.
- Tests: model/count/lookup parsing; repository body/query/error and invariant tests; Cubit duplicate seed, filters, race/debounce and status; responsive RTL/LTR light/dark matrix.