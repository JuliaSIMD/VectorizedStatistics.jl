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

#### See also
* [NaNStatistics.jl](https://github.com/brenhinkeller/NaNStatistics.jl) for equivalently-vectorized functions that additionally ignore `NaN`s

### Examples and benchmarks
As of Julia `v1.7.1`, VectorizedStatistics `v0.4.0`

##### `vminimum`/`vmaximum` (implemented by recursive `vreduce`)
```julia
julia> using Statistics, VectorizedStatistics, BenchmarkTools

julia> A = rand(10_000);

julia> minimum(A) == vminimum(A)
true

julia> @benchmark minimum($A)
BenchmarkTools.Trial: 10000 samples with 8 evaluations.
 Range (min … max):  4.004 μs …  15.188 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     4.174 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   4.484 μs ± 796.238 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▇█▆▆▃▅▃▂▅▂▃    ▄▂▂▂▁▁▁ ▃ ▁                                  ▂
  ████████████▇▇▇███████████▇▇▆▆▆▆▅██▇▆▆▆▆▆▅▆▆▆▄▆▄▅▄▆▄▄▄▄▅▁▅▆ █
  4 μs         Histogram: log(frequency) by time      8.54 μs <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark vminimum($A)
BenchmarkTools.Trial: 10000 samples with 86 evaluations.
 Range (min … max):  804.581 ns …   3.359 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     918.890 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   984.708 ns ± 203.385 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

     ▅▃▃█▇                                                       
  ▃▄▅█████▇▅▄▄▃▃▃▃▄▄▃▃▃▃▃▃▄▃▃▂▂▂▂▂▁▂▂▁▂▂▂▁▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▃▃▃ ▃
  805 ns           Histogram: frequency by time          1.8 μs <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> A = rand(11, 12, 13, 14);

julia> minimum(A, dims=(1,3,4)) == vminimum(A, dims=(1,3,4))
true

julia> @benchmark minimum($A, dims=(1,3,4))
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  46.466 μs … 208.307 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     46.808 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   48.092 μs ±   5.712 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%

  █▆▁▃▅▂▁▂                                                     ▁
  ████████▇▆▇▆▅▄▃▁▃▃▄▁▁▄█▆▆▅▇▅▅▇▆▆▅▅▅▅█▅▅▅▄▄▃▁▄▁▄▄▅▄▅▄▆▆█▇▄▄▄▅ █
  46.5 μs       Histogram: log(frequency) by time      71.3 μs <

 Memory estimate: 816 bytes, allocs estimate: 18.

julia> @benchmark vminimum($A, dims=(1,3,4))
BenchmarkTools.Trial: 10000 samples with 4 evaluations.
 Range (min … max):   7.753 μs …  2.656 ms  ┊ GC (min … max):  0.00% … 99.25%
 Time  (median):      9.138 μs              ┊ GC (median):     0.00%
 Time  (mean ± σ):   13.333 μs ± 73.733 μs  ┊ GC (mean ± σ):  16.79% ±  3.13%

  ▆▅▆▅█▇▇▅▄▄▄▃▃▂▁▁▂▁         ▂▂ ▂▁                            ▂
  ███████████████████▇▇▇▆▇▆▄▆██▇██▇▅▅▄▅▇▆▄▄▄▃▅▄▁▃▄▃▃▁▃▃▁▁▃▁▃▄ █
  7.75 μs      Histogram: log(frequency) by time      23.7 μs <

 Memory estimate: 18.89 KiB, allocs estimate: 7.
```

##### `vmean`, `vstd`, `vvar`, etc. (implemented by direct loop generation)
```julia
julia> A = rand(11, 12, 13, 14);

julia> mean(A, dims=(1,3,4)) ≈ vmean(A, dims=(1,3,4))
true

julia> @benchmark mean(A, dims=(1,3,4))
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  14.110 μs … 51.108 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     15.212 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   15.775 μs ±  2.380 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▂▄▆█▇▅▃▂▂▁ ▂▁    ▁▁      ▁▁                                 ▂
  █████████████▇██▇██▇▅▅▄▄▆██▇▄▄▅▄▄▅▅▅▆▆▇▅▅▄▃▄▁▃▄▁▄▅▄▄▄▁▁▁▁▁▅ █
  14.1 μs      Histogram: log(frequency) by time      31.3 μs <

 Memory estimate: 976 bytes, allocs estimate: 14.

julia> @benchmark vmean(A, dims=(1,3,4))
BenchmarkTools.Trial: 10000 samples with 10 evaluations.
 Range (min … max):  1.735 μs …   6.984 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     1.815 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   1.923 μs ± 386.738 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▄██▇▆▃                    ▁       ▁▁                        ▂
  ███████▆▅▅▆▄▅▄▄▄▄▅▄▄▅▇▇▇▇▇██▇▆▆▅▆▅███▇██▇▆▅▄▆▆▆▆▇▆▆▆▅▆▅▄▄▃▄ █
  1.74 μs      Histogram: log(frequency) by time      3.57 μs <

 Memory estimate: 272 bytes, allocs estimate: 4.
```

##### Sorting-based functions
```julia
julia> A = rand(10_000);

julia> sort(A) == vsort!(A)
true

julia> median(A) == vmedian!(A)
true

julia> @benchmark median!(A) setup = A = rand(100)
BenchmarkTools.Trial: 10000 samples with 252 evaluations.
 Range (min … max):  303.964 ns … 836.444 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     310.599 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   313.896 ns ±  21.261 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

   ▃▆█▇▅▂                                                     ▁ ▂
  ▆██████▇██▇▆▆▅██▆▆▃▁▄▁▃▄▅▄▄▃▄▄▄▄▃▃▇██▅▃▁▃▄▁▁▁▁▄▁▃▃▅▁▁▃▁▁▁▁▄▇█ █
  304 ns        Histogram: log(frequency) by time        410 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark vmedian!(A) setup = A = rand(100)
BenchmarkTools.Trial: 10000 samples with 964 evaluations.
 Range (min … max):  83.265 ns … 264.730 ns  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     83.922 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   91.276 ns ±  17.672 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  █▃▁ ▄      ▄        ▄                                      ▃ ▁
  ███▇█▇▇▇▆▆▆███▆▅▄▅▆▆█▆█▆▅▅▅▄▅▅▆▆▄▅▄▄▄▅▅▄▃▂▃▄▂▄▃▃▅▄▃▄▃▃▃▃▃▃▃█ █
  83.3 ns       Histogram: log(frequency) by time       163 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark median!(A) setup = A = rand(10_000)
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):   62.251 μs … 395.476 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     112.049 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   111.940 μs ±  18.669 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%

                     ▁▂▃▄▄▅▅▇▆█▇▇▇▇▆▅▆▄▂▂                        
  ▁▁▁▂▂▂▂▃▃▄▃▄▅▅▆▇▆███████████████████████▇▅▄▃▂▃▂▂▂▂▁▁▂▁▂▁▁▁▁▁▁ ▄
  62.3 μs          Histogram: frequency by time          168 μs <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark vmedian!(A) setup = A = rand(10_000)
BenchmarkTools.Trial: 10000 samples with 5 evaluations.
 Range (min … max):  16.293 μs … 71.305 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     27.381 μs              ┊ GC (median):    0.00%
 Time  (mean ± σ):   27.907 μs ±  5.386 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%

              ▁▂▃▅▅▆█▇▇▇▆▄▁                                    
  ▁▁▁▂▃▃▄▄▅▆▇███████████████▆▅▄▄▃▃▃▂▂▂▂▂▂▂▂▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ▃
  16.3 μs         Histogram: frequency by time        50.5 μs <

 Memory estimate: 0 bytes, allocs estimate: 0.
```

#### TODO
* Median and percentile could be made more efficient with better SIMD sorting
* Other various summary statistics (mad, aad, etc.?)
* multithreaded vminimum, vmaximum, vextrema


[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://brenhinkeller.github.io/VectorizedStatistics.jl/stable
[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://brenhinkeller.github.io/VectorizedStatistics.jl/dev
[ci-img]: https://github.com/brenhinkeller/VectorizedStatistics.jl/workflows/CI/badge.svg
[ci-url]: https://github.com/brenhinkeller/VectorizedStatistics.jl/actions
[codecov-img]: https://codecov.io/gh/brenhinkeller/VectorizedStatistics.jl/branch/main/graph/badge.svg
[codecov-url]: https://codecov.io/gh/brenhinkeller/VectorizedStatistics.jl
