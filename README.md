# VectorizedStatistics

[![Dev][docs-dev-img]][docs-dev-url]
[![Build Status][ci-img]][ci-url]
[![codecov.io][codecov-img]][codecov-url]

Fast, [LoopVectorization.jl](https://github.com/JuliaSIMD/LoopVectorization.jl)-based summary statistics.

#### Implemented by reduction, recursively (singlethreaded only)
* `vminimum`
* `vmaximum`
* `vextrema`

#### Implemented directly by compile-time loop generation or manually-coded loops (optionally multithreaded)
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

#### See also
* [NaNStatistics.jl](https://github.com/brenhinkeller/NaNStatistics.jl) for equivalently-vectorized functions that additionally ignore `NaN`s

### Examples and benchmarks
As of Julia `v1.8.3`, VectorizedStatistics `v0.5.0`

##### `vminimum`/`vmaximum` (implemented by recursive `vreduce`)
```julia
julia> using Statistics, VectorizedStatistics, BenchmarkTools

julia> A = rand(10_000);

julia> minimum(A) == vminimum(A)
true

julia> @benchmark minimum($A)
BenchmarkTools.Trial: 10000 samples with 5 evaluations.
 Range (min … max):  6.400 μs …  17.850 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     6.692 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   6.677 μs ± 426.730 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▃▁▅▇▂    ▇█▅                                                ▂
  █████▆▆▇▇█████▆▆▄▅▄▃▅▄▅▃▃▁▄▁▅▅▄▁▄▃▄▄▃▁▄▅▄▄▄▄▃▁▄▁▄▃▄▄▄▃▄▄▄▄▃ █
  6.4 μs       Histogram: log(frequency) by time      8.13 μs <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark vminimum($A)

BenchmarkTools.Trial: 10000 samples with 190 evaluations.
 Range (min … max):  532.237 ns … 760.084 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     555.921 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   551.762 ns ±  14.327 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▅▃   ▆▅           ▅█▅▂                                        ▂
  ████▇███▆▅▅▆▆▆▆▇▆▅████▇▇▇▇▆▆▄▄▇▆▅▅▅▅▆▆▅▄▅▆▄▄▅▅▄▅▃▄▄▄▃▁▁▃▃▃▃▄▃ █
  532 ns        Histogram: log(frequency) by time        608 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> A = rand(11, 12, 13, 14);

julia> minimum(A, dims=(1,3,4)) == vminimum(A, dims=(1,3,4))
true

julia> @benchmark minimum($A, dims=(1,3,4))
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  45.083 μs … 445.208 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     47.166 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   47.126 μs ±   5.362 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▄▄▄▅▂    ▅█▅▂                                                ▂
  ██████▆▇▇█████▇▇▇▆▅▅▅▅▅▅▅▅▄▄▅▅▄▅▆▅▅▅▄▅▄▅▃▄▁▁▄▅▃▄▄▃▃▃▃▃▄▄▄▃▁▃ █
  45.1 μs       Histogram: log(frequency) by time      57.2 μs <

 Memory estimate: 816 bytes, allocs estimate: 18.

julia> @benchmark vminimum($A, dims=(1,3,4))
BenchmarkTools.Trial: 10000 samples with 7 evaluations.
 Range (min … max):  4.673 μs … 569.113 μs  ┊ GC (min … max):  0.00% … 98.82%
 Time  (median):     5.833 μs               ┊ GC (median):     0.00%
 Time  (mean ± σ):   6.639 μs ±  19.905 μs  ┊ GC (mean ± σ):  11.21% ±  3.70%

             ▁▂▄▇██▅▂
  ▆▁▁▁▁▁▁▁▁▂▄████████▇▅▄▂▂▂▂▂▂▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ▂
  4.67 μs         Histogram: frequency by time        9.04 μs <

 Memory estimate: 18.89 KiB, allocs estimate: 7.
```

##### `vmean`, `vstd`, `vvar`, etc. (implemented by direct loop generation)
```julia
julia> A = rand(11, 12, 13, 14);

julia> mean(A, dims=(1,3,4)) ≈ vmean(A, dims=(1,3,4))
true

julia> @benchmark mean($A, dims=(1,3,4))
BenchmarkTools.Trial: 10000 samples with 5 evaluations.
 Range (min … max):  6.350 μs …  13.800 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     6.417 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   6.461 μs ± 224.303 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▃▆█▇█▆▇▅▆▄▅▃▄▂▃▁▂▁▂▂▂▃▂▃▁▂▁▂▁▂ ▁ ▁                          ▃
  ████████████████████████████████▇█▆█▇▇▅▇▆▆▆▄▅▃▆▅▅▁▆▁▄▃▁▁▅▃▅ █
  6.35 μs      Histogram: log(frequency) by time      7.08 μs <

 Memory estimate: 976 bytes, allocs estimate: 14.

julia> @benchmark vmean($A, dims=(1,3,4))
BenchmarkTools.Trial: 10000 samples with 7 evaluations.
 Range (min … max):  5.012 μs …  7.696 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     5.137 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   5.147 μs ± 75.912 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

                 ▁▁▂▁█
  ▂▂▁▂▂▂▂▂▃▃▃▄█████████▇▆▅▄▅▃▃▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▁▂▂▂ ▃
  5.01 μs        Histogram: frequency by time        5.41 μs <

 Memory estimate: 272 bytes, allocs estimate: 4.

julia> A = rand(10_000);

julia> @benchmark mean($A)
BenchmarkTools.Trial: 10000 samples with 10 evaluations.
 Range (min … max):  1.733 μs …  5.954 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     1.750 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.754 μs ± 93.796 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

            ▅    █     █    ▅    ▃    ▂     ▁    ▂    ▁      ▂
  ▃▁▁▁▁▆▁▁▁▁█▁▁▁▁█▁▁▁▁▁█▁▁▁▁█▁▁▁▁█▁▁▁▁█▁▁▁▁▁█▁▁▁▁█▁▁▁▁█▁▁▁▁█ █
  1.73 μs      Histogram: log(frequency) by time     1.78 μs <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark vmean($A)
BenchmarkTools.Trial: 10000 samples with 169 evaluations.
 Range (min … max):  636.834 ns … 887.331 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     638.562 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   639.624 ns ±   9.350 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

    ▄▂█▂
  ▂▃████▄▅▃▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▁▂▂▂▁▂▂▂▂▂▂▂▂▂▁▂▂▁▂▁▂▂▂▁▂ ▂
  637 ns           Histogram: frequency by time          662 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark std($A)
BenchmarkTools.Trial: 10000 samples with 7 evaluations.
 Range (min … max):  4.179 μs …  24.470 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     4.202 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   4.219 μs ± 275.224 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▂█▇▆▂▃▂▂                                                    ▂
  ████████▇▁▄▄▄▃▄▄▃▃▃▃▁▄▄▅▃▃▁▃▁▃▃▃▃▃▃▁▁▃▃▁▃▁▃▁▁▃▄▃▃▁▁▁▁▄▁▃▁▁▄ █
  4.18 μs      Histogram: log(frequency) by time      4.73 μs <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark vstd($A)
BenchmarkTools.Trial: 10000 samples with 10 evaluations.
 Range (min … max):  1.421 μs …  4.858 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     1.475 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.466 μs ± 94.269 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

    ▄ ▇ ▇ ▄  ▃ ▂ ▁          ▅  █ █ ▅ ▄ ▃  ▂ ▁                ▂
  ▆▁█▁█▁█▁█▁▁█▁█▁█▁█▁▁▅▁▆▁█▁█▁▁█▁█▁█▁█▁█▁▁█▁█▁█▁█▁▁█▁█▁▆▁▆▁▃ █
  1.42 μs      Histogram: log(frequency) by time     1.53 μs <

 Memory estimate: 0 bytes, allocs estimate: 0.
```

##### Sorting-based functions
```julia
julia> A = rand(10_000);

julia> sort(A) == vsort!(A)
true

julia> median(A) == vmedian!(A)
true
```

#### TODO
* Median and percentile could be made more efficient with better SIMD sorting
* Other various summary statistics (mad, aad, etc.?)
* multithreaded vminimum, vmaximum, vextrema


[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://JuliaSIMD.github.io/VectorizedStatistics.jl/stable
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://JuliaSIMD.github.io/VectorizedStatistics.jl/dev
[ci-img]: https://github.com/JuliaSIMD/VectorizedStatistics.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/JuliaSIMD/VectorizedStatistics.jl/actions
[codecov-img]: https://codecov.io/gh/JuliaSIMD/VectorizedStatistics.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/JuliaSIMD/VectorizedStatistics.jl
