module VectorizedStatistics

    using LoopVectorization, Static
    import LoopVectorization.vsum # Will add more specific method for ::StridedArray

    const IntOrStaticInt = Union{Integer, StaticInt}
    _dim(::Type{StaticInt{N}}) where {N} = N::Int

    # Dropdims if there are dims to be dropped
    reducedims(A, dims) = A
    reducedims(A::AbstractVector, dims) = A
    reducedims(A::AbstractArray, dims) = dropdims(A; dims)

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

    # Fully precompile some commonly-used methods
    using PrecompileTools
    include("precompile.jl")

end
