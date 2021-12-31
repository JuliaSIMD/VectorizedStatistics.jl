# Test sorting functions
A = rand(100)

# SortNaNs
B, iₗ, iᵤ = VectorizedStatistics.sortnans!(copy(A))
@test B == A
@test (iₗ, iᵤ) == (1, 100)

# Quicksort
VectorizedStatistics.quicksort!(A)
sort!(B)
@test A == B

# Multithreaded quicksort
A = rand(100)
B = copy(A)
VectorizedStatistics.quicksortt!(A)
sort!(B)
@test A == B

# Partialsort
A = rand(101)
m = median(A)
VectorizedStatistics.partialquicksort!(A, 1, 101, 51)
@test A[51] == m

# Vsort, Float64
A = rand(100)
B = VectorizedStatistics.vsort(A, multithreaded=false)
@test issorted(B)
A = rand(100)
B = VectorizedStatistics.vsort(A, multithreaded=true)
@test issorted(B)

# Vsort, Int64
A = rand(Int, 100)
B = VectorizedStatistics.vsort(A, multithreaded=false)
@test issorted(B)
A = rand(Int, 100)
B = VectorizedStatistics.vsort(A, multithreaded=true)
@test issorted(B)

## --- Test vmedian!

    A = rand(100)
    @test vmedian!(copy(A)) == median(A)

    A = rand(55,82)
    @test vmedian!(copy(A)) == median(A)
    @test vmedian!(copy(A), dims=1) == median(A, dims=1)
    @test vmedian!(copy(A), dims=2) == median(A, dims=2)

    A = rand(10,11,12)
    @test vmedian!(copy(A)) == median(A)
    @test vmedian!(copy(A), dims=1) == median(A, dims=1)
    @test vmedian!(copy(A), dims=2) == median(A, dims=2)
    @test vmedian!(copy(A), dims=3) == median(A, dims=3)
    @test vmedian!(copy(A), dims=(1,2)) == median(A, dims=(1,2))
    @test vmedian!(copy(A), dims=(2,3)) == median(A, dims=(2,3))


## ---
