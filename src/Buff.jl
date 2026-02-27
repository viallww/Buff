"""
    Buff

A Julia package providing an abstract wrapper around common signal-processing
algorithms:

- **Outliers** – detection (`detect_outliers`), removal (`remove_outliers`),
  and winsorization (`winsorize`) backed by **StatsBase.jl**
- **Interpolate** – linear interpolation (via **Interpolations.jl**),
  natural cubic spline, and missing-value filling
- **Filter** – moving average and Butterworth filters via **DSP.jl**;
  exponential smoothing and Savitzky-Golay (pure Julia)
- **LTTB** – Largest-Triangle-Three-Buckets downsampling (`lttb`)
- **Upsample** – linear and nearest-neighbour upsampling via
  **Interpolations.jl**
- **Trend** – linear/polynomial regression and detrending
- **Plots** – PlotlyJS-backed plotting utilities (pass `plot=true` to any
  transform function to display an overlay automatically)

All functions support `AbstractVector`/`AbstractMatrix` inputs and are written
for type stability.  Multiple-dispatch variants accept optional x-axis vectors
and keyword arguments (`plot`, `method`, `threshold`, etc.).
"""
module Buff

using Reexport

# ── Sub-modules ──────────────────────────────────────────────────────────────

include("plots.jl")        # must come first so other modules can reference Plots
include("outliers.jl")
include("interpolate.jl")
include("filter.jl")
include("lttb.jl")
include("upsample.jl")
include("trend.jl")

# ── Re-export every public symbol ────────────────────────────────────────────

@reexport using .Plots
@reexport using .Outliers
@reexport using .Interpolate
@reexport using .Filter
@reexport using .LTTB
@reexport using .Upsample
@reexport using .Trend

end # module Buff
