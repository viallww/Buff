# Specification - Fix broken tests and CI pipeline

## Problem Statement
The project currently has failing GitHub Actions (CI) runs. The issues identified are:
1.  **Duplicate CI Runs:** The `CI.yml` workflow triggers on both `push` and `pull_request`, leading to redundant executions.
2.  **Test Package & Registry Issues:** The CI fails with `expected package Test [8dfed614] to be registered`. Additionally, standard libraries like `Test`, `Statistics`, and `LinearAlgebra` are missing `[compat]` entries in `Project.toml`.
3.  **Documentation Failure:** `makedocs` fails with `:missing_docs` because the module docstring for `Buff` (in `src/Buff.jl`) is not included in the manual via an `@docs Buff` block in `docs/src/index.md`.
4.  **Broken Tests:** `test/test_outliers.jl` fails with an `UndefVarError` for the `quantile` function because `using Statistics` is missing from the test file.

## Proposed Solution
1.  **Update CI Workflow:** Modify `.github/workflows/CI.yml` to trigger only on `pull_request` (all branches) and `push` to the `main` branch.
2.  **Fix Project.toml:** Add missing `[compat]` entries for `Test`, `Statistics`, and `LinearAlgebra` to ensure stable dependencies.
3.  **Resolve Documentation Issues:** Add an `@docs Buff` block to `docs/src/index.md` to include the module docstring and satisfy Documenter.jl's strict checks.
4.  **Fix Broken Tests:** Add `using Statistics` to `test/test_outliers.jl` and run all tests locally to verify stability.

## Acceptance Criteria
- CI runs only once per PR and on every push to `main`.
- All automated tests pass locally and in CI.
- Documentation builds successfully without `:missing_docs` errors.
- Test coverage meets the 90% requirement.
