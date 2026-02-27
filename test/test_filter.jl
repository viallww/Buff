using Test
using Buff

@testset "Filter" begin
    data = Float64[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    @testset "moving_average window=1 identity" begin
        result = moving_average(data, 1)
        @test result ≈ data
    end

    @testset "moving_average window=3 interior" begin
        result = moving_average(data, 3)
        # Interior values should be average of three consecutive elements
        @test result[5] ≈ (4 + 5 + 6) / 3
    end

    @testset "moving_average length preserved" begin
        result = moving_average(data, 5)
        @test length(result) == length(data)
    end

    @testset "moving_average causal" begin
        result = moving_average(data, 3; causal = true)
        @test length(result) == length(data)
    end

    @testset "moving_average bad window" begin
        @test_throws ArgumentError moving_average(data, 0)
    end

    @testset "exponential_smoothing alpha=1 identity" begin
        result = exponential_smoothing(data, 1.0)
        @test result ≈ data
    end

    @testset "exponential_smoothing alpha=0.5" begin
        result = exponential_smoothing([1.0, 1.0, 1.0], 0.5)
        @test result ≈ [1.0, 1.0, 1.0]
    end

    @testset "exponential_smoothing bad alpha" begin
        @test_throws ArgumentError exponential_smoothing(data, 0.0)
        @test_throws ArgumentError exponential_smoothing(data, 1.5)
    end

    @testset "savitzky_golay constant signal" begin
        const_data = fill(5.0, 20)
        result = savitzky_golay(const_data, 5, 2)
        @test result ≈ const_data atol = 1e-8
    end

    @testset "savitzky_golay linear signal" begin
        lin = collect(1.0:20.0)
        result = savitzky_golay(lin, 5, 2)
        @test result ≈ lin atol = 0.2
    end

    @testset "savitzky_golay bad args" begin
        @test_throws ArgumentError savitzky_golay(data, 4, 2)  # even window
        @test_throws ArgumentError savitzky_golay(data, 3, 3)  # window == degree
    end

    @testset "lowpass_filter output length" begin
        sig = sin.(2π .* collect(0:0.01:1))
        result = lowpass_filter(sig, 0.4; fs = 1.0, order = 2)
        @test length(result) == length(sig)
    end

    @testset "highpass_filter output length" begin
        sig = sin.(2π .* collect(0:0.01:1))
        result = highpass_filter(sig, 0.1; fs = 1.0, order = 2)
        @test length(result) == length(sig)
    end

    @testset "bandpass_filter output length" begin
        sig = sin.(2π .* collect(0:0.01:1))
        result = bandpass_filter(sig, 0.1, 0.4; fs = 1.0, order = 2)
        @test length(result) == length(sig)
    end

    @testset "lowpass_filter removes high freq" begin
        t   = 0:0.001:1
        low_f  = sin.(2π .* 1.0 .* collect(t))   # 1 Hz
        high_f = sin.(2π .* 40.0 .* collect(t))  # 40 Hz
        mixed  = low_f .+ high_f
        # Low-pass at 10 Hz (fs=100) should mostly preserve the 1 Hz component
        result = lowpass_filter(mixed, 10.0; fs = 100.0, order = 4)
        @test maximum(abs.(result .- low_f)) < 0.1
    end

    @testset "moving_average integer input – float output" begin
        result = moving_average(Int[1, 2, 3, 4, 5], 3)
        @test eltype(result) <: AbstractFloat
    end
end
