# Specification - Fix broken tests and CI pipeline

## Problem Statement
The project currently has failing GitHub Actions (CI) runs. The issues identified are:
1.  **Duplicate CI Runs:** The `CI.yml` workflow triggers on both `push` and `pull_request`, leading to redundant executions.
2.  **Test Package Issue:** The CI fails with `expected package Test [8dfed614] to be registered`, likely due to how `Test` is defined in `Project.toml`.
3.  **Documentation Failure:** `makedocs` fails with `:missing_docs` because `Buff.Buff` is not included in the manual.
4.  **Broken Tests:** The user reports that tests are broken (root cause to be investigated).

## Proposed Solution
1.  **Update CI Workflow:** Modify `.github/workflows/CI.yml` to trigger only on `pull_request` and `push` to the `main` branch.
2.  **Fix Project.toml:** Ensure `Test` is correctly handled as a standard library extra.
3.  **Resolve Documentation Issues:** Update `docs/src/api/` or `docs/make.jl` to include missing docstrings.
4.  **Fix Broken Tests:** Run tests locally, identify failures, and fix the underlying code or test cases.

## Acceptance Criteria
- CI runs only once per PR and on every push to `main`.
- All automated tests pass locally and in CI.
- Documentation builds successfully without `:missing_docs` errors.
- Test coverage meets the 90% requirement.
