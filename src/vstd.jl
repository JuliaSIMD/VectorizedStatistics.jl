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
vstd(A; dim=:, dims=:, mean=nothing, corrected=true, multithreaded=False()) = _vstd(mean, corrected, A, dim, dims, multithreaded)
export vstd
_vstd(mean, corrected, A, ::Colon, ::Colon, multithreaded) = _vstd(mean, corrected, A, :, multithreaded)
_vstd(mean, corrected, A, ::Colon, region, multithreaded) = _vstd(mean, corrected, A, region, multithreaded)
_vstd(mean, corrected, A, region, ::Colon, multithreaded) = reducedims(_vstd(mean, corrected, A, region, multithreaded), region)
_vstd(mean, corrected, A, dims, multithreaded) = sqrt!(_vvar(mean, corrected, A, dims, multithreaded), multithreaded)

sqrt!(x, multithreaded::Symbol) = sqrt!(x, (multithreaded===:auto && length(A) > 4095) ? True() : False())
sqrt!(x, multithreaded::Bool) = sqrt!(x, static(multithreaded))
sqrt!(x::Number, multithreaded::StaticBool) = sqrt(x)
function sqrt!(A::AbstractArray, multithreaded::False)
    @turbo for i ∈ eachindex(A)
        A[i] = sqrt(A[i])
    end
    return A
end
function sqrt!(A::AbstractArray, multithreaded::True)
    @tturbo for i ∈ eachindex(A)
        A[i] = sqrt(A[i])
    end
    return A
end
