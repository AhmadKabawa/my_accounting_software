# Age groups — field coverage

Source of truth: `docs/backend/DATA_MODEL.md`, §8 `age_groups` and `product_age_groups`.

| Field | Database contract | Create | Edit | List |
|---|---|---|---|---|
| id | bigint identity PK | generated | immutable | internal |
| name | varchar(100), NOT NULL, UNIQUE | required | editable | primary; searchable |
| min_age | integer, nullable | optional | editable | secondary |
| max_age | integer, nullable | optional | editable | secondary |
| is_active | boolean, default true | defaults true | changed-only PATCH/status action | status |
| sort_order | integer, default 0 | defaults 0 | editable | secondary; sort |

- `age_groups_check` permits either bound to be null; when both are set, `min_age <= max_age`.
- Editor validates the range; PostgreSQL SQLSTATE `23514` maps to localized range failure.
- Duplicate name maps from `23505`; `product_age_groups(count)` determines usage.
- Unknown usage blocks delete. Positive usage hides delete and offers deactivation. A concurrent FK conflict `23503` maps to the same in-use failure.
- Small reference table: bulk actions disabled. Read access follows catalog open-read policy; writes require `masterdata.manage`.
- No migration: the table and constraints already exist in the documented schema.
