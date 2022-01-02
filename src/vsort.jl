## ---

"""
```julia
vsort(A; dims, multithreaded=:auto)
```
Return a copy of the array `A`, optionally along dimensions specified by `dims`.

See also `vsort!` for a more efficient in-place version.

## Examples
```julia
julia> using VectorizedStatistics

julia> A = [1, 3, 2, 4];

julia> vsort(A)
4-element Vector{Int64}:
 1
 2
 3
 4
"""
vsort(A; dims=:, multithreaded=:auto) = vsort!(copy(A), dims=dims, multithreaded=multithreaded)


"""
```julia
vsort!(A; dims, multithreaded=:auto)
```
Sort the array `A`, optionally along dimensions specified by `dims`.

## Examples
```julia
julia> using VectorizedStatistics

julia> A = [1, 3, 2, 4];

julia> vsort!(A)
4-element Vector{Int64}:
 1
 2
 3
 4
```
"""
function vsort!(A; dims=:, multithreaded=:auto)
    if (multithreaded==:auto && length(A) > 16383) || multithreaded==true
        _vtsort!(A, dims)
    else
        _vsort!(A, dims)
    end
end
export vsort!

# Sort linearly (reducing along all dimensions)
function _vsort!(A::AbstractArray, ::Colon)
    # IF there are NaNs, move them all to the end of the array
    A, iₗ, iᵤ = sortnans!(A)
    # Sort the non-NaN elements
    quicksort!(A, iₗ, iᵤ)
end


## --- as above, but multithreaded

# Sort linearly (reducing along all dimensions)
function _vtsort!(A::AbstractArray, ::Colon)
    # IF there are NaNs, move them all to the end of the array
    A, iₗ, iᵤ = sortnans!(A)
    # Sort the non-NaN elements
    quicksortt!(A, iₗ, iᵤ)
end

# Reducing / sorting over noncontiguous dims may be a problem
function iscontiguous(dims)
    for i = 2:length(dims)
        if !(dims[i] == dims[i-1] + 1 || dims[i] == dims[i-1] - 1)
            return false
        end
    end
    return true
end
