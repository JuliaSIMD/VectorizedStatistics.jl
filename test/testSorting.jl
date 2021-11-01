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
B = vsort(A, multithreaded=false)
@test issorted(B)
A = rand(100)
B = vsort(A, multithreaded=true)
@test issorted(B)

# Vsort, Int64
A = rand(Int, 100)
B = vsort(A, multithreaded=false)
@test issorted(B)
A = rand(Int, 100)
B = vsort(A, multithreaded=true)
@test issorted(B)
