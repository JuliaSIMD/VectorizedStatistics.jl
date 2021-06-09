var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = VectorizedStatistics","category":"page"},{"location":"#VectorizedStatistics","page":"Home","title":"VectorizedStatistics","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for VectorizedStatistics.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [VectorizedStatistics]","category":"page"},{"location":"#VectorizedStatistics.vmaximum-Tuple{Any}","page":"Home","title":"VectorizedStatistics.vmaximum","text":"vmaximum(A; dims)\n\nAs Base.maximum, but vectorized: find the greatest value contained in A, optionally over dimensions specified by dims.\n\nExamples\n\njulia> using VectorizedStatistics\n\njulia> A = [1 2; 3 4]\n2×2 Matrix{Int64}:\n 1  2\n 3  4\n\njulia> vmaximum(A, dims=1)\n1×2 Matrix{Int64}:\n 3  4\n\njulia>  vmaximum(A, dims=2)\n 2×1 Matrix{Int64}:\n 2\n 4\n\n\n\n\n\n","category":"method"},{"location":"#VectorizedStatistics.vmean-Tuple{Any}","page":"Home","title":"VectorizedStatistics.vmean","text":"vmean(A; dims)\n\nAs Statistics.mean, but vectorized: compute the mean of all elements in A, optionally over dimensions specified by dims.\n\nExamples\n\njulia> using VectorizedStatistics\n\njulia> A = [1 2; 3 4]\n2×2 Matrix{Int64}:\n 1  2\n 3  4\n\njulia> vmean(A, dims=1)\n1×2 Matrix{Float64}:\n 2.0  3.0\n\njulia> vmean(A, dims=2)\n2×1 Matrix{Float64}:\n 1.5\n 3.5\n\n\n\n\n\n","category":"method"},{"location":"#VectorizedStatistics.vminimum-Tuple{Any}","page":"Home","title":"VectorizedStatistics.vminimum","text":"vminimum(A; dims)\n\nAs Base.minimum, but vectorized: find the least value contained in A, optionally over dimensions specified by dims.\n\nExamples\n\njulia> using VectorizedStatistics\n\njulia> A = [1 2; 3 4]\n2×2 Matrix{Int64}:\n 1  2\n 3  4\n\njulia> vminimum(A, dims=1)\n1×2 Matrix{Int64}:\n 1  2\n\njulia>  vminimum(A, dims=2)\n 2×1 Matrix{Int64}:\n 1\n 3\n\n\n\n\n\n","category":"method"},{"location":"#VectorizedStatistics.vsum-Tuple{Any}","page":"Home","title":"VectorizedStatistics.vsum","text":"vsum(A; dims)\n\nAs Base.sum, but vectorized: summate the values contained in A, optionally over dimensions specified by dims.\n\nExamples\n\njulia> using VectorizedStatistics\n\njulia> A = [1 2; 3 4]\n2×2 Matrix{Int64}:\n 1  2\n 3  4\n\njulia> vsum(A, dims=1)\n1×2 Matrix{Int64}:\n 4  6\n\njulia> vsum(A, dims=2)\n 2×1 Matrix{Int64}:\n 3\n 7\n\n\n\n\n\n","category":"method"},{"location":"#VectorizedStatistics.vvar-Tuple{Any}","page":"Home","title":"VectorizedStatistics.vvar","text":"vvar(A; dims=:, mean=nothing, corrected=true)\n\nAs Statistics.var, but vectorized: compute the variance of all elements in A, optionally over dimensions specified by dims. A precomputed mean may optionally be provided, which results in a somewhat faster calculation. If corrected is true, then Bessel's correction is applied.\n\nExamples\n\njulia> using VectorizedStatistics\n\njulia> A = [1 2; 3 4]\n2×2 Matrix{Int64}:\n 1  2\n 3  4\n\njulia> vvar(A, dims=1)\n1×2 Matrix{Float64}:\n 2.0  2.0\n\njulia> vvar(A, dims=2)\n2×1 Matrix{Float64}:\n 0.5\n 0.5\n\n\n\n\n\n","category":"method"}]
}
