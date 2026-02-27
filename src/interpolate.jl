module Interpolate

using Interpolations
using LinearAlgebra

export interpolate_linear, interpolate_cubic, fill_missing, fill_missing!

# ---------------------------------------------------------------------------
# Linear interpolation  (backed by Interpolations.jl)
# ---------------------------------------------------------------------------

"""
    interpolate_linear(x, y, x_new) -> Vector

Piecewise-linear interpolation using Interpolations.jl.
`x` must be strictly increasing.  Values outside `[x[1], x[end]]` are
clamped to the nearest boundary value (`Flat` extrapolation).

## Multiple-dispatch variants
- `interpolate_linear(y, x_new)` – integer-indexed (x = 1 … n)
"""
function interpolate_linear(
    x::AbstractVector{Tx},
    y::AbstractVector{Ty},
    x_new::AbstractVector{<:Real},
)::Vector{float(Ty)} where {Tx<:Real,Ty<:Real}
    length(x) == length(y) || throw(DimensionMismatch("x and y must have the same length"))
    length(x) >= 2          || throw(ArgumentError("Need at least 2 data points"))

    itp = linear_interpolation(float.(x), float.(y); extrapolation_bc = Flat())
    return itp.(x_new)
end

function interpolate_linear(
    y::AbstractVector{Ty},
    x_new::AbstractVector{<:Real},
)::Vector{float(Ty)} where {Ty<:Real}
    return interpolate_linear(collect(1:length(y)), y, x_new)
end

# ---------------------------------------------------------------------------
# Cubic spline interpolation  (natural cubic spline – pure Julia)
#
# Interpolations.jl's CubicSplineInterpolation requires a uniform AbstractRange.
# This implementation handles arbitrary (non-uniform) sorted knots.
# ---------------------------------------------------------------------------

"""
    interpolate_cubic(x, y, x_new) -> Vector

Natural cubic spline interpolation.  `x` must be strictly increasing with
at least 3 points.  Uses flat (clamp) extrapolation beyond the knot range.
"""
function interpolate_cubic(
    x::AbstractVector{Tx},
    y::AbstractVector{Ty},
    x_new::AbstractVector{<:Real},
)::Vector{float(Ty)} where {Tx<:Real,Ty<:Real}
    n = length(x)
    length(y) == n || throw(DimensionMismatch("x and y must have the same length"))
    n >= 3          || throw(ArgumentError("Need at least 3 data points for cubic spline"))

    F  = float(Ty)
    yf = F.(y)
    xf = F.(x)
    h  = diff(xf)
    all(>(0), h) || throw(ArgumentError("x must be strictly increasing"))

    # Solve tridiagonal system for interior second derivatives (natural BC: M[1]=M[n]=0)
    m = n - 2
    A = zeros(F, m, m)
    b = zeros(F, m)
    for i in 1:m
        A[i, i] = 2 * (h[i] + h[i+1])
        if i > 1;  A[i, i-1] = h[i];   A[i-1, i] = h[i]  end
        b[i] = 6 * ((yf[i+2] - yf[i+1]) / h[i+1] - (yf[i+1] - yf[i]) / h[i])
    end
    M = [zero(F); A \ b; zero(F)]

    result = Vector{F}(undef, length(x_new))
    for (k, xk) in enumerate(x_new)
        if xk <= xf[1];   result[k] = yf[1];   continue  end
        if xk >= xf[n];   result[k] = yf[n];   continue  end
        lo, hi = 1, n
        while hi - lo > 1
            mid = (lo + hi) >>> 1
            xf[mid] <= xk ? lo = mid : hi = mid
        end
        dx    = xf[hi] - xf[lo]
        t     = F(xk) - xf[lo]
        a     = yf[lo]
        b_c   = (yf[hi] - yf[lo]) / dx - dx * (2M[lo] + M[hi]) / 6
        c     = M[lo] / 2
        d_c   = (M[hi] - M[lo]) / (6dx)
        result[k] = a + b_c * t + c * t^2 + d_c * t^3
    end
    return result
end

function interpolate_cubic(
    y::AbstractVector{Ty},
    x_new::AbstractVector{<:Real},
)::Vector{float(Ty)} where {Ty<:Real}
    return interpolate_cubic(collect(1:length(y)), y, x_new)
end

# ---------------------------------------------------------------------------
# fill_missing – backed by Interpolations.jl for the :linear case
# ---------------------------------------------------------------------------

"""
    fill_missing(data; method=:linear) -> Vector

Return a copy of `data` with `missing` values filled in.

## Methods
- `:linear`   – linear interpolation between neighbours (Interpolations.jl)
- `:forward`  – last observed value carried forward
- `:backward` – next observed value carried backward
- `:mean`     – replace every missing with the observed mean
"""
function fill_missing(
    data::AbstractVector{<:Union{T,Missing}};
    method::Symbol = :linear,
)::Vector{T} where {T<:Real}
    return fill_missing!(copy(data); method = method)
end

"""
    fill_missing!(data; method=:linear) -> data

In-place version of `fill_missing`.
"""
function fill_missing!(
    data::AbstractVector{<:Union{T,Missing}};
    method::Symbol = :linear,
)::AbstractVector where {T<:Real}
    n = length(data)

    if method === :forward
        last_val = nothing
        for i in 1:n
            if !ismissing(data[i]);  last_val = data[i]
            elseif last_val !== nothing;  data[i] = last_val  end
        end

    elseif method === :backward
        next_val = nothing
        for i in n:-1:1
            if !ismissing(data[i]);  next_val = data[i]
            elseif next_val !== nothing;  data[i] = next_val  end
        end

    elseif method === :mean
        vals = [v for v in data if !ismissing(v)]
        isempty(vals) && return data
        μ = sum(vals) / length(vals)
        for i in 1:n;  ismissing(data[i]) && (data[i] = μ)  end

    elseif method === :linear
        obs = findall(!ismissing, data)
        isempty(obs) && return data
        # Edge fill
        for i in 1:(obs[1]-1);     data[i] = data[obs[1]]    end
        for i in (obs[end]+1):n;   data[i] = data[obs[end]]  end
        # Interior: use Interpolations.jl linear interpolation
        if length(obs) >= 2
            xf = Float64.(obs)
            yf = Float64.([data[i] for i in obs])
            itp = linear_interpolation(xf, yf)
            for i in 1:n
                if ismissing(data[i])
                    data[i] = T(itp(Float64(i)))
                end
            end
        end

    else
        throw(ArgumentError("Unknown method :$method. Choose :linear, :forward, :backward, or :mean."))
    end
    return data
end

end # module Interpolate
