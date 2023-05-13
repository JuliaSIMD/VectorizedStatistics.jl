"""
```julia
vvar(A; dims=:, mean=nothing, corrected=true)
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

julia> vvar(A, dims=1)
1×2 Matrix{Float64}:
 2.0  2.0

julia> vvar(A, dims=2)
2×1 Matrix{Float64}:
 0.5
 0.5
```
"""
vvar(A; dim=:, dims=:, mean=nothing, corrected=true, multithreaded=False()) = _vvar(mean, corrected, A, dim, dims, multithreaded)
_vvar(mean, corrected, A, ::Colon, ::Colon, multithreaded) = _vvar(mean, corrected, A, :, multithreaded)
_vvar(mean, corrected, A, ::Colon, region, multithreaded) = _vvar(mean, corrected, A, region, multithreaded)
_vvar(mean, corrected, A, region, ::Colon, multithreaded) = reducedims(_vvar(mean, corrected, A, region, multithreaded), region)
export vvar

_vvar(mean, corrected, A, dims, multithreaded::Symbol) = _vvar(mean, corrected, A, dims, (multithreaded===:auto && length(A) > 4095) ? True() : False())
_vvar(mean, corrected, A, dims, multithreaded::Bool) = _vvar(mean, corrected, A, dims, static(multithreaded))

# If dims is an integer, wrap it in a tuple
_vvar(μ, corrected::Bool, A, dims::Int, multithreaded::StaticBool) = _vvar(μ, corrected, A, (dims,), multithreaded)

# If the mean is known, pass it on in the appropriate form
_vvar(μ, corrected::Bool, A, dims::Tuple, multithreaded::StaticBool) = _vvar!(collect(μ), corrected, A, dims, multithreaded)
_vvar(μ::Array, corrected::Bool, A, dims::Tuple, multithreaded::StaticBool) = _vvar!(copy(μ), corrected, A, dims, multithreaded)
_vvar(μ::Number, corrected::Bool, A, dims::Tuple, multithreaded::StaticBool) = _vvar!([μ], corrected, A, dims, multithreaded)
function _vvar(μ::Number, corrected::Bool, A, ::Colon, multithreaded::False)
    # Reduce all the dims!
    n = length(A)
    σ² = zero(typeof(μ))
    @turbo check_empty=true for i ∈ eachindex(A)
        δ = A[i] - μ
        σ² += δ * δ
    end
    return σ² / (n-corrected)
end
function _vvar(μ::Number, corrected::Bool, A, ::Colon, multithreaded::True)
    # Reduce all the dims!
    n = length(A)
    σ² = zero(typeof(μ))
    @tturbo check_empty=true for i ∈ eachindex(A)
        δ = A[i] - μ
        σ² += δ * δ
    end
    return σ² / (n-corrected)
end

# If the mean isn't known, compute it
_vvar(::Nothing, corrected::Bool, A, dims::Tuple, multithreaded::StaticBool) = _vvar!(_vmean(A, dims, multithreaded), corrected, A, dims, multithreaded)
function _vvar(::Nothing, corrected::Bool, A, ::Colon, multithreaded::False)
    # Reduce all the dims!
    n = length(A)
    Tₒ = Base.promote_op(/, eltype(A), Int)
    Σ = zero(Tₒ)
    @turbo check_empty=true for i ∈ eachindex(A)
            Σ += A[i]
    end
    μ = Σ / n
    σ² = zero(typeof(μ))
    @turbo check_empty=true for i ∈ eachindex(A)
            δ = A[i] - μ
            σ² += δ * δ
    end
    return σ² / (n-corrected)
end
function _vvar(::Nothing, corrected::Bool, A, ::Colon, multithreaded::True)
    # Reduce all the dims!
    n = length(A)
    Tₒ = Base.promote_op(/, eltype(A), Int)
    Σ = zero(Tₒ)
    @tturbo check_empty=true for i ∈ eachindex(A)
            Σ += A[i]
    end
    μ = Σ / n
    σ² = zero(typeof(μ))
    @tturbo check_empty=true for i ∈ eachindex(A)
            δ = A[i] - μ
            σ² += δ * δ
    end
    return σ² / (n-corrected)
end

## Singlethreaded implementation

