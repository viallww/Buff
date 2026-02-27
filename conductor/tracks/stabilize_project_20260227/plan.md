# Implementation Plan - Fix broken tests and CI pipeline

## Phase 1: CI Pipeline Stabilization
- [ ] Task: Update CI.yml trigger logic
    - [ ] Modify `.github/workflows/CI.yml` to trigger on `pull_request` (all branches) and `push` (only `main`).
    - [ ] Verify the change by pushing to a branch and checking CI triggers.
- [ ] Task: Fix Test package registration issue
    - [ ] Analyze `Project.toml` and `test/runtests.jl`.
    - [ ] Ensure `Test` is correctly listed in `[extras]` and `[targets]`.
    - [ ] Run `julia --project -e 'using Pkg; Pkg.test()'` locally to verify the environment.

## Phase 2: Code and Documentation Fixes
- [ ] Task: Fix missing documentation
    - [ ] Identify where `Buff.Buff` docstring is defined and ensure it's included in `docs/make.jl` or a markdown file in `docs/src/`.
    - [ ] Run `julia --project=docs docs/make.jl` locally to verify the build.
- [ ] Task: Fix broken tests
    - [ ] Run the full test suite locally: `julia --project -e 'using Pkg; Pkg.test()'`.
    - [ ] Identify failing test cases and fix them.
    - [ ] Ensure 90% test coverage is maintained.

## Phase 3: Verification and Finalization
- [ ] Task: Final local verification
    - [ ] Run all tests with coverage: `julia --project -e 'using Pkg; Pkg.test(coverage=true)'`.
    - [ ] Verify 90% coverage.
    - [ ] Build documentation one last time.
- [ ] Task: Verify CI stability
    - [ ] Push changes and confirm CI passes on GitHub Actions.
    - [ ] Confirm no duplicate runs occur.
