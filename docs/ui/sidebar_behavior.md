# Sidebar behavior by device

Source: `lib/app/shell/app_shell.dart` (`AppShell`, `_PersistedSidebar`) and
`lib/app/core/presentation/widgets/app_sidebar/app_sidebar.dart`. Tests:
`test/shell/app_shell_windows_sidebar_test.dart`.

| Device | Navigation | Collapse |
|---|---|---|
| Desktop / Windows | Sidebar tree, open by default | Yes: chevron button and the page-tap toggle below. Saved in settings. |
| Tablet | Same sidebar, icon-only until opened | Same as desktop |
| Phone | Bottom bar (4 destinations + "More" tree above 5) and the full sidebar as a drawer from the menu icon | No rail; the drawer is always expanded and closes after a choice |

## Tapping on desktop and tablet

Precedent: the VS Code activity bar.

| State | Tap | Result |
|---|---|---|
| Open | the page shown (leaf at its branch root) | folds to icons, no navigation |
| Open | the active sub-item | folds, no navigation |
| Open | another page or sub-item | navigates, stays open |
| Open | a parent with sub-items | opens/closes its list (double tap: its page) |
| Folded | the page shown (icon) | opens, no navigation |
| Folded | another page's icon | navigates **and** opens |
| Folded | a parent's icon | opens with its list unfolded, no navigation |
| Folded | a sub-item icon | navigates (unless active) **and** opens |

The choice is saved like the chevron button. Guards: a leaf toggles only at its
branch root (a detail page goes back to the root first); only after the saved
preference was restored; only where collapsing is supported
(`supportsCollapsibleSidebar`, or a tablet).

## Phone notes

* The drawer shows the section of the current page open; a choice closes the
  drawer, then navigates (the unsaved-changes guard still applies).
* Reselecting the active bottom-bar tab resets the branch to its root, because
  there is no sidebar to fold.
* Known gap: a drawer parent with sub-items opens its own page only through a
  double tap, which is hard to discover on touch. The "More" sheet does not have
  this problem (its parent row opens the page). Candidate follow-up: add an
  explicit "open page" row at the top of an open drawer section.
