module VectorizedStatistics

    using LoopVectorization, Static

    _dim(::Type{StaticInt{N}}) where {N} = N::Int

    include("vreduceables.jl")
    include("vmean.jl")
    # include("vstd.jl")
    # include("vvar.jl")

end
