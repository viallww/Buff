module Plots

using PlotlyJS

export plot_signal, plot_comparison, plot_regression

"""
    plot_signal(y; title="Signal", xlabel="Index", ylabel="Value")

Create a PlotlyJS scatter plot for a single signal `y`.
"""
function plot_signal(
    y::AbstractVector{<:Real};
    title::AbstractString = "Signal",
    xlabel::AbstractString = "Index",
    ylabel::AbstractString = "Value",
    name::AbstractString = "signal",
    mode::AbstractString = "lines+markers",
)::PlotlyJS.SyncPlot
    x = collect(1:length(y))
    trace = scatter(; x = x, y = y, mode = mode, name = name)
    layout = Layout(; title = title, xaxis_title = xlabel, yaxis_title = ylabel)
    return plot(trace, layout)
end

function plot_signal(
    x::AbstractVector{<:Real},
    y::AbstractVector{<:Real};
    title::AbstractString = "Signal",
    xlabel::AbstractString = "x",
    ylabel::AbstractString = "y",
    name::AbstractString = "signal",
    mode::AbstractString = "lines+markers",
)::PlotlyJS.SyncPlot
    trace = scatter(; x = x, y = y, mode = mode, name = name)
    layout = Layout(; title = title, xaxis_title = xlabel, yaxis_title = ylabel)
    return plot(trace, layout)
end

"""
    plot_comparison(x_orig, y_orig, x_new, y_new; title, labels)

Overlay two signals (e.g. original vs processed) in a single PlotlyJS figure.
"""
function plot_comparison(
    x_orig::AbstractVector{<:Real},
    y_orig::AbstractVector{<:Real},
    x_new::AbstractVector{<:Real},
    y_new::AbstractVector{<:Real};
    title::AbstractString = "Comparison",
    xlabel::AbstractString = "x",
    ylabel::AbstractString = "y",
    label_orig::AbstractString = "original",
    label_new::AbstractString = "processed",
)::PlotlyJS.SyncPlot
    t1 = scatter(; x = x_orig, y = y_orig, mode = "lines", name = label_orig,
                   line = attr(color = "royalblue", width = 1))
    t2 = scatter(; x = x_new, y = y_new, mode = "markers", name = label_new,
                   marker = attr(color = "crimson", size = 6))
    layout = Layout(; title = title, xaxis_title = xlabel, yaxis_title = ylabel)
    return plot([t1, t2], layout)
end

function plot_comparison(
    y_orig::AbstractVector{<:Real},
    y_new::AbstractVector{<:Real};
    kwargs...,
)::PlotlyJS.SyncPlot
    x_orig = collect(1:length(y_orig))
    x_new = collect(1:length(y_new))
    return plot_comparison(x_orig, y_orig, x_new, y_new; kwargs...)
end

"""
    plot_regression(x, y, y_fit; title, labels)

Scatter the raw data and overlay the fitted regression line.
"""
function plot_regression(
    x::AbstractVector{<:Real},
    y::AbstractVector{<:Real},
    y_fit::AbstractVector{<:Real};
    title::AbstractString = "Regression",
    xlabel::AbstractString = "x",
    ylabel::AbstractString = "y",
)::PlotlyJS.SyncPlot
    t_data = scatter(; x = x, y = y, mode = "markers", name = "data",
                      marker = attr(color = "steelblue", size = 5))
    t_fit = scatter(; x = x, y = y_fit, mode = "lines", name = "fit",
                     line = attr(color = "firebrick", width = 2))
    layout = Layout(; title = title, xaxis_title = xlabel, yaxis_title = ylabel)
    return plot([t_data, t_fit], layout)
end

end # module Plots
