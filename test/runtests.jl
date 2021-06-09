using SafeTestsets

@safetestset "Vreducibles" begin include("testVreducibles.jl") end
@safetestset "ArrayStats" begin include("testArrayStats.jl") end
