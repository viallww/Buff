using Test
using Statistics
using Buff

@testset "Outliers" begin
    data = [1.0, 2.0, 3.0, 100.0, 4.0, 5.0]

    @testset "detect_outliers zscore" begin
        mask = detect_outliers(data; method = :zscore, threshold = 2.0)
        @test mask[4] == true
        @test sum(mask) == 1
    end

    @testset "detect_outliers iqr" begin
        mask = detect_outliers(data; method = :iqr, threshold = 1.5)
        @test mask[4] == true
    end

    @testset "detect_outliers modified_zscore" begin
        mask = detect_outliers(data; method = :modified_zscore, threshold = 3.5)
        @test mask[4] == true
    end

    @testset "remove_outliers drops elements" begin
        cleaned = remove_outliers(data; method = :zscore, threshold = 2.0)
        @test length(cleaned) == 5
        @test !(100.0 in cleaned)
    end

    @testset "remove_outliers replace_with_missing" begin
        cleaned = remove_outliers(data; method = :zscore, threshold = 2.0,
                                  replace_with_missing = true)
        @test length(cleaned) == 6
        @test ismissing(cleaned[4])
    end

    @testset "winsorize" begin
        w = winsorize([1.0, 2.0, 3.0, 4.0, 5.0, 100.0]; limits = (0.0, 0.8))
        @test maximum(w) <= quantile([1.0, 2.0, 3.0, 4.0, 5.0, 100.0], 0.8)
    end

    @testset "detect_outliers constant data" begin
        mask = detect_outliers(ones(10); method = :zscore)
        @test !any(mask)
    end

    @testset "detect_outliers unknown method" begin
        @test_throws ArgumentError detect_outliers(data; method = :unknown)
    end

    @testset "detect_outliers matrix" begin
        mat = [1.0 100.0; 2.0 2.0; 3.0 3.0]
        mask = detect_outliers(mat; method = :zscore, threshold = 1.0)
        @test mask[1, 2] == true
        @test size(mask) == size(mat)
    end

    @testset "type stability" begin
        result = remove_outliers(Int[1, 2, 3, 200, 4])
        @test eltype(result) == Int
    end
end
