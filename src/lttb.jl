module LTTB

using Statistics

export lttb

# ---------------------------------------------------------------------------
# LTTB – Largest-Triangle-Three-Buckets  (Sveinn Steinarsson, 2013)
# ---------------------------------------------------------------------------

"""
    lttb(y, n_out; plot=false) -> (x_out, y_out)

Downsample 1-D signal `y` from `length(y)` points to `n_out` points using the
Largest-Triangle-Three-Buckets algorithm, which preserves visual fidelity.

When `plot=true` the function also displays an overlay of the original signal
and the downsampled result using PlotlyJS.

## Multiple-dispatch variants
- `lttb(y, n_out)` – integer-indexed signal
- `lttb(x, y, n_out)` – custom x-axis  
"""
function lttb(
    y::AbstractVector{T},
    n_out::Integer;
    plot::Bool = false,
)::Tuple{Vector{float(T)},Vector{float(T)}} where {T<:Real}
    x = collect(float(T), 1:length(y))
    return lttb(x, float.(y), n_out; plot = plot)
end

"""
    lttb(x, y, n_out; plot=false) -> (x_out, y_out)

Downsample `(x, y)` pairs to `n_out` representative samples.
Returns `(x_out::Vector, y_out::Vector)`.
"""
function lttb(
    x::AbstractVector{Tx},
    y::AbstractVector{Ty},
    n_out::Integer;
    plot::Bool = false,
) where {Tx<:Real,Ty<:Real}
    n = length(y)
    length(x) == n || throw(DimensionMismatch("x and y must have the same length"))
    n_out >= 2 || throw(ArgumentError("n_out must be ≥ 2"))

    # No downsampling needed
    if n <= n_out
        x_out = collect(Tx, x)
        y_out = collect(Ty, y)
        if plot
            _show_lttb_plot(x, y, x_out, y_out)
        end
        return x_out, y_out
    end

    idx = _lttb_indices(x, y, n_out)
    x_out = x[idx]
    y_out = y[idx]

    if plot
        _show_lttb_plot(x, y, x_out, y_out)
    end
    return collect(Tx, x_out), collect(Ty, y_out)
end

# ---------------------------------------------------------------------------
# Core index-selection logic
# ---------------------------------------------------------------------------
function _lttb_indices(
    x::AbstractVector{<:Real},
    y::AbstractVector{<:Real},
    n_out::Integer,
)::Vector{Int}
    n = length(y)
    selected = Vector{Int}(undef, n_out)
    selected[1] = 1
    selected[n_out] = n

    bucket_size = (n - 2) / (n_out - 2)
    a = 1  # index of last selected point

    for i in 1:(n_out-2)
        # Next-bucket average (look-ahead)
        # The i-th bucket (1-based) covers index range [floor(i*bucket_size)+2, floor((i+1)*bucket_size)+1]
        # We need the average of the NEXT bucket (i+1)
        next_start = floor(Int, (i + 1) * bucket_size) + 2
        next_end   = min(floor(Int, (i + 2) * bucket_size) + 1, n - 1)
        
        # Guard against empty next-bucket (can happen for very small n or specific n_out)
        if next_start > next_end
            avg_x = x[n]
            avg_y = y[n]
        else
            avg_x = mean(view(x, next_start:next_end))
            avg_y = mean(view(y, next_start:next_end))
        end

        # Current bucket range
        cur_start = floor(Int, i * bucket_size) + 2
        cur_end   = min(floor(Int, (i + 1) * bucket_size) + 1, n - 1)

        max_area  = -1.0
        max_idx   = cur_start
        xa, ya    = x[a], y[a]

        for j in cur_start:cur_end
            # Triangle area (×2, sign doesn't matter)
            area = abs((xa - avg_x) * (y[j] - ya) -
                       (xa - x[j]) * (avg_y - ya))
            if area > max_area
                max_area = area
                max_idx  = j
            end
        end
        selected[i+1] = max_idx
        a = max_idx
    end
    return selected
end

# ---------------------------------------------------------------------------
# Plot helper (lazy-loaded to avoid hard PlotlyJS import cost at module load)
# ---------------------------------------------------------------------------
function _show_lttb_plot(x_orig, y_orig, x_out, y_out)
    # Dynamically resolve Buff.Plots to avoid circular dependency
    buff_mod = Base.moduleroot(parentmodule(LTTB))
    plots_mod = getfield(buff_mod, :Plots)
    p = plots_mod.plot_comparison(
        collect(Float64, x_orig),
        collect(Float64, y_orig),
        collect(Float64, x_out),
        collect(Float64, y_out);
        title      = "LTTB Downsampling",
        label_orig = "original ($(length(y_orig)) pts)",
        label_new  = "LTTB ($(length(y_out)) pts)",
    )
    display(p)
    return p
end

end # module LTTB
