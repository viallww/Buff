module Upsample

using Interpolations

export upsample_linear, upsample_nearest

# ---------------------------------------------------------------------------
# Linear upsampling  (backed by Interpolations.jl LinearInterpolation)
# ---------------------------------------------------------------------------

"""
    upsample_linear(y, factor; plot=false) -> Vector

Upsample signal `y` by integer `factor` using piecewise-linear interpolation
(Interpolations.jl).  Output length = `(length(y) - 1) * factor + 1`.

## Multiple-dispatch variants
- `upsample_linear(y, factor)` – integer-indexed
- `upsample_linear(x, y, factor)` – custom x-axis; returns `(x_new, y_new)`
- `upsample_linear(x, y, x_new)` – evaluate at explicit new positions
"""
function upsample_linear(
    y::AbstractVector{T},
    factor::Integer;
    plot::Bool = false,
)::Vector{float(T)} where {T<:Real}
    x = collect(1.0:Float64(length(y)))
    _, y_new = upsample_linear(x, y, factor; plot = plot)
    return y_new
end

function upsample_linear(
    x::AbstractVector{Tx},
    y::AbstractVector{Ty},
    factor::Integer;
    plot::Bool = false,
) where {Tx<:Real,Ty<:Real}
    factor >= 1 || throw(ArgumentError("factor must be ≥ 1"))
    n = length(y)
    length(x) == n || throw(DimensionMismatch("x and y must have same length"))
    n >= 2          || throw(ArgumentError("Need at least 2 points to upsample"))

    xf    = float.(x)
    itp   = LinearInterpolation(xf, float.(y); extrapolation_bc = Flat())
    x_new = range(xf[1], xf[end]; length = (n - 1) * factor + 1)
    y_new = itp.(x_new)

    if plot;  _show_upsample_plot(x, y, x_new, y_new, "Linear")  end
    return collect(float(Tx), x_new), y_new
end

function upsample_linear(
    x::AbstractVector{Tx},
    y::AbstractVector{Ty},
    x_new::AbstractVector{<:Real};
    plot::Bool = false,
) where {Tx<:Real,Ty<:Real}
    length(x) == length(y) || throw(DimensionMismatch("x and y must have same length"))

    itp   = LinearInterpolation(float.(x), float.(y); extrapolation_bc = Flat())
    y_new = itp.(x_new)

    if plot;  _show_upsample_plot(x, y, x_new, y_new, "Linear")  end
    return collect(float(Tx), x_new), y_new
end

# ---------------------------------------------------------------------------
# Nearest-neighbour upsampling (pure Julia – avoids Interpolations.jl API
# version uncertainty for Gridded(Constant) boundary modes)
# ---------------------------------------------------------------------------

"""
    upsample_nearest(y, factor; plot=false) -> Vector

Upsample by integer `factor` using nearest-neighbour (step) interpolation.
"""
function upsample_nearest(
    y::AbstractVector{T},
    factor::Integer;
    plot::Bool = false,
)::Vector{T} where {T<:Real}
    x = collect(1.0:Float64(length(y)))
    _, y_new = upsample_nearest(x, y, factor; plot = plot)
    return collect(T, y_new)
end

function upsample_nearest(
    x::AbstractVector{Tx},
    y::AbstractVector{Ty},
    factor::Integer;
    plot::Bool = false,
) where {Tx<:Real,Ty<:Real}
    factor >= 1 || throw(ArgumentError("factor must be ≥ 1"))
    n = length(y)
    length(x) == n || throw(DimensionMismatch("x and y must have same length"))
    n >= 2          || throw(ArgumentError("Need at least 2 points"))

    xf    = float.(x)
    x_new = range(xf[1], xf[end]; length = (n - 1) * factor + 1)
    y_new = _nearest(xf, float.(y), x_new)

    if plot;  _show_upsample_plot(x, y, x_new, y_new, "Nearest")  end
    return collect(float(Tx), x_new), y_new
end

function upsample_nearest(
    x::AbstractVector{Tx},
    y::AbstractVector{Ty},
    x_new::AbstractVector{<:Real};
    plot::Bool = false,
) where {Tx<:Real,Ty<:Real}
    length(x) == length(y) || throw(DimensionMismatch("x and y must have same length"))

    y_new = _nearest(float.(x), float.(y), x_new)
    if plot;  _show_upsample_plot(x, y, x_new, y_new, "Nearest")  end
    return collect(float(Tx), x_new), y_new
end

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

function _nearest(
    x::AbstractVector{F},
    y::AbstractVector{F},
    x_new,
)::Vector{F} where {F<:AbstractFloat}
    n      = length(x)
    result = Vector{F}(undef, length(x_new))
    for (k, xk) in enumerate(x_new)
        if xk <= x[1];   result[k] = y[1];   continue  end
        if xk >= x[n];   result[k] = y[n];   continue  end
        lo, hi = 1, n
        while hi - lo > 1
            mid = (lo + hi) >>> 1
            x[mid] <= xk ? lo = mid : hi = mid
        end
        result[k] = abs(xk - x[lo]) <= abs(xk - x[hi]) ? y[lo] : y[hi]
    end
    return result
end

function _show_upsample_plot(x_orig, y_orig, x_new, y_new, method_name::String)
    buff_mod  = Base.moduleroot(parentmodule(Upsample))
    plots_mod = getfield(buff_mod, :Plots)
    p = plots_mod.plot_comparison(
        collect(Float64, x_orig),
        collect(Float64, y_orig),
        collect(Float64, x_new),
        collect(Float64, y_new);
        title      = "$method_name Upsampling",
        label_orig = "original ($(length(y_orig)) pts)",
        label_new  = "upsampled ($(length(y_new)) pts)",
    )
    display(p)
    return p
end

end # module Upsample
