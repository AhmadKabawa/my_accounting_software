# CAT-08 Attributes — UI plan

## Implementation status — 2026-11-26

Status: implementation is present on `feat/cat08-attributes-screen`; do not merge until the latest CI and live/manual acceptance checks are complete.

- Implemented: Domain-owned lookup choice models; Attributes-owned unit/option-set reads; paged list Cubit; independent server-statistics Cubit; lookup and form Cubits; list screen/config; editor and lookup widgets; duplicate flow; usage locks; 23503 deactivate fallback; translated business-error mapping.
- Implemented: GoRoute, Catalog hub card, sidebar destination, DI registrations and sidebar assertions. `attributes_list_config.dart` is below 250 lines; the page delegates layout to `CrudListScreen`.
- Tests added: repository query/body/count/error tests; model usage-count tests; Cubit debounce/race/page-reset/delete-guard tests; lookup-failure isolation; editor trim/type-change/lock/duplicate/option-set-required tests; 360/600/900/1200 × RTL/LTR × light/dark screen matrix with statistics-failure isolation; Core deferred-panel regression test.
- Shared Core adjustment: optional `SearchableDropdown.deferPanelRefresh`, default `false` to preserve existing behavior. Attributes opts in for editor/filter dropdowns to avoid overlay refresh during an ancestor form rebuild.
- CI: run 45929138726 passed Auto-format and Analyze; 20 tests failed. One failure was a CAT-08 editor test selecting the untranslated test label `Option` rather than the actual localized label `Option set`; fixed in commit `05cea81`. The other 19 failures were outside this scope (Categories, Product Types and the pre-existing Size Systems key-registry/UI gates).
- Run 45929612854 (head `3547cc7`): Auto-format and Analyze passed; its test job was still running at last check and predates the selector correction.
- Run 45929784410 (head `05cea81`): queued at last check; this is the verification run for the selector correction.
- Live Supabase: unverified. Confirm PostgREST relationships for `product_type_attributes(count)` and `product_attribute_values(count)`, plus `Content-Range` count behavior for all four statistics.
- Chrome: unverified. Manually inspect 360 and 1200 px, RTL/LTR and light/dark, especially editor selectors, duplicate of used/inactive records, row actions and the FK 23503 fallback.
- Backend: no new RPC/View/endpoint is currently requested. The implementation uses existing REST tables and PostgREST embedded counts; request a backend view/RPC only if live schema/policies cannot supply those counts reliably.

