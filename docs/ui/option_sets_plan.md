# CAT-08 Option Sets — UI plan

- Screen: `/catalog/option-sets`; `CrudListScreen` + feature-owned config; write permission `Permissions.masterData.manage`.
- List: server search by name/code, status filter, stable name/id order; columns name+code, selection type, options count, linked attributes count, status.
- Stats: server total/active/inactive; no local-page aggregates.
- Details: desktop `AppDetailsPanel`, narrow `BottomSheet`; fetch option rows only after opening a set; order `sort_order,name,id`.
- Option editor: name ≤100, code ≤50, numeric non-negative sort_order, active=true on create; create/update/deactivate only; never delete options.
- Group editor: name ≤100, code ≤50, single/multiple; selection type locked when attributes or product-type links are positive/unknown.
- Delete group only when option count, attribute count and product-type link count are known zero; 23503 offers deactivate.
- Capabilities: no bulk, no duplicate. Trimmed dirty guard and `AppValidator`; status sent on create and only-if-changed PATCH.
- Tests: model/count parsing; query/body/error mapping; lazy options fetch and sort; duplicate option code scoped to group; Cubit stale request/debounce; responsive panel/sheet matrix.