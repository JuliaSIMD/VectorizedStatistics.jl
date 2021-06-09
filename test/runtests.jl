using Test
using Statistics
using VectorizedStatistics

using VectorizationBase
VectorizationBase.vsum(x::Float64) = x

@testset "Vreducibles" begin include("testVreducibles.jl") end
@testset "ArrayStats" begin include("testArrayStats.jl") end
