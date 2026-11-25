# List page template

## Preferred slots

| Need | Preferred slot | Legacy alternative | Runtime precedence |
|---|---|---|---|
| Toolbar: search, filters, sorting, view modes, refresh | `toolbar: ListToolbarConfig` | `filterBar`, `activeFilters`, `viewModeSwitcher` | `filterBar` overrides `toolbar`; do not provide both |
| Extra toolbar actions | `ListToolbarConfig.extraActions` | Feature-specific action widgets | Appended to the standard toolbar controls; defaults to an empty list |
| Statistics | `stats` (normally `ListStatsBar`) | `actions` | `stats` wins when both are supplied |
| Add/create action | `addAction: ListAddAction` | `primaryAction` | Mutually exclusive; the constructor asserts if both are supplied |
| Header item count | `count` | None | Rendered beside the page title |
| Page content | `dataTable` (normally `AppDataView`) | None | Rendered inside the list surface |

All legacy slots remain available for compatibility. Do not delete them or add `@Deprecated` annotations as part of a feature migration. New list screens must use the preferred slots.

## Statistics card behavior

A statistics card with a filter applies that filter to the list when selected. A card without a filter is informational only: it has no tap behavior, selected state, hover/ripple affordance, focus affordance, or button semantics. For example, a card showing the total inventory value is informational unless a corresponding list filter exists.

## Slot composition

- The header is first and may show `count` and `addAction`.
- The preferred statistics widget (`stats`) follows the header. The legacy `actions` widget is used only when `stats` is null.
- The list surface contains the toolbar, optional legacy active-filter/view-mode widgets, then the data area.
- `toolbar` owns active filters and view-mode selection through `ListToolbarConfig`. Do not also pass the legacy `activeFilters` or `viewModeSwitcher` slots, or the same controls can appear twice.
- `filterBar` is checked before `toolbar`; if both are passed, the legacy widget is what renders.

## Existing catalog list screens after migration

| Screen | Preferred slots | Legacy slots still used |
|---|---|---|
| `BrandsScreen` | `toolbar`, `stats`, `addAction`, `count` | None |
| `ColorsScreen` | `toolbar`, `stats`, `addAction`, `count` | None |

No catalog CRUD list screen in the migration scope still uses the legacy slots. This does not imply that unrelated non-CRUD pages use `ListPageTemplate`.

## Example

```dart
return ListPageTemplate(
  titleKey: FeatureKeys.title,
  toolbar: ListToolbarConfig(
    onSearchChanged: cubit.searchChanged,
    onClearAll: cubit.clearFilters,
    activeFilters: activeFilters,
    filterControls: filterControls,
    sortOptions: sortOptions,
    sorts: query.sorts,
    onSortsChanged: cubit.setSorts,
  ),
  stats: ListStatsBar<StatusFilter>(
    items: statsItems,
    selected: query.status,
    onSelected: cubit.setStatus,
    loading: statsLoading,
  ),
  addAction: ListAddAction(
    labelKey: FeatureKeys.add,
    permission: Permissions.catalog.manage,
    onPressed: onAdd,
  ),
  count: totalCount,
  dataTable: dataView,
);
```

## Selection mode and bulk CRUD actions

Selection is opt-in. The feature supplies its server-authoritative bulk permission through ListToolbarConfig: set selectionModeActive from PagedListCubit and provide onSelectionModeToggle only while the permission is granted. The template places the icon-only toggle beside refresh/view controls. The active state is exposed to semantics and uses a filled visual variant.

CrudSelectionScope<T> receives selectionModeActive and an exit callback. It passes selected IDs and the selection callback only when both permission and selection mode are active. It shows the compact BulkActionBar as soon as selection mode is active, including when zero records are selected. The page-level tri-state checkbox selects or clears the current page in every view. Exiting selection mode clears the selection; query/page/view-mode changes and completed bulk actions clear IDs while preserving selection mode. If permission is revoked, the scope exits selection mode. Core must not contain feature permission constants.

