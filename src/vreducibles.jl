
for (op, name) in zip((:min, :max, :+), (:_vminimum, :_vmaximum, :_vsum))
  # Reduce over all dimensions
  @eval $name(A, ::Colon) = vreduce($op, A)

  # Reduce over a single dimension
  @eval $name(A, region::Int) = vreduce($op, A, dims=region)

  # General case: recursive
  @eval function $name(A::AbstractArray, region::Tuple)
    if length(region) == 1
      # For tuple with single element, simply unwrap
      $name(A, region[1])
    elseif length(region) == 2
      # For tuple with two elements, two evaluations suffice
      $name($name(A, region[1]), region[2])
    else
      # Otherwise recurse
      $name($name(A, region[1]), region[2:end])
    end
  end
end


"""
```julia
vminimum(A; dims)
```
As `Base.minimum`, but vectorized: find the least value contained in `A`,
optionally over dimensions specified by `dims`.

## Examples
```julia
julia> using VectorizedStatistics

julia> A = [1 2; 3 4]
2×2 Matrix{Int64}:
 1  2
 3  4

julia> vminimum(A, dims=1)
1×2 Matrix{Int64}:
 1  2

julia> vminimum(A, dims=2)
 2×1 Matrix{Int64}:
 1
 3
```
"""
vminimum(A; dims=:) = _vminimum(A, dims)
export vminimum


"""
```julia
vmaximum(A; dims)
```
As `Base.maximum`, but vectorized: find the greatest value contained in `A`,
optionally over dimensions specified by `dims`.

## Examples
```julia
julia> using VectorizedStatistics

julia> A = [1 2; 3 4]
2×2 Matrix{Int64}:
 1  2
 3  4

julia> vmaximum(A, dims=1)
1×2 Matrix{Int64}:
 3  4

julia>  vmaximum(A, dims=2)
 2×1 Matrix{Int64}:
 2
 4
```
"""
vmaximum(A; dims=:) = _vmaximum(A, dims)
export vmaximum


"""
```julia
vsum(A; dims)
```
As `Base.sum`, but vectorized: summate the values contained in `A`,
optionally over dimensions specified by `dims`.

## Examples
```julia
julia> using VectorizedStatistics

julia> A = [1 2; 3 4]
2×2 Matrix{Int64}:
 1  2
 3  4

julia> vsum(A, dims=1)
1×2 Matrix{Int64}:
 4  6

julia> vsum(A, dims=2)
 2×1 Matrix{Int64}:
 3
 7
```
"""
vsum(A; dims=:) = _vsum(A, dims)
export vsum


"""
```julia
vextrema(A; dims)
```
As `Base.extrema`, but vectorized: Find the maximum and minimum of `A`,
optionally along the dimensions specified by `dims`.

## Examples

julia> A = reshape(Vector(1:2:16), (2,2,2))
2×2×2 Array{Int64, 3}:
 [:, :, 1] =
  1  5
  3  7

 [:, :, 2] =
   9  13
  11  15

julia> extrema(A, dims = (1,2))
1×1×2 Array{Tuple{Int64, Int64}, 3}:
 [:, :, 1] =
  (1, 7)

 [:, :, 2] =
  (9, 15)
"""
vextrema(A; dims=:) = _vextrema(A, dims)
_vextrema(A, region) = collect(zip(_vminimum(A, region), _vmaximum(A, region)))
_vextrema(A, ::Colon) = (_vminimum(A, :), _vmaximum(A, :))
export vextrema
