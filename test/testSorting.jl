# Test sorting functions
A = rand(100)

# SortNaNs
B, iₗ, iᵤ = VectorizedStatistics.sortnans!(copy(A))
@test B == A
@test (iₗ, iᵤ) == (1, 100)

# Quicksort
VectorizedStatistics.quicksort!(A)
@test Base.issorted(A)
VectorizedStatistics.quicksortt!(B)
@test Base.issorted(B)

# Partialsort
A = rand(101)
m = median(A)
VectorizedStatistics.partialquicksort!(A, 1, 101, 51)
@test A[51] == m
