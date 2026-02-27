module Outliers

using Statistics
using StatsBase: zscore, mad, winsor

export detect_outliers, remove_outliers, winsorize

# ---------------------------------------------------------------------------
# detect_outliers
# ---------------------------------------------------------------------------

"""
    detect_outliers(data; method=:zscore, threshold=3.0) -> BitVector

Return a `BitVector` where `true` marks an outlier.

## Methods
- `:zscore`         – points whose |z-score| exceeds `threshold`
                      (uses `StatsBase.zscore` for robust computation)
- `:iqr`            – points outside `Q1 - t·IQR … Q3 + t·IQR`
- `:modified_zscore` – median-based z-score using MAD
                      (uses `StatsBase.mad`; robust to non-Gaussian data)
"""
function detect_outliers(
    data::AbstractVector{T};
    method::Symbol = :zscore,
    threshold::Real = 3.0,
)::BitVector where {T<:Real}
    if method === :zscore
        zs = zscore(data)        # StatsBase – (x - μ) / σ
        return abs.(zs) .> threshold

    elseif method === :iqr
        q1 = quantile(data, 0.25)
        q3 = quantile(data, 0.75)
        iqr_val = q3 - q1
        fence   = threshold * iqr_val
        return (data .< q1 - fence) .| (data .> q3 + fence)

    elseif method === :modified_zscore
        med     = median(data)
        mad_val = mad(data; normalize = false)   # StatsBase.mad
        mad_val == 0 && return falses(length(data))
        mzs = 0.6745 .* abs.(data .- med) ./ mad_val
        return mzs .> threshold

    else
        throw(ArgumentError("Unknown method :$method. Choose :zscore, :iqr, or :modified_zscore."))
    end
end

# Dispatch for matrix columns
function detect_outliers(
    data::AbstractMatrix{T};
    method::Symbol = :zscore,
    threshold::Real = 3.0,
)::BitMatrix where {T<:Real}
    n, p = size(data)
    result = falses(n, p)
    for j in 1:p
        result[:, j] = detect_outliers(view(data, :, j); method = method, threshold = threshold)
    end
    return result
end

# ---------------------------------------------------------------------------
# remove_outliers
# ---------------------------------------------------------------------------

"""
    remove_outliers(data; method=:zscore, threshold=3.0, replace_with_missing=false)

Return a copy of `data` with outlier elements either dropped (default) or
replaced by `missing` when `replace_with_missing=true`.
"""
function remove_outliers(
    data::AbstractVector{T};
    method::Symbol = :zscore,
    threshold::Real = 3.0,
    replace_with_missing::Bool = false,
)::Vector where {T<:Real}
    mask = detect_outliers(data; method = method, threshold = threshold)
    if replace_with_missing
        result = Vector{Union{T,Missing}}(data)
        result[mask] .= missing
        return result
    else
        return data[.!mask]
    end
end

# ---------------------------------------------------------------------------
# winsorize  (backed by StatsBase.winsor)
# ---------------------------------------------------------------------------

"""
    winsorize(data; limits=(0.05, 0.95)) -> Vector

Clip extreme values so that observations below the `limits[1]` quantile are
raised to that boundary, and observations above `limits[2]` are lowered to it.
This delegates to `StatsBase.winsor` for symmetric limits and uses
quantile-clamping directly for asymmetric limits.
"""
function winsorize(
    data::AbstractVector{T};
    limits::Tuple{Float64,Float64} = (0.05, 0.95),
)::Vector{T} where {T<:Real}
    lo_frac = limits[1]
    hi_frac = 1.0 - limits[2]

    if lo_frac ≈ hi_frac
        # StatsBase.winsor takes the proportion to clip from EACH end
        return collect(T, winsor(data; prop = lo_frac))
    else
        lo = quantile(data, limits[1])
        hi = quantile(data, limits[2])
        return clamp.(data, lo, hi)
    end
end

end # module Outliers
