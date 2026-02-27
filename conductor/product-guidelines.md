# Product Guidelines

## API Design Principles
- **Unified Interface:** Maintain a consistent API across all sub-modules (Outliers, Interpolate, Filter, etc.).
- **Multiple Dispatch:** Always provide variants for single vector inputs (`y`) and coordinate pairs (`x, y`).
- **Keyword Arguments:** Use keyword arguments for configuration (e.g., `method = :zscore`, `threshold = 3.0`) to improve readability.
- **Optional Visualization:** Plotting should always be opt-in via a `plot=true` keyword argument.
- **Type Stability:** All functions must be type-stable to leverage Julia's performance.

## Documentation Standards
- **Docstrings:** Every public function must have a comprehensive docstring with examples.
- **API Reference:** The documentation site (via Documenter.jl) should be the single source of truth for the API.
- **Visual Examples:** Include interactive PlotlyJS examples in the documentation to demonstrate the package's capabilities.
- **Tutorials:** Provide high-level tutorials that show how to combine different sub-modules for end-to-end signal processing tasks.

## Code Style & Performance
- **Naming Conventions:** Follow standard Julia naming conventions (snake_case for functions, PascalCase for types).
- **Zero-Copy Where Possible:** Use views and other zero-copy operations to maintain high performance.
- **Preallocation:** Provide "in-place" versions of functions (e.g., `filter!`) when it makes sense for performance.

## Testing & Quality Assurance
- **Comprehensive Coverage:** Every sub-module must have thorough unit tests in the `test/` directory.
- **Type Checks:** Use `@test @inferred` to verify type stability of key functions.
- **CI/CD:** All changes must pass the automated GitHub Actions CI pipeline.
- **Numerical Accuracy:** Verify algorithmic correctness against established libraries (e.g., DSP.jl, SciPy equivalents).
