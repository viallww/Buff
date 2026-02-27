using Test
using Buff

@testset "Upsample" begin
    x = [0.0, 1.0, 2.0, 3.0, 4.0]
    y = [0.0, 1.0, 2.0, 3.0, 4.0]  # linear signal

    @testset "upsample_linear factor=1 identity" begin
        x_new, y_new = upsample_linear(x, y, 1)
        @test x_new ≈ x
        @test y_new ≈ y
    end

    @testset "upsample_linear factor=2 midpoints" begin
        x_new, y_new = upsample_linear(x, y, 2)
        @test length(y_new) == (length(y) - 1) * 2 + 1
        # Midpoints should be half-way between neighbours
        @test y_new[2] ≈ 0.5
    end

    @testset "upsample_linear preserves endpoints" begin
        x_new, y_new = upsample_linear(x, y, 4)
        @test y_new[1]   ≈ y[1]
        @test y_new[end] ≈ y[end]
    end

    @testset "upsample_linear y-only dispatch" begin
        y_new = upsample_linear(y, 2)
        @test length(y_new) == (length(y) - 1) * 2 + 1
    end

    @testset "upsample_linear with explicit x_new" begin
        x_req = [0.5, 1.5, 2.5]
        x_new, y_new = upsample_linear(x, y, x_req)
        @test y_new ≈ x_req  # linear signal → y == x
    end

    @testset "upsample_nearest factor=2" begin
        x_new, y_new = upsample_nearest(x, y, 2)
        @test length(y_new) == (length(y) - 1) * 2 + 1
        @test y_new[1] ≈ y[1]
        @test y_new[end] ≈ y[end]
    end

    @testset "upsample_nearest y-only dispatch" begin
        y_new = upsample_nearest(y, 2)
        @test length(y_new) == (length(y) - 1) * 2 + 1
    end

    @testset "upsample bad factor" begin
        @test_throws ArgumentError upsample_linear(x, y, 0)
        @test_throws ArgumentError upsample_nearest(x, y, 0)
    end

    @testset "dimension mismatch" begin
        @test_throws DimensionMismatch upsample_linear(x, y[1:end-1], 2)
    end
end
