# CAT-07 — Genders reference feature

## Purpose
The Genders reference table supplies the gender dimension referenced by size groups. It is implemented as a standalone Catalog feature at `/catalog/genders`, using the shared CRUD list and editor infrastructure.

## Data contract
- `id`: server-generated primary key.
- `name`: required, trimmed, maximum 50 characters.
- `code`: required, trimmed, maximum 30 characters; unique in the database.
- `sort_order`: non-negative integer used for stable presentation ordering.
- `is_active`: defaults to true. Status is changed through the dedicated status mutation or included in an edit PATCH only when changed.
- `size_groups`: relationship count is selected with the row. A missing/unknown count is treated as unsafe to delete.

## Lifecycle and deletion safety
1. Create and update validate the trimmed name, code, and non-negative order.
2. Duplicate database constraint errors are translated to the duplicate message.
3. A gender with one or more size groups cannot be deleted; the UI hides its delete action and recommends deactivation.
4. If relationship usage cannot be established, deletion is also blocked (fail closed).
5. The database foreign-key violation (Postgres 23503) is translated to the same in-use failure to handle races between list load and delete.
6. Deactivation preserves the record and all historical references.

## UI contract
- Arabic and English translations are registered through `GendersKeys`.
- The feature is discoverable from the Catalog hub.
- The screen uses the shared CRUD list: search, status filters, sorting, paging, table/cards, bulk status actions, and access gating.
- The editor compares status to its initial value; unchanged status is omitted from PATCH.
- All visible UI copy is localized and fields use shared design-system widgets.

## Reuse notes
A follow-on reference-table feature should copy the layering and registration pattern, not duplicate the CRUD engine: typed entity/draft/query, datasource, repository, use cases, Cubits, a compact `CrudListConfig`, a `CrudEditorDialog`, localization, DI, route registry, hub card, and tests. Preserve fail-closed delete policy whenever another table references the record.
