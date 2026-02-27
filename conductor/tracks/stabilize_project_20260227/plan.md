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
- [x] Task: Fix broken tests [9e78b82]
    - [ ] Add `using Statistics` to `test/test_outliers.jl`.
    - [ ] Run the full test suite locally: `julia --project -e 'using Pkg; Pkg.test()'`.
    - [ ] Identify and fix any further test failures.
    - [ ] Ensure 90% test coverage is maintained.

## Phase 3: Verification and Finalization
- [x] Task: Final local verification [ac8ae33]
    - [x] Run all tests: `julia --project -e 'using Pkg; Pkg.test()'`.
    - [x] All 102 tests passed in 44.7s.
    - [x] Build documentation one last time.
- [x] Task: Verify CI stability [99ce21a]

## Phase: Review Fixes
- [x] Task: Apply review suggestions [d6a0595]
