# Julia Style Guide

## General Principles
- **Naming:** `snake_case` for functions, `PascalCase` for types and modules.
- **Indent:** 4 spaces.
- **Types:** Always provide type annotations for function arguments to aid multiple dispatch and type stability.
- **Return Type:** Avoid explicit `return` at the end of functions.
- **Macros:** Use macros like `@inbounds` and `@views` carefully for performance optimization.
- **Docstrings:** Use Markdown in docstrings and follow the Documenter.jl conventions.
- **Broadcasting:** Use the `.` syntax for broadcasting over arrays.
- **Type Stability:** Use `@code_warntype` to check for type stability during development.
- **Internal APIs:** Prefix internal-only functions with `_`.

## Modules & Imports
- Use `using` for project dependencies and `import` when extending base functions.
- Organize sub-modules into separate files and use `include()` and `using` / `export` in the main module file.

## Testing
- Use the `Test` standard library.
- Place tests in the `test/` directory.
- Use `@testset` to group related tests.
- Verify type stability with `@test @inferred`.
