# Implementation Plan - Fix broken tests and CI pipeline

## Phase 1: CI Pipeline & Dependency Stabilization
- [x] Task: Update CI.yml trigger logic [99ce21a]
    - [ ] Modify `.github/workflows/CI.yml` to trigger on `pull_request` and `push` (only `main`).
    - [ ] Verify the change by pushing to a branch and checking CI triggers.
- [x] Task: Fix Project.toml dependencies & [compat] [bfc1203]
    - [ ] Add `[compat]` entries for `Test`, `Statistics`, and `LinearAlgebra`.
    - [ ] Run `julia --project -e 'using Pkg; Pkg.test()'` locally to verify the environment.

## Phase 2: Code and Documentation Fixes
- [x] Task: Fix missing documentation [3913020]
    - [ ] Add an `@docs Buff` block to `docs/src/index.md`.
    - [ ] Run `julia --project=docs docs/make.jl` locally to verify the build passes without `:missing_docs` errors.
- [ ] Task: Fix broken tests
    - [ ] Add `using Statistics` to `test/test_outliers.jl`.
    - [ ] Run the full test suite locally: `julia --project -e 'using Pkg; Pkg.test()'`.
    - [ ] Identify and fix any further test failures.
    - [ ] Ensure 90% test coverage is maintained.

## Phase 3: Verification and Finalization
- [ ] Task: Final local verification
    - [ ] Run all tests with coverage: `julia --project -e 'using Pkg; Pkg.test(coverage=true)'`.
    - [ ] Verify 90% coverage.
    - [ ] Build documentation one last time.
- [ ] Task: Verify CI stability
    - [ ] Push changes and confirm CI passes on GitHub Actions.
    - [ ] Confirm no duplicate runs occur.