# Chris Elrod metaprogramming magic:
# Generate customized set of loops for a given ndims and a vector
# `static_dims` of dimensions to reduce over
function staticdim_var_quote(static_dims::Vector{Int}, N::Int, multithreaded::Type{False})
  M = length(static_dims)
  # `static_dims` now contains every dim we're taking the var over.
  Bᵥ = Expr(:call, :view, :B)
  reduct_inds = Int[]
  nonreduct_inds = Int[]
  # Firstly, build our expressions for indexing each array
  Aind = :(A[])
  Bind = :(Bᵥ[])
  inds = Vector{Symbol}(undef, N)
  len = Expr(:call, :*)
  for n ∈ 1:N
    ind = Symbol(:i_,n)
    inds[n] = ind
    push!(Aind.args, ind)
    if n ∈ static_dims
      push!(reduct_inds, n)
      push!(Bᵥ.args, :(firstindex(B,$n)))
      push!(len.args, :(size(A, $n)))
    else
      push!(nonreduct_inds, n)
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
    push!(rblock.args, :(μ = $Bind))
    push!(rblock.args, :(σ² = zero(eltype(Bᵥ))))
    # Build the reduction loop
    for n ∈ reduct_inds
      newblock = Expr(:block)
      push!(block.args, Expr(:for, :($(inds[n]) = axes(A,$n)), newblock))
      block = newblock
    end
    # Push more things here if you want them in the innermost loop
    push!(block.args, :(δ = $Aind - μ))
    push!(block.args, :(σ² += δ * δ))
    # Push more things here if you want them at the end of the reduction loop
    push!(rblock.args, :($Bind = σ² * invdenom))
    # Put it all together
    return quote
      invdenom = inv(($len) - corrected)
      Bᵥ = $Bᵥ
      @turbo $loops
      return B
    end
  else
    firstn = first(reduct_inds)
    block = Expr(:block)
    loops = Expr(:for, :($(inds[firstn]) = axes(A,$firstn)), block)
    if length(reduct_inds) > 1
      for n ∈ @view(reduct_inds[2:end])
        newblock = Expr(:block)
        push!(block.args, Expr(:for, :($(inds[n]) = axes(A,$n)), newblock))
        block = newblock
      end
    end
    # Push more things here if you want them in the innermost loop
    push!(block.args, :(δ = $Aind - μ))
    push!(block.args, :(σ² += δ * δ))
    # Put it all together
    return quote
      invdenom = inv(($len) - corrected)
      Bᵥ = $Bᵥ
      μ = Bᵥ[]
      σ² = zero(eltype(Bᵥ))
      @turbo $loops
      Bᵥ[] = σ² * invdenom
      return B
    end
  end
end

## Multithreaded implementation

# Chris Elrod metaprogramming magic:
# Generate customized set of loops for a given ndims and a vector
# `static_dims` of dimensions to reduce over
function staticdim_var_quote(static_dims::Vector{Int}, N::Int, multithreaded::Type{True})
  M = length(static_dims)
  # `static_dims` now contains every dim we're taking the var over.
  Bᵥ = Expr(:call, :view, :B)
  reduct_inds = Int[]
  nonreduct_inds = Int[]
  # Firstly, build our expressions for indexing each array
  Aind = :(A[])
  Bind = :(Bᵥ[])
  inds = Vector{Symbol}(undef, N)
  len = Expr(:call, :*)
  for n ∈ 1:N
    ind = Symbol(:i_,n)
    inds[n] = ind
    push!(Aind.args, ind)
    if n ∈ static_dims
      push!(reduct_inds, n)
      push!(Bᵥ.args, :(firstindex(B,$n)))
      push!(len.args, :(size(A, $n)))
    else
      push!(nonreduct_inds, n)
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
    push!(rblock.args, :(μ = $Bind))
    push!(rblock.args, :(σ² = zero(eltype(Bᵥ))))
    # Build the reduction loop
    for n ∈ reduct_inds
      newblock = Expr(:block)
      push!(block.args, Expr(:for, :($(inds[n]) = axes(A,$n)), newblock))
      block = newblock
    end
    # Push more things here if you want them in the innermost loop
    push!(block.args, :(δ = $Aind - μ))
    push!(block.args, :(σ² += δ * δ))
    # Push more things here if you want them at the end of the reduction loop
    push!(rblock.args, :($Bind = σ² * invdenom))
    # Put it all together
    return quote
      invdenom = inv(($len) - corrected)
      Bᵥ = $Bᵥ
      @tturbo $loops
      return B
    end
  else
    firstn = first(reduct_inds)
    block = Expr(:block)
    loops = Expr(:for, :($(inds[firstn]) = axes(A,$firstn)), block)
    if length(reduct_inds) > 1
      for n ∈ @view(reduct_inds[2:end])
        newblock = Expr(:block)
        push!(block.args, Expr(:for, :($(inds[n]) = axes(A,$n)), newblock))
        block = newblock
      end
    end
    # Push more things here if you want them in the innermost loop
    push!(block.args, :(δ = $Aind - μ))
    push!(block.args, :(σ² += δ * δ))
    # Put it all together
    return quote
      invdenom = inv(($len) - corrected)
      Bᵥ = $Bᵥ
      μ = Bᵥ[]
      σ² = zero(eltype(Bᵥ))
      @tturbo $loops
      Bᵥ[] = σ² * invdenom
      return B
    end
  end
end

## ---
# Chris Elrod metaprogramming magic:
# Turn non-static integers in `dims` tuple into `StaticInt`s
# so we can construct `static_dims` vector within @generated code
function branches_var_quote(N::Int, M::Int, D, multithreaded)
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
        qnew = Expr(ifsym, :(dimm == $n), :(return _vvar!(B, corrected, A, $tc, multithreaded)))
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
      push!(qold.args, Expr(:block, :(return _vvar!(B, corrected, A, $tc, multithreaded))))
      return q
    end
  end
  staticdim_var_quote(static_dims, N, multithreaded)
end

# Efficient @generated in-place var
@generated function _vvar!(B::AbstractArray{Tₒ,N}, corrected::Bool, A::AbstractArray{T,N}, dims::D, multithreaded) where {Tₒ,T,N,M,D<:Tuple{Vararg{IntOrStaticInt,M}}}
  branches_var_quote(N, M, D, multithreaded)
end
@generated function _vvar!(B::AbstractArray{Tₒ,N}, corrected::Bool, A::AbstractArray{T,N}, dims::Tuple{}, multithreaded) where {Tₒ,T,N}
  :(fill!(B, Tₒ(NaN)); return B)
end