CrudBulkActions.statusAndDelete<T> invokes the selected-items callback and opens BulkResultDialog once for partial or complete failure.

- Complete success: success flash only.
- Partial/complete failure: result dialog only; do not also emit an error flash for the same batch.
- The operation is sequential per selected record, not atomic. Keep the selection page-scoped. Recommend a maximum of 50 records for ordinary bulk operations; 100 is the configured page-size ceiling and is suitable only for light operations.
- On content narrower than compactContentBreakpoint (720 logical pixels), BulkActionBar shows icon-only actions with tooltips and semantics.

## Grid tile sizing

AppDataGrid uses the available content width and the shared minimum tile-width token to determine columns. Each row uses intrinsic height so its tiles match the tallest tile in that row. Do not set a fixed mainAxisExtent and do not wrap grid content in FittedBox/scaleDown. Keep selection and row actions overlaid in the tile corner so enabling selection does not change content height. Grid content must allow natural height, constrain long names with maxLines and ellipsis, and keep logo/swatch previews at a stable size.

## Form dialog dismissal

Every AppFormDialog caller must pass a truthful dirty value comparing the current editable values with the initial create defaults, edit record, or duplicate seed. Compare normalized values consistently with save (the catalog editors trim surrounding whitespace); changing a field and restoring its original value is clean. A clean form may dismiss through the barrier, Escape, or back and returns false/null. A dirty form must route dismissal through the existing unsaved-changes confirmation with an explicit "Leave without saving" action; a busy form cannot dismiss. Never reload the list or show a success message unless the dialog result is true.

`CrudEditorDialog` provides the shared reset action through `AppFormDialog`:
- Create mode exposes **Clear content** and restores the initial create defaults without writing to the database.
- Edit mode exposes **Reset** and restores the original record values captured when the editor opened; it never submits a PATCH.
- Duplicate mode exposes **Reset** and restores the duplicate seed values.
- Reset appears only while the form is dirty and requires confirmation. Cancelling confirmation preserves every edit.
- `CrudEditorFields.reset()` restores text controllers. Feature-owned non-text values (such as a status switch) are restored by the optional editor `onReset` callback and must be represented in `extraDirty`.
- Reset also clears stale validation errors. No autosave, draft persistence, or Cubit lifecycle change is introduced.

Never use a screen BuildContext after await to show an operation result. Capture the root Navigator before awaiting and use its mounted state/context afterward.

## Sorting and loading

Multi-sort criteria are kept in priority order and all available fields may be used once. Selecting a field already used by another criterion is disabled; changing a criterion's field preserves its direction. For criteria after the first, the field menu contains a "Move sort up" action that moves that criterion one position earlier in the priority order. The feature query model and remote order builder must retain the entire list, not truncate after the second criterion. A zero maxSorts means no artificial cap beyond the available fields.

When no view mode has been selected, loading placeholders follow the available content width: cards below the shared compact breakpoint, table otherwise. An explicit saved view mode remains authoritative.

## Grid, sort, and editor invariants

### Grid cards
- Grid tiles use their natural content height. Do not set a fixed tile height or use `FittedBox` or `IntrinsicHeight`.
- Tile content may use `LayoutBuilder`; row-height equality is provided by the shared `EqualHeightRow` RenderBox without intrinsic queries.
- The grid reserves a header only when selection or row actions exist. When neither exists, no empty header row is rendered. Brands and Colors keep their row actions present in both selection states, so toggling selection does not move the tile content.

### Shared logos
- Use `AppLogoThumb` instead of feature-specific logo/image implementations.
- Use `AppLogoSize.small` (`AppComponentSize.avatarSmall`) for tables and horizontal rows.
- Use `AppLogoSize.large` (`AppComponentSize.logoPreview`) for grid previews. The component validates HTTP(S) URLs, contains the image without cropping, and provides the shared fallback.

