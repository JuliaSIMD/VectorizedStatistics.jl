module VectorizedStatistics

    using LoopVectorization, Static

    _dim(::Type{StaticInt{N}}) where {N} = N::Int

    # Implemented by reduction, recursively
    include("vreducibles.jl")

    # Implemented with @generated functions, singlethreaded (@turbo)
    include("vmean.jl")
    include("vsum.jl")
    include("vvar.jl")
    include("vcov.jl")

    # Implemented with @generated functions, multithreaded (@tturbo)
    include("vtmean.jl")
    include("vtsum.jl")
    include("vtvar.jl")
    include("vtcov.jl")


end
