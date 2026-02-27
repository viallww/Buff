using Test
using Buff
using PlotlyJS

@testset "Plots" begin
    y = rand(10)
    x = collect(1:10)
    
    @testset "plot_signal" begin
        p = plot_signal(y)
        @test p isa PlotlyJS.SyncPlot
        
        p2 = plot_signal(x, y)
        @test p2 isa PlotlyJS.SyncPlot
    end
    
    @testset "plot_comparison" begin
        p = plot_comparison(y, y)
        @test p isa PlotlyJS.SyncPlot
        
        p2 = plot_comparison(x, y, x, y)
        @test p2 isa PlotlyJS.SyncPlot
    end
    
    @testset "plot_regression" begin
        p = plot_regression(x, y, y)
        @test p isa PlotlyJS.SyncPlot
    end
end
