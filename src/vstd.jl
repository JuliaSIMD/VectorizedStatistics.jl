"""
```julia
vstd(A; dims=:, mean=nothing, corrected=true, multithreaded=false)
```
Compute the variance of all elements in `A`, optionally over dimensions specified by `dims`.
As `Statistics.var`, but vectorized and (optionally) multithreaded.

A precomputed `mean` may optionally be provided, which results in a somewhat faster
calculation. If `corrected` is `true`, then _Bessel's correction_ is applied, such
that the sum is divided by `n-1` rather than `n`.

## Examples
```julia
julia> using VectorizedStatistics

julia> A = [1 2; 3 4]
2×2 Matrix{Int64}:
 1  2
 3  4

julia> vstd(A, dims=1)
1×2 Matrix{Float64}:
 1.41421  1.41421

julia> vstd(A, dims=2)
2×1 Matrix{Float64}:
 0.7071067811865476
 0.7071067811865476
```
"""
function vstd(A; dims=:, mean=nothing, corrected=true, multithreaded=false)
    if (multithreaded===:auto && length(A) > 4095) || multithreaded===true
        _vtstd(mean, corrected, A, dims)
    else
        _vstd(mean, corrected, A, dims)
    end
end
export vstd

sqrt!(x::Number) = sqrt(x)
function sqrt!(A::AbstractArray)
    @turbo for i ∈ eachindex(A)
        A[i] = sqrt(A[i])
    end
    return A
end

_vstd(mean, corrected, A, dims) = sqrt!(_vvar(mean, corrected, A, dims))

sqrtt!(x::Number) = sqrt(x)
function sqrtt!(A::AbstractArray)
    @tturbo for i ∈ eachindex(A)
        A[i] = sqrt(A[i])
    end
    return A
end

_vtstd(mean, corrected, A, dims) = sqrtt!(_vtvar(mean, corrected, A, dims))
