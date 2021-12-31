"""
```julia
vmedian!(A; dims)
```
Compute the median of all elements in `A`, optionally over dimensions specified by `dims`.
As `Statistics.median!`, but slightly vectorized and supporting the `dims` keyword.

Be aware that, like `Statistics.median!`, this function modifies `A`, sorting or
partially sorting the contents thereof (specifically, along the dimensions specified
by `dims`, using either `quicksort!` or `partialquicksort!` around the median
depending on the size of the array). Do not use this function if you do not want
the contents of `A` to be rearranged.

Reduction over multiple `dims` is not officially supported, though does work
(in generally suboptimal time) as long as the dimensions being reduced over are
all contiguous.

## Examples
```julia
julia> using VectorizedStatistics

julia> A = [1 2 3; 4 5 6; 7 8 9]
3×3 Matrix{Int64}:
 1  2  3
 4  5  6
 7  8  9

 julia> vmedian!(A, dims=1)
 1×3 Matrix{Float64}:
  4.0  5.0  6.0

 julia> vmedian!(A, dims=2)
 3×1 Matrix{Float64}:
  2.0
  5.0
  8.0

 julia> vmedian!(A)
 5.0

 julia> A # Note that the array has been sorted
3×3 Matrix{Int64}:
 1  4  7
 2  5  8
 3  6  9
```
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
_vmedian!(A, ::Tuple{Colon}) = _vmedian!(A, :)
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

# Generate customized set of loops for a given ndims and a vector
# `static_dims` of dimensions to reduce over
function staticdim_median_quote(static_dims::Vector{Int}, N::Int)
  M = length(static_dims)
  # `static_dims` now contains every dim we're taking the median over.
  Bᵥ = Expr(:call, :view, :B)
  Aᵥ = Expr(:call, :view, :A)
  reduct_inds = Int[]
  nonreduct_inds = Int[]
  # Firstly, build our expressions for indexing each array
  Aind = :(Aᵥ[])
  Bind = :(Bᵥ[])
  inds = Vector{Symbol}(undef, N)
  for n ∈ 1:N
    ind = Symbol(:i_,n)
    inds[n] = ind
    if n ∈ static_dims
      push!(reduct_inds, n)
      push!(Aᵥ.args, :)
      push!(Bᵥ.args, :(firstindex(B,$n)))
    else
      push!(nonreduct_inds, n)
      push!(Aᵥ.args, ind)
      push!(Bᵥ.args, :)
      push!(Bind.args, ind)
    end
  end
  # Secondly, build up our set of loops
  if !isempty(nonreduct_inds)
    firstn = first(nonreduct_inds)
    block = Expr(:block)
    loops = Expr(:for, :($(inds[firstn]) = indices((A,B),$firstn)), block)
    if length(nonreduct_inds) > 1
      for n ∈ @view(nonreduct_inds[2:end])
        newblock = Expr(:block)
        push!(block.args, Expr(:for, :($(inds[n]) = indices((A,B),$n)), newblock))
        block = newblock
      end
    end
    rblock = block
    # Push more things here if you want them at the beginning of the reduction loop
    push!(rblock.args, :(Aᵥ = $Aᵥ))
    push!(rblock.args, :($Bind = _vmedian!(Aᵥ, :)))
    # Put it all together
    return quote
      Bᵥ = $Bᵥ
      @inbounds $loops
      return B
    end
  else
    return quote
      Bᵥ = $Bᵥ
      Bᵥ[] = _vmedian!(A, :)
      return B
    end
  end
end

# Chris Elrod metaprogramming magic:
# Turn non-static integers in `dims` tuple into `StaticInt`s
# so we can construct `static_dims` vector within @generated code
function branches_median_quote(N::Int, M::Int, D)
  static_dims = Int[]
  for m ∈ 1:M
    param = D.parameters[m]
    if param <: StaticInt
      new_dim = _dim(param)::Int
      @assert new_dim ∉ static_dims
      push!(static_dims, new_dim)
    else
      t = Expr(:tuple)
      for n ∈ static_dims
        push!(t.args, :(StaticInt{$n}()))
      end
      q = Expr(:block, :(dimm = dims[$m]))
      qold = q
      ifsym = :if
      for n ∈ 1:N
        n ∈ static_dims && continue
        tc = copy(t)
        push!(tc.args, :(StaticInt{$n}()))
        qnew = Expr(ifsym, :(dimm == $n), :(return _vmedian!(B, A, $tc)))
        for r ∈ m+1:M
          push!(tc.args, :(dims[$r]))
        end
        push!(qold.args, qnew)
        qold = qnew
        ifsym = :elseif
      end
      # Else, if dimm ∉ 1:N, drop it from list and continue
      tc = copy(t)
      for r ∈ m+1:M
        push!(tc.args, :(dims[$r]))
      end
      push!(qold.args, Expr(:block, :(return _vmedian!(B, A, $tc))))
      return q
    end
  end
  return staticdim_median_quote(static_dims, N)
end

# Efficient @generated in-place median
@generated function _vmedian!(B::AbstractArray{Tₒ,N}, A::AbstractArray{T,N}, dims::D) where {Tₒ,T,N,M,D<:Tuple{Vararg{Integer,M}}}
  branches_median_quote(N, M, D)
end
@generated function _vmedian!(B::AbstractArray{Tₒ,N}, A::AbstractArray{T,N}, dims::Tuple{}) where {Tₒ,T,N}
  :(copyto!(B, A); return B)
end
