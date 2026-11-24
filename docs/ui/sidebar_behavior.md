# Sidebar behavior by device

Source: `lib/app/shell/app_shell.dart` (`AppShell`, `_PersistedSidebar`) and
`lib/app/core/presentation/widgets/app_sidebar/app_sidebar.dart`. Tests:
`test/shell/app_shell_windows_sidebar_test.dart`.

| Device | Navigation | Collapse |
|---|---|---|
| Desktop / Windows | Sidebar tree, open by default | Yes: chevron button and the page-tap toggle below. Saved in settings. |
| Tablet | Same sidebar, icon-only until opened | Same as desktop |
| Phone | Bottom bar (4 destinations + "More" tree above 5) and the full sidebar as a drawer from the menu icon | No rail; the drawer is always expanded and closes after a choice |

## Tapping the page already shown (desktop and tablet)

Precedent: the VS Code activity bar (tap the active icon to hide or show the
panel).

* Sidebar open, tap the current page: it folds to icons. No navigation.
* Sidebar folded, tap the current page's icon: it opens. No navigation.
* Tap another page: navigate; the sidebar stays as it is (open or folded).
* The choice is saved exactly like the chevron button.

Guards, so the shortcut never costs the user something:

* Only for pages without sub-items. A parent with sub-items keeps its own
  rule: one tap opens/closes its list, a double tap opens its page.
* Only when the shown page is the root of its branch. On a deeper page (a
  detail) the same tap goes back to the root, as before; a second tap then
  folds the sidebar.
* Only after the saved preference was restored, and only where collapsing is
  supported (`supportsCollapsibleSidebar`, or a tablet).
* The chevron button stays as the visible, discoverable control.

## Phone notes

* The drawer shows the section of the current page open; a choice closes the
  drawer, then navigates (the unsaved-changes guard still applies).
* Reselecting the active bottom-bar tab resets the branch to its root, because
  there is no sidebar to fold.
* Known gap: a drawer parent with sub-items opens its own page only through a
  double tap, which is hard to discover on touch. The "More" sheet does not have
  this problem (its parent row opens the page). Candidate follow-up: add an
  explicit "open page" row at the top of an open drawer section.
