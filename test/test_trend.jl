using Test
using Buff

@testset "Trend" begin
    x = Float64[1, 2, 3, 4, 5]
    y = 2.0 .* x .+ 1.0   # perfect line: slope=2, intercept=1

    @testset "linear_regression perfect line" begin
        res = linear_regression(x, y)
        @test res.slope     ≈ 2.0  atol = 1e-10
        @test res.intercept ≈ 1.0  atol = 1e-10
        @test res.r_squared ≈ 1.0  atol = 1e-10
        @test res.y_fit     ≈ y    atol = 1e-10
    end

    @testset "linear_regression y-only dispatch" begin
        res = linear_regression(y)
        @test res.r_squared ≈ 1.0 atol = 1e-8
    end

    @testset "linear_regression dimension mismatch" begin
        @test_throws DimensionMismatch linear_regression(x, y[1:end-1])
    end

    @testset "polynomial_regression degree 1 matches linear" begin
        res = polynomial_regression(x, y, 1)
        @test res.r_squared ≈ 1.0 atol = 1e-10
    end

    @testset "polynomial_regression quadratic" begin
        xq = Float64[1, 2, 3, 4, 5]
        yq = xq .^ 2
        res = polynomial_regression(xq, yq, 2)
        @test res.r_squared ≈ 1.0  atol = 1e-8
        @test res.y_fit     ≈ yq   atol = 1e-6
    end

    @testset "polynomial_regression bad args" begin
        @test_throws ArgumentError polynomial_regression(x, y, 0)
        @test_throws ArgumentError polynomial_regression(x, y, 10)  # more than data
    end

    @testset "detrend linear residual near zero" begin
        res = detrend(y; method = :linear)
        @test res ≈ zeros(length(y)) atol = 1e-8
    end

    @testset "detrend mean" begin
        d = [1.0, 2.0, 3.0, 4.0, 5.0]
        res = detrend(d; method = :mean)
        @test sum(res) ≈ 0.0 atol = 1e-10
    end

    @testset "detrend polynomial" begin
        xq = Float64[1, 2, 3, 4, 5]
        yq = xq .^ 2
        res = detrend(yq; method = :polynomial, degree = 2)
        @test res ≈ zeros(5) atol = 1e-8
    end

    @testset "detrend unknown method" begin
        @test_throws ArgumentError detrend(y; method = :unknown)
    end
end
