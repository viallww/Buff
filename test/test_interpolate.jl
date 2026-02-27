using Test
using Buff

@testset "Interpolate" begin
    x = [0.0, 1.0, 2.0, 3.0, 4.0]
    y = [0.0, 1.0, 0.0, 1.0, 0.0]

    @testset "interpolate_linear exact nodes" begin
        y_hat = interpolate_linear(x, y, x)
        @test y_hat ≈ y
    end

    @testset "interpolate_linear midpoints" begin
        y_hat = interpolate_linear(x, y, [0.5, 1.5, 2.5])
        @test y_hat ≈ [0.5, 0.5, 0.5]
    end

    @testset "interpolate_linear extrapolation clamped" begin
        y_hat = interpolate_linear(x, y, [-1.0, 5.0])
        @test y_hat[1] == y[1]
        @test y_hat[2] == y[end]
    end

    @testset "interpolate_linear y-only dispatch" begin
        y2 = [0.0, 2.0, 4.0]
        y_hat = interpolate_linear(y2, [1.5, 2.5])
        @test y_hat ≈ [1.0, 3.0]
    end

    @testset "interpolate_cubic exact nodes" begin
        y3 = [0.0, 1.0, 4.0, 9.0, 16.0]  # x^2
        y_hat = interpolate_cubic(x, y3, x)
        @test y_hat ≈ y3 atol = 1e-10
    end

    @testset "interpolate_cubic smooth" begin
        xc = collect(0.0:0.5:4.0)
        yc = xc .^ 2
        y_hat = interpolate_cubic(xc, yc, [1.25, 2.75])
        @test y_hat[1] ≈ 1.25^2 atol = 0.05
        @test y_hat[2] ≈ 2.75^2 atol = 0.05
    end

    @testset "fill_missing linear" begin
        v = [1.0, missing, missing, 4.0]
        filled = fill_missing(v; method = :linear)
        @test filled ≈ [1.0, 2.0, 3.0, 4.0]
    end

    @testset "fill_missing forward" begin
        v = [1.0, missing, missing, 4.0]
        filled = fill_missing(v; method = :forward)
        @test filled ≈ [1.0, 1.0, 1.0, 4.0]
    end

    @testset "fill_missing backward" begin
        v = [1.0, missing, missing, 4.0]
        filled = fill_missing(v; method = :backward)
        @test filled ≈ [1.0, 4.0, 4.0, 4.0]
    end

    @testset "fill_missing mean" begin
        v = [1.0, missing, 3.0]
        filled = fill_missing(v; method = :mean)
        @test filled[2] ≈ 2.0
    end

    @testset "fill_missing unknown method" begin
        v = [1.0, missing, 3.0]
        @test_throws ArgumentError fill_missing(v; method = :unknown)
    end
end
