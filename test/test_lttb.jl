using Test
using Buff

@testset "LTTB" begin
    n = 100
    x = collect(Float64, 1:n)
    y = sin.(x .* 0.3)

    @testset "output length matches n_out" begin
        x_out, y_out = lttb(x, y, 20)
        @test length(x_out) == 20
        @test length(y_out) == 20
    end

    @testset "first and last points preserved" begin
        x_out, y_out = lttb(x, y, 20)
        @test x_out[1]   == x[1]   && y_out[1]   == y[1]
        @test x_out[end] == x[end] && y_out[end] == y[end]
    end

    @testset "y-only dispatch" begin
        x_out, y_out = lttb(y, 20)
        @test length(y_out) == 20
        @test y_out[1] == y[1]
    end

    @testset "no downsample when n_out >= n" begin
        x_out, y_out = lttb(x, y, n)
        @test length(y_out) == n
        @test y_out == y
    end

    @testset "output is subset of original data" begin
        x_out, y_out = lttb(x, y, 10)
        # Each output point should be one of the original x values
        for xo in x_out
            @test xo in x
        end
    end

    @testset "invalid n_out" begin
        @test_throws ArgumentError lttb(x, y, 1)
    end

    @testset "dimension mismatch" begin
        @test_throws DimensionMismatch lttb(x, y[1:end-1], 10)
    end

    @testset "type stability – Float32 input" begin
        x32 = Float32.(x)
        y32 = Float32.(y)
        x_out, y_out = lttb(x32, y32, 15)
        @test eltype(x_out) == Float32
        @test eltype(y_out) == Float32
    end
end
