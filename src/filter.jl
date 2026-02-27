module Filter

using DSP
using Statistics
using LinearAlgebra

export moving_average, exponential_smoothing, savitzky_golay,
       lowpass_filter, highpass_filter, bandpass_filter, bandstop_filter

# ---------------------------------------------------------------------------
# Moving average  (backed by DSP.jl convolution for centered result)
# ---------------------------------------------------------------------------

"""
    moving_average(data, window; causal=false) -> Vector

Compute a simple moving-average smooth with a rectangular (boxcar) window of
`window` points.

- `causal=false` (default) – centred window; output length equals input length,
  edges are handled by shrinking the window.
- `causal=true` – causal (one-sided) FIR filter via `DSP.filt`, introduces a
  delay of `⌊window/2⌋` samples.

Uses `DSP.conv` for the centred case and `DSP.filt` for the causal case.
"""
function moving_average(
    data::AbstractVector{T},
    window::Integer;
    causal::Bool = false,
)::Vector{float(T)} where {T<:Real}
    window >= 1 || throw(ArgumentError("window must be ≥ 1"))
    F = float(T)
    n = length(data)
    fd = F.(data)

    if causal
        b = fill(one(F) / F(window), window)
        return filt(b, [one(F)], fd)
    else
        # Centred via full convolution then trim
        kernel = fill(one(F) / F(window), window)
        c      = conv(fd, kernel)
        half   = (window - 1) ÷ 2
        return c[(half + 1):(half + n)]
    end
end

# Column-wise for matrices
function moving_average(
    data::AbstractMatrix{T},
    window::Integer;
    kwargs...,
)::Matrix{float(T)} where {T<:Real}
    mapreduce(
        j -> moving_average(view(data, :, j), window; kwargs...),
        hcat,
        1:size(data, 2),
    )
end

# ---------------------------------------------------------------------------
# Exponential smoothing  (simple / Holt's single exponential, pure Julia)
# ---------------------------------------------------------------------------

"""
    exponential_smoothing(data, alpha) -> Vector

Single (simple) exponential smoothing: `s_t = α·x_t + (1-α)·s_{t-1}`.
`alpha ∈ (0, 1]` – larger values give more weight to recent observations.
"""
function exponential_smoothing(
    data::AbstractVector{T},
    alpha::Real,
)::Vector{float(T)} where {T<:Real}
    0 < alpha <= 1 || throw(ArgumentError("alpha must be in (0, 1]"))
    F      = float(T)
    n      = length(data)
    result = Vector{F}(undef, n)
    result[1] = F(data[1])
    for i in 2:n
        result[i] = F(alpha * data[i] + (1 - alpha) * result[i-1])
    end
    return result
end

# ---------------------------------------------------------------------------
# Savitzky-Golay  (pure Julia – DSP.jl does not expose SG directly)
# ---------------------------------------------------------------------------

"""
    savitzky_golay(data, window, degree) -> Vector

Savitzky-Golay smoothing filter.  `window` must be odd and > `degree`.
Fits a polynomial of `degree` to each sliding window and returns the
centre value, smoothing noise while preserving higher moments.
"""
function savitzky_golay(
    data::AbstractVector{T},
    window::Integer,
    degree::Integer,
)::Vector{float(T)} where {T<:Real}
    isodd(window)  || throw(ArgumentError("window must be odd"))
    window > degree || throw(ArgumentError("window must be larger than degree"))
    window >= 1    || throw(ArgumentError("window must be ≥ 1"))

    F    = float(T)
    n    = length(data)
    half = window ÷ 2
    result = Vector{F}(undef, n)

    x_full   = F.((-half):half)
    V_full   = _vandermonde(x_full, degree)
    pinv_V   = pinv(V_full)

    for i in 1:n
        lo = i - half;  hi = i + half
        if lo >= 1 && hi <= n
            coeffs    = pinv_V * F.(view(data, lo:hi))
            result[i] = coeffs[1]
        else
            lo_c = max(1, lo);  hi_c = min(n, hi)
            x_w  = F.((lo_c:hi_c) .- i)
            y_w  = F.(view(data, lo_c:hi_c))
            V    = _vandermonde(x_w, min(degree, length(x_w) - 1))
            result[i] = (V \ y_w)[1]
        end
    end
    return result
end

function _vandermonde(x::AbstractVector{T}, degree::Integer)::Matrix{T} where {T<:Real}
    n = length(x)
    V = Matrix{T}(undef, n, degree + 1)
    for j in 1:(degree + 1);  V[:, j] = x .^ (j - 1)  end
    return V
end

# ---------------------------------------------------------------------------
# Butterworth filter wrappers  (DSP.jl digitalfilter + filtfilt)
# ---------------------------------------------------------------------------

"""
    lowpass_filter(data, cutoff; fs=2.0, order=4) -> Vector

Zero-phase Butterworth low-pass filter via `DSP.filtfilt`.

- `cutoff` – 3 dB cutoff frequency (same units as `fs`)
- `fs`     – sample rate (default 2.0 → normalised 0–1 range)
- `order`  – filter order (default 4)
"""
function lowpass_filter(
    data::AbstractVector{T},
    cutoff::Real;
    fs::Real    = 2.0,
    order::Integer = 4,
)::Vector{float(T)} where {T<:Real}
    f = digitalfilter(Lowpass(cutoff; fs = fs), Butterworth(order))
    return filtfilt(f, float.(data))
end

"""
    highpass_filter(data, cutoff; fs=2.0, order=4) -> Vector

Zero-phase Butterworth high-pass filter.
"""
function highpass_filter(
    data::AbstractVector{T},
    cutoff::Real;
    fs::Real       = 2.0,
    order::Integer = 4,
)::Vector{float(T)} where {T<:Real}
    f = digitalfilter(Highpass(cutoff; fs = fs), Butterworth(order))
    return filtfilt(f, float.(data))
end

"""
    bandpass_filter(data, lo, hi; fs=2.0, order=4) -> Vector

Zero-phase Butterworth band-pass filter passing frequencies `[lo, hi]`.
"""
function bandpass_filter(
    data::AbstractVector{T},
    lo::Real,
    hi::Real;
    fs::Real       = 2.0,
    order::Integer = 4,
)::Vector{float(T)} where {T<:Real}
    f = digitalfilter(Bandpass(lo, hi; fs = fs), Butterworth(order))
    return filtfilt(f, float.(data))
end

"""
    bandstop_filter(data, lo, hi; fs=2.0, order=4) -> Vector

Zero-phase Butterworth band-stop (notch) filter rejecting frequencies `[lo, hi]`.
"""
function bandstop_filter(
    data::AbstractVector{T},
    lo::Real,
    hi::Real;
    fs::Real       = 2.0,
    order::Integer = 4,
)::Vector{float(T)} where {T<:Real}
    f = digitalfilter(Bandstop(lo, hi; fs = fs), Butterworth(order))
    return filtfilt(f, float.(data))
end

end # module Filter
