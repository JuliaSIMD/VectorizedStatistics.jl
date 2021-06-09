# VectorizedStatistics

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://brenhinkeller.github.io/VectorizedStatistics.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://brenhinkeller.github.io/VectorizedStatistics.jl/dev)
[![Build Status](https://github.com/brenhinkeller/VectorizedStatistics.jl/workflows/CI/badge.svg)](https://github.com/brenhinkeller/VectorizedStatistics.jl/actions)
[![Coverage](https://codecov.io/gh/brenhinkeller/VectorizedStatistics.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/brenhinkeller/VectorizedStatistics.jl)

Fast, [LoopVectorization.jl](https://github.com/JuliaSIMD/LoopVectorization.jl)-based summary statistics.

#### Implemented by reduction, recursively
* `vminimum`
* `vmaximum`
* `vsum`

#### Implemented directly by compile-time loop generation
* `vmean`
* `vvar`
* `vstd`
