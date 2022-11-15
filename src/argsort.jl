# Move all NaNs to the end of the array `A`
function sortnans!(I::AbstractArray, A::AbstractArray, iₗ::Int=firstindex(A), iᵤ::Int=lastindex(A))
    # Count up NaNs
    Nₙₐₙ = 0
    @turbo for i = iₗ:iᵤ
        Nₙₐₙ += A[i] != A[i]
    end
    # If none, return early
    Nₙₐₙ == 0 && return I, A, iₗ, iᵤ

    # Otherwise, swap all NaNs
    i = iₗ
    j = iᵤ
    N = iᵤ - iₗ
    @inbounds for n = 0:N-Nₙₐₙ
        i = iₗ + n
        if A[i] != A[i]
            while A[j] != A[j]
                j -= 1
            end
            j <= i && break
            A[i], A[j] = A[j], A[i]
            I[i], I[j] = I[j], I[i]
            j -= 1
        end
    end
    return I, A, iₗ, iᵤ - Nₙₐₙ
end
# For integers, don't need to check for NaNs
sortnans!(I::AbstractArray, A::AbstractArray{<:Integer}, iₗ::Int=firstindex(A), iᵤ::Int=lastindex(A)) = I, A, iₗ, iᵤ


# Sort `A`, assuming no NaNs
function quicksort!(I::AbstractArray, A::AbstractArray, iₗ::Int=firstindex(A), iᵤ::Int=lastindex(A))
    if issortedrange(A, iₗ, iᵤ)
        # If already sorted, we're done here
        return I, A
    end
    # Otherwise, we have to sort
    N = iᵤ - iₗ + 1
    if isantisortedrange(A, iₗ, iᵤ)
        vreverse!(A, iₗ, iᵤ)
        vreverse!(I, iₗ, iᵤ)
        return I, A
    elseif N == 3
        # We know we are neither sorted nor antisorted, so only four possibilities remain
        iₘ = iₗ + 1
        a,b,c = A[iₗ], A[iₘ], A[iᵤ]
        if a <= b
            if a <= c
                A[iₘ], A[iᵤ] = c, b             # a ≤ c ≤ b
                I[iₘ], I[iᵤ] = I[iᵤ], I[iₘ]
            else
                A[iₗ], A[iₘ], A[iᵤ] = c, a, b   # c ≤ a ≤ b
                I[iₗ], I[iₘ], I[iᵤ] = I[iᵤ], I[iₗ], I[iₘ]
            end
        else
            if a <= c
                A[iₗ], A[iₘ] = b, a             # b ≤ a ≤ c
                I[iₗ], I[iₘ] = I[iₘ], I[iₗ]
            else
                A[iₗ], A[iₘ], A[iᵤ] = b, c, a   # b ≤ c ≤ a
                I[iₗ], I[iₘ], I[iᵤ] = I[iₘ], I[iᵤ], I[iₗ]
            end
        end
        return I, A
    else
        # Pick a pivot for partitioning
        iₚ = iₗ + (N >> 2)
        A[iₗ], A[iₚ] = A[iₚ], A[iₗ]
        I[iₗ], I[iₚ] = I[iₚ], I[iₗ]
        pivot = A[iₗ]

        # Count up elements that must be moved to upper partition
        Nᵤ = 0
        @turbo for i = (iₗ+1):iᵤ
            Nᵤ += A[i] >= pivot
        end
        Nₗ = N - Nᵤ

        # Swap elements between upper and lower partitions
        i = iₗ
        j = iᵤ
        @inbounds for n = 1:Nₗ-1
            i = iₗ + n
            if A[i] >= pivot
                while A[j] >= pivot
                    j -= 1
                end
                j <= i && break
                A[i], A[j] = A[j], A[i]
                I[i], I[j] = I[j], I[i]
                j -= 1
            end
        end
        # Move pivot to the top of the lower partition
        iₚ = iₗ + Nₗ - 1
        A[iₗ], A[iₚ] = A[iₚ], A[iₗ]
        I[iₗ], I[iₚ] = I[iₚ], I[iₗ]
        # Recurse: sort both upper and lower partitions
        quicksort!(I, A, iₗ, iₚ)
        quicksort!(I, A, iₚ+1, iᵤ)
    end
end

# Sort `A`, assuming no NaNs, multithreaded
function quicksortt!(I::AbstractArray, A::AbstractArray, iₗ::Int=firstindex(A), iᵤ::Int=lastindex(A), level=1)
    if issortedrange(A, iₗ, iᵤ)
        # If already sorted, we're done here
        return I, A
    end
    # Otherwise, we have to sort
    N = iᵤ - iₗ + 1
    if isantisortedrange(A, iₗ, iᵤ)
        vreverse!(A, iₗ, iᵤ)
        vreverse!(I, iₗ, iᵤ)
        return I, A
    elseif N == 3
        # We know we are neither sorted nor antisorted, so only four possibilities remain
        iₘ = iₗ + 1
        a,b,c = A[iₗ], A[iₘ], A[iᵤ]
        if a <= b
            if a <= c
                A[iₘ], A[iᵤ] = c, b             # a ≤ c ≤ b
                I[iₘ], I[iᵤ] = I[iᵤ], I[iₘ]
            else
                A[iₗ], A[iₘ], A[iᵤ] = c, a, b   # c ≤ a ≤ b
                I[iₗ], I[iₘ], I[iᵤ] = I[iᵤ], I[iₗ], I[iₘ]
            end
        else
            if a <= c
                A[iₗ], A[iₘ] = b, a             # b ≤ a ≤ c
                I[iₗ], I[iₘ] = I[iₘ], I[iₗ]
            else
                A[iₗ], A[iₘ], A[iᵤ] = b, c, a   # b ≤ c ≤ a
                I[iₗ], I[iₘ], I[iᵤ] = I[iₘ], I[iᵤ], I[iₗ]
            end
        end
        return I, A
    else
        # Pick a pivot for partitioning
        iₚ = iₗ + (N >> 2)
        A[iₗ], A[iₚ] = A[iₚ], A[iₗ]
        I[iₗ], I[iₚ] = I[iₚ], I[iₗ]
        pivot = A[iₗ]

        # Count up elements that must be moved to upper partition
        Nᵤ = 0
        @turbo for i = (iₗ+1):iᵤ
            Nᵤ += A[i] >= pivot
        end
        Nₗ = N - Nᵤ

        # Swap elements between upper and lower partitions
        i = iₗ
        j = iᵤ
        @inbounds for n = 1:Nₗ-1
            i = iₗ + n
            if A[i] >= pivot
                while A[j] >= pivot
                    j -= 1
                end
                j <= i && break
                A[i], A[j] = A[j], A[i]
                I[i], I[j] = I[j], I[i]
                j -= 1
            end
        end
        # Move pivot to the top of the lower partition
        iₚ = iₗ + Nₗ - 1
        A[iₗ], A[iₚ] = A[iₚ], A[iₗ]
        I[iₗ], I[iₚ] = I[iₚ], I[iₗ]
        # Recurse: sort both upper and lower partitions
        if level < 7
            @sync begin
                Threads.@spawn quicksortt!(I, A, iₗ, iₚ, level+1)
                Threads.@spawn quicksortt!(I, A, iₚ+1, iᵤ, level+1)
            end
        else
            quicksort!(I, A, iₗ, iₚ)
            quicksort!(I, A, iₚ+1, iᵤ)
        end
        return I, A
    end
end
