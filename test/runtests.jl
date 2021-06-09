using Test
using Statistics
using VectorizedStatistics

@testset "Vreducibles" begin include("testVreducibles.jl") end
@testset "ArrayStats" begin include("testArrayStats.jl") end
