module VectorizedStatistics

    using LoopVectorization, Static

    _dim(::Type{StaticInt{N}}) where {N} = N::Int

    include("vreducibles.jl")
    include("vmean.jl")
    include("vvar.jl")
    # include("vstd.jl")

end
