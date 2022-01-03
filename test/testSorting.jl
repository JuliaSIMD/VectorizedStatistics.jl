## --- Test sorting functions directly

    A = rand(100)

    # SortNaNs
    B, iₗ, iᵤ = VectorizedStatistics.sortnans!(copy(A))
    @test B == A
    @test (iₗ, iᵤ) == (1, 100)

    # Quicksort
    VectorizedStatistics.quicksort!(A)
    sort!(B)
    @test A == B

    A = rand(10_000)
    B = sort(A)
    VectorizedStatistics.quicksort!(A)
    @test A == B

    # Multithreaded quicksort
    A = rand(100)
    B = sort(A)
    VectorizedStatistics.quicksortt!(A)
    @test A == B

    A = rand(10_000)
    B = sort(A)
    VectorizedStatistics.quicksortt!(A)
    @test A == B

    # Partialsort
    A = rand(101)
    m = median(A)
    VectorizedStatistics.quickselect!(A, 1, 101, 51)
    @test A[51] == m

    # Quicksort of already-sorted arrays
    @test VectorizedStatistics.quicksort!(collect(1:100)) == 1:100
    @test VectorizedStatistics.quicksort!(collect(100:-1:1)) == 1:100
    @test VectorizedStatistics.quicksortt!(collect(1:100)) == 1:100
    @test VectorizedStatistics.quicksortt!(collect(100:-1:1)) == 1:100

    # Test quicksort of some potentially pathological cases
    @test VectorizedStatistics.quicksort!(abs.(-50:50)) == sort(abs.(-50:50))
    @test VectorizedStatistics.quicksortt!(abs.(-50:50)) == sort(abs.(-50:50))

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

    @test vmedian!(0:10) == 5
    @test vmedian!(1:10) == 5.5

    A = rand(100)
    @test vmedian!(copy(A)) == median(A)
    A = rand(10_000)
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

## --- Test vpercentile! / vquantile!

    @test vpercentile!(0:10, 0) == 0
    @test vpercentile!(0:10, 1) ≈ 0.1
    @test vpercentile!(0:10, 100) == 10
    @test vpercentile!(0:10, 13.582) ≈ 1.3582
    @test vpercentile!(collect(1:10), 50) == 5.5

    A = rand(100)
    @test vpercentile!(copy(A), 50) == median(A)
    A = rand(10_000)
    @test vpercentile!(copy(A), 50) == median(A)

    A = rand(55,82)
    @test vpercentile!(copy(A), 50) == median(A)
    @test vpercentile!(copy(A), 50, dims=1) == median(A, dims=1)
    @test vpercentile!(copy(A), 50, dims=2) == median(A, dims=2)

    A = rand(10,11,12)
    @test vpercentile!(copy(A), 50) == median(A)
    @test vpercentile!(copy(A), 50, dims=1) == median(A, dims=1)
    @test vpercentile!(copy(A), 50, dims=2) == median(A, dims=2)
    @test vpercentile!(copy(A), 50, dims=3) == median(A, dims=3)
    @test vpercentile!(copy(A), 50, dims=(1,2)) == median(A, dims=(1,2))
    @test vpercentile!(copy(A), 50, dims=(2,3)) == median(A, dims=(2,3))

    A = rand(100)
    @test median(A) == vpercentile!(copy(A), 50) == vquantile!(copy(A), 0.5)
    @test vpercentile!(copy(A), 50) == vquantile!(copy(A), 0.5)

## ---
