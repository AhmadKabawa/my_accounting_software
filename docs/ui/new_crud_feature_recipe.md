# New CRUD feature recipe

This recipe describes the shared structure for a new catalog CRUD feature. Follow the existing Brands and Colors implementations, and reuse the core components instead of rebuilding list behavior inside a feature.

## Recommended feature structure

```text
lib/app/features/catalog/<feature>/
  domain/
    entity/
      <feature>.dart
      <feature>_draft.dart
      <feature>_list_query.dart
    repository/
    usecase/
  data/
    datasource/
    repository/
  presentation/
    cubit/
      <feature>_list/
      <feature>_stats/
      <feature>_form/
    dialogs/
      <feature>_editor_dialog.dart
    localization/
      <feature>_keys.dart
    pages/
      <feature>_screen.dart
    sections/
      <feature>_table_section.dart
      <feature>_stats_section.dart
    widgets/
      <feature>_card.dart
      <feature>_status_badge.dart
      <feature>_filter_bar.dart
```

The exact folders depend on the feature. Keep feature-specific fields, labels, validation, data access and seed construction inside the feature. Shared list mechanics belong in `lib/app/core`.

## Reuse map

| Need | Main file / component to change | Can it truly be one file? |
|---|---|---|
| Change the number or meaning of statistics cards | `presentation/sections/<feature>_stats_section.dart` using `ListStatsBar` and `StatItem` | Usually yes, if the stats data already exists |
| Change add-button label, permission or destination | `presentation/pages/<feature>_screen.dart` using `ListAddAction` | The key still lives in the feature localization file |
| Add or remove a table column | `presentation/sections/<feature>_table_section.dart` | Usually yes when the domain field already exists |
| Change row actions | `presentation/sections/<feature>_table_section.dart` using `CrudRowActions` | Callback behavior may also require the screen or cubit |
| Add a bulk action | `presentation/cubit/<feature>_list/` plus the screen's `BulkActionBar` configuration | No: permission, confirmation, result reporting and use case may span files |
| Add duplicate behavior | `presentation/dialogs/<feature>_editor_dialog.dart` with a feature-specific seed function | No: the row action and localized duplicate labels also change |
| Change sort fields | `domain/entity/<feature>_list_query.dart` and the feature toolbar configuration | No: remote query ordering must support the same fields |
| Change pagination behavior | `domain/entity/<feature>_list_query.dart` and the list cubit/data query | No: query, fetch and paging contract must agree |
| Enable row selection | `presentation/pages/<feature>_screen.dart` and `presentation/sections/<feature>_table_section.dart` using the cubit's `selection` | No: permission gating and data-view callbacks must be connected |
| Change status display | `presentation/sections/<feature>_table_section.dart` using `crudStatusColumn` | Usually yes if status already exists |
| Make status available in every view | `presentation/sections/<feature>_table_section.dart` using `CrudRowActions` | Usually yes if the status use case exists |
| Change filter controls | `presentation/widgets/<feature>_filter_bar.dart` or `ListToolbarConfig` | Query fields and localization keys may also change |

**Known weakness:** CRUD changes are not universally one-file changes. A new domain field, sort key, bulk mutation or duplicate mode often crosses the query/entity, data source/use case, cubit, screen, table section and localization. The table above identifies the primary feature file, not a promise that all related code is isolated there.

## Implementation checklist

1. Read the repository's `AGENTS.md` and `CLAUDE.md`; follow the feature-first and Clean Architecture conventions already present.
2. Define the entity and draft in `domain/entity`. Keep validation and feature rules out of core.
3. Define the list query as a `PagedQuery`: search, page, page size, active-filter detection, clear behavior and sort criteria.
4. Implement repository/data-source access and use cases. Ensure server-side sort and paging match the query contract.
5. Implement the list Cubit by extending `PagedListCubit`. Use its shared load, search debounce, page, refresh, delete, mutation effects, selection reset and `runBulk` behavior.
6. Implement the stats Cubit and expose the feature's statistics as `StatItem` values. A card with a filter applies it; a card without a filter is informational only.
7. Implement the form Cubit and editor dialog. For duplicate mode, create a feature-specific seed: generate new unique values, copy safe non-unique fields, and do not save until the user confirms.
8. Implement the feature's filter/sort configuration using `FilterBar` and `ListToolbarConfig`. Keep every user-facing label in `AppKey` translations.
9. Implement the table/data section with `AppDataView`, `CrudEmptyState`, `crudStatusColumn` and `CrudRowActions`. Supply the same row ID for table, card and grid selection.
10. Connect the page with `ListPageTemplate` using `toolbar`, `stats`, `addAction` and `count`. Use `ViewModeCubit` for table/cards/grid.
11. Keep selection mode off by default. Set ListToolbarConfig.selectionModeActive from the feature's PagedListCubit and provide onSelectionModeToggle only when the feature's bulk permission is granted. Pass selectionModeActive and an exit callback to CrudSelectionScope. Selection IDs and checkboxes are passed to AppDataView only while permission and selection mode are both active. Exiting mode clears IDs; query/page/view-mode changes and bulk completion clear IDs but keep mode active. The bulk bar is visible at zero selected items and its actions remain disabled until a selection exists.
12. Add `BulkActionBar` actions with feature permissions and count-aware confirmations. Keep the operation in the cubit/use-case layer, not in widget loops. Return a `BulkResult` with every failed row and its reason; do not report partial success as full success. When no server bulk endpoint exists, `BulkMutationUseCase` executes mutations sequentially; this is not one database transaction, so document the partial-completion behavior.
13. For bulk delete, reject or skip rows that cannot be deleted while continuing the remaining rows.
14. Add widget and unit tests for query behavior, sort synchronization, selection tri-state, permissions, bulk success/partial/full failure, duplicate seeds and editor dirty state.
15. Review all three view modes, phone/tablet/desktop widths, RTL/LTR, light/dark, empty/error/loading states and users without permissions.
16. Grid tiles must size to content: no fixed mainAxisExtent and no FittedBox/scaleDown. Determine columns from the available content width, keep each row's tiles equal height, overlay selection/actions so mode changes do not change tile height, and ellipsize long names.
17. Every editor opened with showAppFormDialog must pass an accurate dirty comparison against create defaults, edit values or duplicate seed. Match save normalization (trim surrounding whitespace in catalog editors); changing and restoring a value is clean. Clean forms dismiss directly, dirty forms require TemplateKeys.unsavedChanges confirmation, and busy forms cannot dismiss.
18. Never use the originating screen BuildContext after await to show a mutation result. Capture the root Navigator before awaiting and check that it remains mounted.

## Core components to reuse

- `ListPageTemplate`, `ListToolbarConfig`, `ListAddAction`
- `ListStatsBar`, `StatItem`, `CrudEmptyState`
- `PagedListCubit`, `PagedQuery`, `ListSelectionCubit`, `BulkMutationUseCase`, `BulkResult`
- `AppDataView`, `AppDataTable`, `AppRecordCard`, `AppDataGrid`
- `BulkActionBar`, `CrudBulkActions`, `BulkResultDialog`, `CrudRowActions`, `crudStatusColumn`
- `AppSwitch`, `AppStatCard`, `AppFilterBar`

Core must receive permissions from the feature; do not hardcode feature permissions such as `Permissions.masterData.manage` in `lib/app/core`.
