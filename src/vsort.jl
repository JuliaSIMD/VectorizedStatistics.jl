## ---

"""
```julia
vsort(A; dims, multithreaded=false)
```
Return a sorted copy of the array `A`, optionally along dimensions specified by `dims`.

If sorting over multiple `dims`, these dimensions must be contiguous (i.e.
`dims=(2,3)` but not `dims=(1,3)`). Note also that specifying `dims` other than
`:` creates `view`s, with some nonzero performance cost.

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
vsort(A; dims=:, multithreaded=false) = vsort!(copy(A), dims=dims, multithreaded=multithreaded)


"""
```julia
vsort!([I], A; dims, multithreaded=false)
```
Sort the array `A`, optionally along dimensions specified by `dims`.

If the optional argument `I` is supplied, it will be sorted following the
same permuation as `A`. For example, if `I = collect(1:length(A))`, then
after calling `vsort!(I, A)`, `A` will be sorted and `I` will be equal to
`sortperm(A)`

If sorting over multiple `dims`, these dimensions must be contiguous (i.e.
`dims=(2,3)` but not `dims=(1,3)`). Note also that specifying `dims` other than
`:` creates `view`s, with some nonezero performance cost.

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
function vsort!(A; dims=:, multithreaded=false)
    if (multithreaded===:auto && length(A) > 16383) || multithreaded===true
        _vtsort!(A, dims)
    else
        _vsort!(A, dims)
    end
end
function vsort!(I, A; dims=:, multithreaded=false)
    @assert eachindex(I) === eachindex(A)
    if (multithreaded===:auto && length(A) > 16383) || multithreaded===true
        _vtsort!(I, A, dims)
    else
        _vsort!(I, A, dims)
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
# Also permute `I` via the same permutation that sorts `A`
function _vsort!(I, A::AbstractArray, ::Colon)
    @assert eachindex(I) === eachindex(A)
    # IF there are NaNs, move them all to the end of the array
    I, A, iₗ, iᵤ = sortnans!(I, A)
    # Sort the non-NaN elements
    quicksort!(I, A, iₗ, iᵤ)
end

## --- as above, but multithreaded

# Sort linearly (reducing along all dimensions)
function _vtsort!(A::AbstractArray, ::Colon)
    # IF there are NaNs, move them all to the end of the array
    A, iₗ, iᵤ = sortnans!(A)
    # Sort the non-NaN elements
    quicksortt!(A, iₗ, iᵤ)
end
function _vtsort!(I, A::AbstractArray, ::Colon)
    # IF there are NaNs, move them all to the end of the array
    I, A, iₗ, iᵤ = sortnans!(I, A)
    # Sort the non-NaN elements
    quicksortt!(I, A, iₗ, iᵤ)
end


# Fall back to singlethreaded for multidimensional cases
_vtsort!(A::AbstractArray, dims) = _vsort!(A::AbstractArray, dims)

## -- multidimensional cases (singlethreaded only)

# Reducing / sorting over noncontiguous dims may be a problem
function iscontiguous(dims)
    for i = 2:length(dims)
        if !(dims[i] == dims[i-1] + 1 || dims[i] == dims[i-1] - 1)
            return false
        end
    end
    return true
end

# Sort one dim
_vsort!(A, dims::Int) = _vsort!(A, (dims,))

# Sort some dims
function _vsort!(A::AbstractArray{T,N}, dims::Tuple) where {T,N}
    iscontiguous(dims) || error("Only continuous `dims` are supported")
    __vsort!(A, dims)
end

# Generate customized set of loops for a given ndims and a vector
# `static_dims` of dimensions to reduce over
function staticdim_sort_quote(static_dims::Vector{Int}, N::Int)
  M = length(static_dims)
  # `static_dims` now contains every dim we're taking the sort over.
  Aᵥ = Expr(:call, :view, :A)
  reduct_inds = Int[]
  nonreduct_inds = Int[]
  # Firstly, build our expressions for indexing each array
  Aind = :(Aᵥ[])
  inds = Vector{Symbol}(undef, N)
  for n ∈ 1:N
    ind = Symbol(:i_,n)
    inds[n] = ind
    if n ∈ static_dims
      push!(reduct_inds, n)
      push!(Aᵥ.args, :)
    else
      push!(nonreduct_inds, n)
      push!(Aᵥ.args, ind)
    end
  end
  # Secondly, build up our set of loops
  if !isempty(nonreduct_inds)
    firstn = first(nonreduct_inds)
    block = Expr(:block)
    loops = Expr(:for, :($(inds[firstn]) = indices(A,$firstn)), block)
    if length(nonreduct_inds) > 1
      for n ∈ @view(nonreduct_inds[2:end])
        newblock = Expr(:block)
        push!(block.args, Expr(:for, :($(inds[n]) = indices(A,$n)), newblock))
        block = newblock
      end
    end
    rblock = block
    # Push more things here if you want them at the beginning of the reduction loop
    push!(rblock.args, :(Aᵥ = $Aᵥ))
    push!(rblock.args, :(_vsort!(Aᵥ, :)))
    # Put it all together
    return quote
      @inbounds $loops
      return A
    end
  else
    return quote
      _vsort!(A, :)
      return A
    end
  end
end

# Chris Elrod metaprogramming magic:
# Turn non-static integers in `dims` tuple into `StaticInt`s
# so we can construct `static_dims` vector within @generated code
function branches_sort_quote(N::Int, M::Int, D)
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
        qnew = Expr(ifsym, :(dimm == $n), :(return __vsort!(A, $tc)))
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
      push!(qold.args, Expr(:block, :(return __vsort!(A, $tc))))
      return q
    end
  end
  return staticdim_sort_quote(static_dims, N)
end

# Efficient @generated in-place sort
@generated function __vsort!(A::AbstractArray{T,N}, dims::D) where {T,N,M,D<:Tuple{Vararg{IntOrStaticInt,M}}}
  branches_sort_quote(N, M, D)
end
@generated function __vsort!(A::AbstractArray{T,N}, dims::Tuple{}) where {T,N}
  :(return A)
end
