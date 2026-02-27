module Trend

using Statistics
using LinearAlgebra

export linear_regression, polynomial_regression, detrend

# ---------------------------------------------------------------------------
# Linear regression
# ---------------------------------------------------------------------------

"""
    linear_regression(x, y; plot=false) -> NamedTuple

Ordinary least-squares fit `y ≈ slope·x + intercept`.

Returns `(slope, intercept, r_squared, y_fit)`.
"""
function linear_regression(
    x::AbstractVector{Tx},
    y::AbstractVector{Ty};
    plot::Bool = false,
) where {Tx<:Real,Ty<:Real}
    length(x) == length(y) || throw(DimensionMismatch("x and y must have the same length"))
    length(x) >= 2          || throw(ArgumentError("Need at least 2 points"))

    F = float(promote_type(Tx, Ty))
    xf = F.(x)
    yf = F.(y)

    n   = length(xf)
    x̄   = mean(xf)
    ȳ   = mean(yf)
    Sxx = sum((xi - x̄)^2 for xi in xf)
    Sxy = sum((xf[i] - x̄) * (yf[i] - ȳ) for i in 1:n)

    slope     = Sxy / Sxx
    intercept = ȳ - slope * x̄
    y_fit     = slope .* xf .+ intercept

    ss_res = sum((yf[i] - y_fit[i])^2 for i in 1:n)
    ss_tot = sum((yf[i] - ȳ)^2       for i in 1:n)
    r2     = ss_tot ≈ 0 ? one(F) : 1 - ss_res / ss_tot

    if plot
        _show_regression_plot(xf, yf, y_fit, "Linear Regression")
    end
    return (slope = slope, intercept = intercept, r_squared = r2, y_fit = y_fit)
end

# Convenience: 1-D (use integer indices as x)
function linear_regression(
    y::AbstractVector{T};
    kwargs...,
) where {T<:Real}
    x = collect(1:length(y))
    return linear_regression(x, y; kwargs...)
end

# ---------------------------------------------------------------------------
# Polynomial regression
# ---------------------------------------------------------------------------

"""
    polynomial_regression(x, y, degree; plot=false) -> NamedTuple

Fit a degree-`d` polynomial `y ≈ ∑ cₖ xᵏ` via QR-decomposed least squares.

Returns `(coefficients, r_squared, y_fit)` where `coefficients[k]` is the
coefficient of `x^(k-1)`.
"""
function polynomial_regression(
    x::AbstractVector{Tx},
    y::AbstractVector{Ty},
    degree::Integer;
    plot::Bool = false,
) where {Tx<:Real,Ty<:Real}
    length(x) == length(y) || throw(DimensionMismatch("x and y must have the same length"))
    degree >= 1              || throw(ArgumentError("degree must be ≥ 1"))
    length(x) > degree       || throw(ArgumentError("Need more data points than polynomial degree"))

    F = float(promote_type(Tx, Ty))
    xf = F.(x)
    yf = F.(y)

    # Vandermonde matrix
    V = Matrix{F}(undef, length(xf), degree + 1)
    for j in 1:(degree+1)
        V[:, j] = xf .^ (j - 1)
    end
    coeffs = V \ yf
    y_fit  = V * coeffs

    ȳ      = mean(yf)
    ss_res = sum((yf[i] - y_fit[i])^2 for i in eachindex(yf))
    ss_tot = sum((yf[i] - ȳ)^2        for i in eachindex(yf))
    r2     = ss_tot ≈ 0 ? one(F) : 1 - ss_res / ss_tot

    if plot
        _show_regression_plot(xf, yf, y_fit, "Polynomial Regression (degree $degree)")
    end
    return (coefficients = coeffs, r_squared = r2, y_fit = y_fit)
end

# ---------------------------------------------------------------------------
# Detrend
# ---------------------------------------------------------------------------

"""
    detrend(data; method=:linear, degree=1) -> Vector

Remove the trend from `data`.

## Methods
- `:linear`     – subtract best-fit line
- `:polynomial` – subtract best-fit polynomial of `degree`
- `:mean`       – subtract the mean
"""
function detrend(
    data::AbstractVector{T};
    method::Symbol = :linear,
    degree::Integer = 1,
    plot::Bool = false,
) where {T<:Real}
    F = float(T)
    x = collect(F, 1:length(data))
    y = F.(data)

    if method === :mean
        trend = fill(mean(y), length(y))
    elseif method === :linear
        res = linear_regression(x, y)
        trend = res.y_fit
    elseif method === :polynomial
        res = polynomial_regression(x, y, degree)
        trend = res.y_fit
    else
        throw(ArgumentError("Unknown method :$method. Choose :linear, :polynomial, or :mean."))
    end

    residual = y .- trend

    if plot
        _show_detrend_plot(x, y, trend, residual, method)
    end
    return residual
end

# ---------------------------------------------------------------------------
# Internal plot helpers
# ---------------------------------------------------------------------------
function _show_regression_plot(x, y, y_fit, title_str)
    buff_mod = Base.moduleroot(parentmodule(Trend))
    plots_mod = getfield(buff_mod, :Plots)
    p = plots_mod.plot_regression(
        collect(Float64, x),
        collect(Float64, y),
        collect(Float64, y_fit);
        title = title_str,
    )
    display(p)
    return p
end

function _show_detrend_plot(x, y, trend, residual, method)
    buff_mod = Base.moduleroot(parentmodule(Trend))
    plots_mod = getfield(buff_mod, :Plots)
    p = plots_mod.plot_comparison(
        collect(Float64, x),
        collect(Float64, y),
        collect(Float64, x),
        collect(Float64, residual);
        title      = "Detrend (:$method)",
        label_orig = "original",
        label_new  = "detrended",
    )
    display(p)
    return p
end

end # module Trend
