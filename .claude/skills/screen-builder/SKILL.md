---
name: screen-builder
description: Use when creating or substantially changing a Flutter screen/page (list, hub, form) in lib/app/features/**/presentation. Not for Core-only or backend work.
---

# Screen builder

1. Read `docs/architecture/KNOWN_PITFALLS.md` and `docs/design/SCREEN_BUILD_PLAYBOOK.md` first.
2. Write/confirm the screen spec (analysis card: info shown, filter sources and reasons, actions, states, mobile behavior) before code.
3. Build only from Core widgets (`ListPageTemplate`, `AppPageBody`, `AppDataTable`, `FilterBar`, `AppRowActions`, ...). If a capability is missing, add it to Core first.
4. Keep files ≤ 250 lines (`pages/<page>/widgets|sections`); no business logic in widgets.
5. Localize with `{name}` variables only; register key enums.
6. Add the 4-width × RTL/LTR × light/dark render test.
7. Never claim `dart format`, `flutter analyze` or `flutter test` passed unless run; list what was not run and ask the owner to run them.
