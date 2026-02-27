# Buff.jl

**Buff** is a Julia package providing a clean, type-stable, multiple-dispatch
interface to common signal-processing operations:

- Outlier detection and removal
- Interpolation and missing-value filling
- Smoothing / filtering
- Downsampling (LTTB)
- Upsampling
- Trend / regression analysis
- Interactive PlotlyJS visualisations (pass `plot=true` to any transform)

## Getting started

```julia
using Buff
```

## Table of contents

```@contents
Pages = [
    "api/outliers.md",
    "api/interpolate.md",
    "api/filter.md",
    "api/lttb.md",
    "api/upsample.md",
    "api/trend.md",
    "api/plots.md",
]
Depth = 2
```
