## ---

vsort(A; dims=:, multithreaded=:auto) = vsort!(copy(A), dims=dims, multithreaded=multithreaded)
function vsort!(A; dims=:, multithreaded=:auto)
    if (multithreaded==:auto && length(A) > 16383) || multithreaded==true
        _vtsort!(A, dims)
    else
        _vsort!(A, dims)
    end
end
export vsort

# Sort linearly (reducing along all dimensions)
function _vsort!(A::AbstractArray, ::Colon)
    iₗ, iᵤ = firstindex(A), lastindex(A)
    # IF there are NaNs, move them all to the end of the array
    A, iₗ, iᵤ = sortnans!(A, iₗ, iᵤ)
    quicksort!(A, iₗ, iᵤ)
end
function _vsort!(A::AbstractArray{<:Integer}, ::Colon)
    iₗ, iᵤ = firstindex(A), lastindex(A)
    # If there are only integers, no need to check for NaNs first
    quicksort!(A, iₗ, iᵤ)
end


## --- as above, but multithreaded

# Sort linearly (reducing along all dimensions)
function _vtsort!(A::AbstractArray, ::Colon)
    iₗ, iᵤ = firstindex(A), lastindex(A)
    # IF there are NaNs, move them all to the end of the array
    A, iₗ, iᵤ = sortnans!(A, iₗ, iᵤ)
    quicksortt!(A, iₗ, iᵤ)
end
function _vtsort!(A::AbstractArray{<:Integer}, ::Colon)
    iₗ, iᵤ = firstindex(A), lastindex(A)
    # If there are only integers, no need to check for NaNs first
    quicksortt!(A, iₗ, iᵤ)
end
