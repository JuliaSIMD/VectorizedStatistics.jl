# VectorizedStatistics

[![Dev][docs-dev-img]][docs-dev-url]
[![Build Status][ci-img]][ci-url]
[![codecov.io][codecov-img]][codecov-url]

Fast, [LoopVectorization.jl](https://github.com/JuliaSIMD/LoopVectorization.jl)-based summary statistics.

#### Implemented by reduction, recursively (singlethreaded only)
* `vminimum`
* `vmaximum`
* `vextrema`

#### Implemented directly by compile-time loop generation or manually-coded loops (auto-multithreaded by default)
* `vmean`
* `vsum`
* `vvar`
* `vstd`
* `vcov`
* `vcor`

#### Implemented via quicksort/quickselect (some easy steps vectorized), with multidimensional reductions handled by compile-time loop generation
* `vsort!`
* `vmedian!`
* `vquantile!`
* `vpercentile!`

#### TODO
* median, percentile: requires a good SIMD sorting function
* Other various summary statistics (mad, aad, etc.?)
* multithreaded vminimum, vmaximum, vextrema

#### Examples
```julia
julia> A = randn(11,12,13,14);

julia> using Statistics, VectorizedStatistics

julia> @btime minimum($A, dims=(1,3,4))
  119.232 μs (17 allocations: 784 bytes)
1×12×1×1 Array{Float64, 4}:
[:, :, 1, 1] =
 -3.00642  -2.83965  -3.32982  -3.61375  -3.48724  -3.45598  -4.18917  -4.15953  -3.13166  -3.06141  -3.28183  -3.92745

julia> @btime vminimum($A, dims=(1,3,4))
  7.548 μs (7 allocations: 18.91 KiB)
1×12×1×1 Array{Float64, 4}:
[:, :, 1, 1] =
 -3.00642  -2.83965  -3.32982  -3.61375  -3.48724  -3.45598  -4.18917  -4.15953  -3.13166  -3.06141  -3.28183  -3.92745

julia> @btime mean($A, dims=(1,3,4))
  14.805 μs (14 allocations: 1.03 KiB)
1×12×1×1 Array{Float64, 4}:
[:, :, 1, 1] =
 -0.0218661  -0.00620601  0.00940895  -0.0346008  -0.0142793  …  -0.0122078  -0.00940791  -0.0224422  -0.0149096

julia> @btime vmean($A, dims=(1,3,4))
  5.543 μs (4 allocations: 272 bytes)
1×12×1×1 Array{Float64, 4}:
[:, :, 1, 1] =
 -0.0218661  -0.00620601  0.00940895  -0.0346008  -0.0142793  …  -0.0122078  -0.00940791  -0.0224422  -0.0149096

julia> @btime std($A, dims=(1,3,4))
  35.999 μs (22 allocations: 1.47 KiB)
1×12×1×1 Array{Float64, 4}:
[:, :, 1, 1] =
 0.997894  0.992307  1.00967  0.994489  0.98649  0.99119  0.979061  1.00489  1.01303  0.979  1.00003  0.977224

julia> @btime vstd($A, dims=(1,3,4))
  12.395 μs (7 allocations: 352 bytes)
1×12×1×1 Array{Float64, 4}:
[:, :, 1, 1] =
 0.997894  0.992307  1.00967  0.994489  0.98649  0.99119  0.979061  1.00489  1.01303  0.979  1.00003  0.977224
```

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://brenhinkeller.github.io/VectorizedStatistics.jl/stable
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://brenhinkeller.github.io/VectorizedStatistics.jl/dev
[ci-img]: https://github.com/brenhinkeller/VectorizedStatistics.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/brenhinkeller/VectorizedStatistics.jl/actions
[codecov-img]: https://codecov.io/gh/brenhinkeller/VectorizedStatistics.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/brenhinkeller/VectorizedStatistics.jl
