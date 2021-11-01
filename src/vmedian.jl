"""
```julia
vmedian(A; dims, multithreaded=:auto)
```
Compute the median of all elements in `A`, optionally over dimensions specified by `dims`.
As `Statistics.median`, but vectorized and (optionally) multithreaded.

## Examples
```julia
julia> using VectorizedStatistics

julia> A = [1 2 3; 4 5 6; 7 8 9]
3×3 Matrix{Int64}:
 1  2  3
 4  5  6
 7  8  9

julia> vmedian(A, dims=1)
# not implemented yet

julia> vmedian(A, dims=2)
# not implemented yet
```
"""
vmedian(A; dims=:) = _vmedian!(copy(A), dims)
export vmedian

"""
```julia
vmedian!(A; dims, multithreaded=:auto)
```
As `vmedian` but will partially sort `A` around the median (using either
`quicksort!` or `partialquicksort!` depending on the size of the array).
"""
vmedian!(A; dims=:) = _vmedian!(A, dims)
export vmedian!

# Reduce one dim
_vmedian!(A, dims::Int) = _vmedian!(A, (dims,))

# Reduce some dims
function _vmedian!(A::AbstractArray{T,N}, dims::Tuple) where {T,N}
    sᵢ = size(A)
    sₒ = ntuple(Val(N)) do d
        ifelse(d ∈ dims, 1, sᵢ[d])
    end
    Tₒ = Base.promote_op(/, T, Int)
    B = similar(A, Tₒ, sₒ)
    _vmedian!(B, A, dims)
end

# Reduce all the dims!
function _vmedian!(A, ::Colon)
    iₗ, iᵤ = firstindex(A), lastindex(A)
    A, iₗ, iᵤ₋ = sortnans!(A, iₗ, iᵤ)
    if iᵤ₋ < iᵤ
        # Remove this if we'd rather ignore NaNs
        return A[iᵤ]
    end
    N = iᵤ - iₗ + 1
    i½ = (iₗ + iᵤ) ÷ 2
    if iseven(N)
        if N < 384
            quicksort!(A, iₗ, iᵤ)
        else
            partialquicksort!(A, iₗ, iᵤ, i½)
            partialquicksort!(A, i½+1, iᵤ, i½+1)
        end
        return (A[i½] + A[i½+1]) / 2
    else
        if N < 192
            quicksort!(A, iₗ, iᵤ)
        else
            partialquicksort!(A, iₗ, iᵤ, i½)
        end
        return A[i½] / 1
    end
end
