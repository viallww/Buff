using Test

@testset "Buff" begin
    include("test_outliers.jl")
    include("test_interpolate.jl")
    include("test_filter.jl")
    include("test_lttb.jl")
    include("test_upsample.jl")
    include("test_trend.jl")
end
