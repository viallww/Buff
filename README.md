# Buff.jl

[![CI](https://github.com/viallww/Buff/actions/workflows/CI.yml/badge.svg)](https://github.com/viallww/Buff/actions/workflows/CI.yml)
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://viallww.github.io/Buff)

**Buff** is a Julia package that wraps best-in-class signal-processing
libraries behind a unified, type-stable, multiple-dispatch API. Pass
`plot=true` to any transform to instantly visualise the result with
**PlotlyJS**.

| Sub-module | What it uses | Functions |
|------------|-------------|-----------|
| `Outliers` | **StatsBase.jl** (`zscore`, `mad`, `winsor`) | `detect_outliers`, `remove_outliers`, `winsorize` |
| `Interpolate` | **Interpolations.jl** (linear); pure-Julia natural cubic spline | `interpolate_linear`, `interpolate_cubic`, `fill_missing` |
| `Filter` | **DSP.jl** (Butterworth, `conv`, `filtfilt`); pure-Julia SG / EMA | `moving_average`, `lowpass_filter`, `highpass_filter`, `bandpass_filter`, `bandstop_filter`, `exponential_smoothing`, `savitzky_golay` |
| `LTTB` | pure-Julia LTTB algorithm | `lttb` |
| `Upsample` | **Interpolations.jl** | `upsample_linear`, `upsample_nearest` |
| `Trend` | pure-Julia OLS | `linear_regression`, `polynomial_regression`, `detrend` |
| `Plots` | **PlotlyJS.jl** | `plot_signal`, `plot_comparison`, `plot_regression` |

---

## Installation

```julia
using Pkg
Pkg.add(url = "https://github.com/viallww/Buff")
```

---

## Quick start

```julia
using Buff

t = 0.0:0.01:4π
y = sin.(t) .+ 0.3 .* randn(length(t))
```

### Outlier detection & removal

```julia
y_noisy = copy(y)
y_noisy[50] = 10.0          # inject a spike

mask    = detect_outliers(y_noisy; method = :zscore, threshold = 3.0)
y_clean = remove_outliers(y_noisy; method = :iqr, threshold = 1.5)

# Winsorise to [5th, 95th] percentile
y_win = winsorize(y_noisy; limits = (0.05, 0.95))
```

### Interpolation & missing-value filling

```julia
x = [0.0, 1.0, 2.5, 4.0, 5.0]
z = [0.0, 1.0, 0.6, 0.3, 0.0]

# Linear via Interpolations.jl
z_lin = interpolate_linear(x, z, 0.0:0.1:5.0)

# Natural cubic spline (pure Julia, handles non-uniform knots)
z_cub = interpolate_cubic(x, z, 0.0:0.1:5.0)

# Fill missing values
v = [1.0, missing, missing, 4.0, missing, 6.0]
fill_missing(v; method = :linear)      # → [1, 2, 3, 4, 5, 6]
fill_missing(v; method = :forward)     # LOCF
fill_missing(v; method = :backward)    # NOCB
```

### Filtering (DSP.jl powered)

```julia
# Centred moving average (DSP.conv based)
y_ma = moving_average(y, 11)

# Exponential smoothing
y_ema = exponential_smoothing(y, 0.3)

# Savitzky-Golay
y_sg = savitzky_golay(y, 11, 3)

# Butterworth low-pass at 5 Hz (signal sampled at 100 Hz)
y_lp = lowpass_filter(y, 5.0; fs = 100.0, order = 4)

# Band-pass 1–10 Hz
y_bp = bandpass_filter(y, 1.0, 10.0; fs = 100.0, order = 4)
```

### LTTB downsampling (with optional plot)

```julia
t_dense = collect(0.0:0.001:10.0)
sig     = sin.(t_dense) .+ 0.1 .* randn(length(t_dense))

# Returns (x_out, y_out) – 200 representative points
x_ds, y_ds = lttb(t_dense, sig, 200)

# Same call + interactive PlotlyJS overlay
x_ds, y_ds = lttb(t_dense, sig, 200; plot = true)
```

### Upsampling (with optional plot)

```julia
x_low = [0.0, 1.0, 2.0, 3.0, 4.0]
y_low = [0.0, 1.0, 0.5, 0.8, 0.2]

# 4× linear upsampling via Interpolations.jl
x_hi, y_hi = upsample_linear(x_low, y_low, 4; plot = true)

# Nearest-neighbour
x_hi, y_hi = upsample_nearest(x_low, y_low, 4)
```

### Trend / regression

```julia
x = collect(1.0:50.0)
y = 2.5 .* x .+ 1.0 .+ randn(50)

res = linear_regression(x, y; plot = true)
# res.slope, res.intercept, res.r_squared, res.y_fit

res2 = polynomial_regression(x, y .^ 2, 2; plot = true)

detrended = detrend(y; method = :linear)
```

### Direct plot helpers

```julia
p = plot_signal(y; title = "Raw signal")
p = plot_comparison(x_low, y_low, x_hi, y_hi; title = "Upsampled")
p = plot_regression(x, y, res.y_fit)
display(p)
```

---

## Design principles

* **Type stability** – all functions are parameterised on element type `T<:Real`
  and return concrete `Vector{float(T)}` or `Vector{T}` outputs.
* **Multiple dispatch** – every function has variants for `y`-only (integer
  x-index), `(x, y)` pairs, and explicit output-grid arguments.
* **Best-in-class back-ends** – linear interpolation and upsampling delegate to
  **Interpolations.jl**; DSP filters use **DSP.jl**'s `filtfilt` for zero-phase
  response; outlier statistics use **StatsBase.jl**.
* **Zero mandatory plots** – plotting is always opt-in via `plot=true` and
  requires no display server to use the numerical functions.

---

## Documentation

Full API docs are generated with **Documenter.jl** and deployed to
[GitHub Pages](https://viallww.github.io/Buff).
