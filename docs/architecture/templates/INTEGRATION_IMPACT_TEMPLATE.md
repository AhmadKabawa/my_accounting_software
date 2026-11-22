# Integration impact — template

Feature: 
DATA_MODEL/API source: 

Answer these ten impact checks before implementation:
1. Which related feature/entity is involved?
2. Can the user create/select it from this flow?
3. Is a navigation route needed?
4. Is a shared contract/Core capability needed?
5. Does it affect permissions or RLS?
6. Does it affect validation or uniqueness?
7. Does it affect search/filter/sort or server aggregation?
8. Does it affect lifecycle (delete/archive/disable/return)?
9. Does it require backend/API/RPC/Storage work?
10. What tests, docs, and migration risks follow?

If no integration is needed, explicitly record **«لا يوجد Integration مطلوب»** and explain why for each relevant check.

Backend work must be recorded in docs/backend/BACKEND_REQUESTS.md; isolate data-source switching in one place.