# Reduce all the dims!
function _vmean(A, ::Colon)
  Σ = zero(eltype(A))
  @avx for i ∈ eachindex(A)
    Σ += A[i]
  end
  return Σ / length(A)
end

# Reduce over some specific indices
function _vmean(A, I::CartesianIndices)
    Σ = zero(eltype(A))
    @avx for i ∈ I
        Σ += A[i]
    end
    return Σ / length(I)
end

# Fallback cartesian in-place mean
function _vmean_cartesian!(B::AbstractArray{Tₒ,N}, A::AbstractArray, dims) where {Tₒ,N}
  axᵢ = axes(A)
  @inbounds for I ∈ CartesianIndices(B)
    axᵣ = ntuple(Val(N)) do d
      ifelse(d ∈ dims, axᵢ[d], I[d])
    end
    B[I] = _vmean(A, CartesianIndices(axᵣ))
  end
  return B
end

# Chris Elrod metaprogramming magic:
# Generate customized set of loops for a given ndims and a vector
# `static_dims` of dimensions to reduce over
function staticdim_mean_quote(static_dims::Vector{Int}, N::Int)
  M = length(static_dims)
  # `static_dims` now contains every dim we're taking the mean over.
  Bv = Expr(:call, :view, :B)
  reduct_inds = Int[]
  nonreduct_inds = Int[]
  # Firstly, build our expressions for indexing each array
  Aind = :(A[])
  Bind = :(Bv[])
  inds = Vector{Symbol}(undef, N)
  len = Expr(:call, :*)
  for n ∈ 1:N
    ind = Symbol(:i_,n)
    inds[n] = ind
    push!(Aind.args, ind)
    if n ∈ static_dims
      push!(reduct_inds, n)
      push!(Bv.args, :(firstindex(B,$n)))
      push!(len.args, :(size(A, $n)))
    else
      push!(nonreduct_inds, n)
      push!(Bv.args, :)
      push!(Bind.args, ind)
    end
  end
  firstn = first(nonreduct_inds)
  # Secondly, build up our set of loops
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
  push!(rblock.args, :(Σ = zero(eltype(Bv))))
  # Build the reduction loop
  for n ∈ reduct_inds
    newblock = Expr(:block)
    push!(block.args, Expr(:for, :($(inds[n]) = axes(A,$n)), newblock))
    block = newblock
  end
  # Push more things here if you want them in the innermost loop
  push!(block.args, :(Σ += $Aind))
  # Push more things here if you want them at the end of the reduction loop
  push!(rblock.args, :($Bind = Σ * invdenom))
  # Put it all together
  quote
    invdenom = inv($len)
    Bv = $Bv
    @avx $loops
    return B
  end
end

# Chris Elrod metaprogramming magic:
# Turn non-static integers in `dims` tuple into `StaticInt`s
# so we can construct `static_dims` vector within @generated code
function branches_mean_quote(N::Int, M::Int, D)
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
        qnew = Expr(ifsym, :(dimm == $n), :(return _vmean!(B, A, $tc)))
        for r ∈ m+1:M
          push!(tc.args, :(dims[$r]))
        end
        push!(qold.args, qnew)
        qold = qnew
        ifsym = :elseif
      end
      push!(qold.args, Expr(:block, :(throw("Dimension `$dimm` not found."))))
      return q
    end
  end
  staticdim_mean_quote(static_dims, N)
end

# Efficient @generated in-place mean
@generated function _vmean!(B::AbstractArray{Tₒ,N}, A::AbstractArray{T,N}, dims::D) where {Tₒ,T,N,M,D<:Tuple{Vararg{Integer,M}}}
  N == M && return :(B[1] = _vmean(A, :); B)
  total_combinations = binomial(N,M)
  if total_combinations > 10
    # Fallback, for extremely high-dimensional arrays
    return :(_vmean_cartesian!(B, A, dims))
  else
    branches_mean_quote(N, M, D)
  end
end

# Reduce some dims
function _vmean(A::AbstractArray{T,N}, dims::Tuple) where {T,N}
  sᵢ = size(A)
  sₒ = ntuple(Val(N)) do d
    ifelse(d ∈ dims, 1, sᵢ[d])
  end
  Tₒ = Base.promote_op(/, T, Int)
  B = similar(A, Tₒ, sₒ)
  _vmean!(B, A, dims)
end

# Reduce one dim
_vmean(A, dims::Int) = _vmean(A, (dims,))

"""
```julia
vmean(A; dims)
```
As `Statistics.mean`, but vectorized: compute the mean of all elements in `A`,
optionally over dimensions specified by `dims`.

## Examples
```julia
julia> using VectorizedStatistics

julia> A = [1 2; 3 4]
2×2 Matrix{Int64}:
 1  2
 3  4

julia> vmean(A, dims=1)
1×2 Matrix{Float64}:
 2.0  3.0

julia> vmean(A, dims=2)
2×1 Matrix{Float64}:
 1.5
 3.5
```
"""
vmean(A; dims=:) = _vmean(A, dims)
export vmean
