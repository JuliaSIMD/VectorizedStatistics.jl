module VectorizedStatistics

    using LoopVectorization, Static

    _dim(::Type{StaticInt{N}}) where {N} = N::Int
    const IntOrStaticInt = Union{Integer, StaticInt}

    # Implemented by reduction, recursively
    include("vreducibles.jl")

    # Implemented with @generated functions, single- and multithreaded
    include("vmean.jl")
    include("vsum.jl")
    include("vvar.jl")
    include("vstd.jl")
    include("vcov.jl")

    # Sorting-based statistics
    include("quicksort.jl")
    include("argsort.jl")
    include("vsort.jl")
    include("vmedian.jl")
    include("vquantile.jl")

end