### Multi-sort panel
- Each criterion occupies one row. The field selector fills the available row width and contains both the field name and its direction target inside one bordered control. The direction icon keeps its own touch target, tooltip, and semantics; tapping it changes direction without opening the field menu.
- The field name uses `AppTextType.bodyMedium`, stays on one line, and ends with an ellipsis when necessary. Its tooltip exposes the full translated field name.
- Only criteria after the first show the remove action. When there is more than one criterion, the first row reserves an empty slot with the same width as the remove button so the field controls align. With one criterion, no empty slot is reserved.
- "Move sort up" is an item at the end of the existing field menu, after a divider, and appears only for criteria after the first. This removes a separate row-level touch target and gives the field name more room without hiding the reorder action.
- The reorder action is placed in the existing field menu rather than another nested menu. The menu already owns field selection, so adding the action there avoids another menu layer and preserves the same close behavior: the current inner menu closes while the containing sort panel remains open.
- The add control remains icon-only. There is no move-down action; moving a later criterion up changes priority.
- Already-used fields are disabled in the menu. Duplicate and limit messages remain at the bottom of the panel.
- Desktop width is fixed to `AppComponentSize.filterControlWidth` (260 px at tablet/desktop); the phone panel fills the bottom sheet. Do not put `LayoutBuilder` inside the panel because `MenuAnchor` measures intrinsic dimensions.
- Width calculation uses the shared tokens and `AppIconButton` touch targets:
  - At a 280 px phone viewport, the sheet's horizontal `AppSpacing.md` padding leaves a 248 px panel. Subtract the panel's horizontal `AppSpacing.xs` padding (8 px total), the remove target (48 px), and the direction target (48 px): 144 px remain for the field-name area. The field's own horizontal `AppSpacing.xs` padding leaves 136 px for text.
  - On desktop, the 260 px panel minus its horizontal `AppSpacing.xs` padding (16 px total), remove target (56 px), and direction target (56 px) leaves 132 px for the field-name area. Subtracting the field target's own horizontal padding (16 px) leaves 116 px for text.
  - Both layouts keep at least 110 px for the field name without shrinking either touch target.

### Form dialogs
- Desktop dialogs keep the header and footer outside the scrollable body. Only the middle form content scrolls, so Save and Cancel remain visible on short screens.
- Every editor must provide its actual `dirty` state to `AppFormDialog`; this is required for the shared close guard.
- The mobile sheet keeps `enableDrag: false`: dragging would dismiss the route outside the dirty-form guard and conflicts with scrolling the form.

### Widget-test state
- Do not repeatedly `pumpWidget` the same stateful widget inside a width loop without resetting its state. Give each iteration a distinct `ValueKey(width)`, or pump an empty widget between iterations, so controllers and state are not reused accidentally.


## CRUD list engine role

`CrudListScreen<T, Q, C, E>` is the feature screen's composition root for a paged CRUD list. A feature supplies `CrudListConfig`; the engine creates the configured Cubit, restores the screen's `ViewModeCubit`, applies permission-gated add/selection behavior, connects mutation effects and stats refresh, builds the standard `ListToolbarConfig`, `ListPageTemplate` and `CrudSelectionScope`, and passes typed row/query state to the feature's data builder. Core owns the reusable mechanics; it does not own feature fields, translations, repositories, editor dialogs or business rules.

- Use `CrudListScreen(config: featureListConfig)` as the screen body; keep the route screen thin.
- Use `CrudDataSection` for the standard table/cards/grid, status column, empty/no-results state and row actions. Its feature callbacks supply columns, status policy, card/grid renderers, `canDelete` and optional row actions.
- Use the `CrudListConfig.extraToolbarActions` builder to supply per-screen toolbar widgets. The engine forwards them to `ListToolbarConfig.extraActions`; this is a screen-level slot, not a new global toolbar behavior.
- Use `extraBulkActions` to append feature actions after the standard bulk builder. Existing actions remain first.
- The `count` shown by `ListPageTemplate` is controlled by `CrudCapabilities.showCount`; stats remain a separate feature-owned widget.
- Keep the `CrudListConfig` and `CrudDataSection` contracts typed. Do not use dynamic casts, feature imports in Core, or a parallel screen/template implementation.
