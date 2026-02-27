# Initial Concept

**Buff.jl** is a high-performance Julia package providing a unified, type-stable, multiple-dispatch API for signal processing. It wraps best-in-class libraries (DSP.jl, StatsBase.jl, Interpolations.jl) and offers optional, instant visualization via PlotlyJS.

# Product Guide

## Vision
To be the standard, easy-to-use "Swiss Army Knife" for signal processing in Julia, offering a consistent and performant interface for common tasks like outlier detection, interpolation, filtering, and downsampling.

## Target Users
- Data scientists and researchers working with time-series data.
- Engineers needing robust signal processing for real-time or offline analysis.
- Julia developers looking for a simplified, high-level API over complex signal processing libraries.

## Key Features
- **Outlier Detection & Removal:** Support for Z-score, MAD, IQR, and Winsorization.
- **Interpolation & Missing Value Filling:** Linear and cubic spline interpolation with support for non-uniform grids.
- **Filtering:** High-level access to Butterworth filters, moving averages, Savitzky-Golay, and exponential smoothing.
- **LTTB Downsampling:** Fast, visually-representative downsampling for large datasets.
- **Upsampling:** Linear and nearest-neighbour upsampling.
- **Trend & Regression:** Linear and polynomial regression with built-in detrending tools.
- **Visualization:** Integrated, interactive PlotlyJS plots for all transforms.

## Core Values
- **Type Stability:** Ensuring high performance by adhering to Julia's type-inference rules.
- **Multiple Dispatch:** Providing flexible APIs that adapt to different input formats (e.g., vectors, x-y pairs).
- **Ease of Use:** A "batteries-included" feel with sensible defaults and optional visualization.
- **Composability:** Designed to work seamlessly with other Julia packages and the broader data ecosystem.
