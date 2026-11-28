# CAT Scope 1 — CI validation record

## Baseline on integration branch

- Branch: `integration/catalog-scope-1-combined`
- Commit: `211a5f89fd5dff74d55dc1035a129b05ea71e222`
- Workflow: Flutter CI, run #2587
- Result: **success** (formatting and static analysis passed; the full Flutter test suite was intentionally skipped as recorded in the commit message).
- URL: https://github.com/AhmadKabawa/my_accounting_software/actions/runs/46092249506

## Scope 1 review branch

- Branch: `fix/scope-1-catalog-review`
- Code head: `c46ab8c13e35c0cda37bd9f51030cc88240a15d2`
- Workflow: Flutter CI, run #2665
- Result: **success** for Dart formatting and static analysis.
- URL: https://github.com/AhmadKabawa/my_accounting_software/actions/runs/46097370659
- The workflow's `Full test suite` job was skipped for this feature-branch push. This is not evidence that the updated tests pass; they remain unexecuted in this workflow.
- Static analysis completed with `flutter analyze --no-fatal-infos`; informational lints remain in the repository, with no analyzer errors or fatal warnings in this run.

## Validation boundaries

- No local Flutter/Dart commands were run.
- No live Supabase/PostgREST checks were performed.
- No merge was performed.
