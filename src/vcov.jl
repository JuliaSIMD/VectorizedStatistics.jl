function _vcov(x::AbstractVector, y::AbstractVector, corrected::Bool, μᵪ::Number, μᵧ::Number)
    # Calculate covariance
    σᵪᵧ = zero(promote_type(typeof(μᵪ), typeof(μᵧ), Int))
    @turbo for i ∈ indices((x,y))
            δᵪ = x[i] - μᵪ
            δᵧ = y[i] - μᵧ
            σᵪᵧ += δᵪ * δᵧ
    end
    σᵪᵧ = σᵪᵧ / (length(x)-corrected)
    return σᵪᵧ
end

function _vtcov(x::AbstractVector, y::AbstractVector, corrected::Bool, μᵪ::Number, μᵧ::Number)
    # Calculate covariance
    σᵪᵧ = zero(promote_type(typeof(μᵪ), typeof(μᵧ), Int))
    @tturbo for i ∈ indices((x,y))
            δᵪ = x[i] - μᵪ
            δᵧ = y[i] - μᵧ
            σᵪᵧ += δᵪ * δᵧ
    end
    σᵪᵧ = σᵪᵧ / (length(x)-corrected)
    return σᵪᵧ
end

"""
```julia
vcov(x::AbstractVector, y::AbstractVector; corrected::Bool=true, multithreaded=:auto)
```
Compute the covariance between the vectors `x` and `y`.
As `Statistics.cov`, but vectorized and (optionally) multithreaded.

If `corrected` is `true` as is the default, _Bessel's correction_ will be applied,
such that the sum is scaled by `n-1` rather than `n`, where `n = length(x)`.
"""
function vcov(x::AbstractVector, y::AbstractVector; corrected::Bool=true, multithreaded=:auto)
    # Check lengths
    nᵪ = length(x)
    nᵧ = length(y)
    @assert nᵪ == nᵧ

    if (multithreaded==:auto && length(x) > 4095) || multithreaded==true
        μᵪ = _vtmean(x,:)
        μᵧ = _vtmean(y,:)
        σᵪᵧ = _vtcov(x, y, corrected, μᵪ, μᵧ)
    else
        μᵪ = _vmean(x,:)
        μᵧ = _vmean(y,:)
        σᵪᵧ = _vcov(x, y, corrected, μᵪ, μᵧ)
    end
    return σᵪᵧ
end

"""
```julia
vcov(X::AbstractMatrix; dims::Int=1, corrected::Bool=true, multithreaded=:auto)
```
Compute the covariance matrix of the matrix `X`, along dimension `dims`.
As `Statistics.cov`, but vectorized and (optionally) multithreaded.

If `corrected` is `true` as is the default, _Bessel's correction_ will be applied,
such that the sum is scaled by `n-1` rather than `n`, where `n = length(x)`.
"""
function vcov(X::AbstractMatrix; dims::Int=1, corrected::Bool=true, multithreaded=:auto)
    if (multithreaded===:auto && length(X) > 4095) || multithreaded===true
        _vtcov(X, dims, corrected)
    else
        _vcov(X, dims, corrected)
    end
end
export vcov

function _vcov(X, dims, corrected)
    Tₒ = Base.promote_op(/, eltype(X), Int)
    n = size(X, dims)
    m = size(X, mod(dims,2)+1)
    Σ = similar(X, Tₒ, (m, m))
    # Only two dimensions are possible, so handle each manually
    if dims == 1
        # Precalculate means for each column
        μ = ntuple(m) do d
            vmean(view(X,:,d))
        end
        # Fill covariance matrix symmetrically
        @inbounds for i = 1:m
            for j = 1:i
                σᵢⱼ = _vcov(view(X,:,i), view(X,:,j), corrected, μ[i], μ[j])
                Σ[i,j] = Σ[j,i] = σᵢⱼ
            end
        end
    elseif dims == 2
        # Precalculate means for each row
        μ = ntuple(m) do d
            vmean(view(X,d,:))
        end
        # Fill covariance matrix symmetrically
        @inbounds for i = 1:m
            for j = 1:i
                σᵢⱼ = _vcov(view(X,i,:), view(X,j,:), corrected, μ[i], μ[j])
                Σ[i,j] = Σ[j,i] = σᵢⱼ
            end
        end
    else
        throw("Dimension not in range")
    end
    return Σ
end

function _vtcov(X, dims, corrected)
    Tₒ = Base.promote_op(/, eltype(X), Int)
    n = size(X, dims)
    m = size(X, mod(dims,2)+1)
    Σ = similar(X, Tₒ, (m, m))
    # Only two dimensions are possible, so handle each manually
    if dims == 1
        # Precalculate means for each column
        μ = ntuple(m) do d
            _vtmean(view(X,:,d),:)
        end
        # Fill covariance matrix symmetrically
        @inbounds for i = 1:m
            for j = 1:i
                σᵢⱼ = _vtcov(view(X,:,i), view(X,:,j), corrected, μ[i], μ[j])
                Σ[i,j] = Σ[j,i] = σᵢⱼ
            end
        end
    elseif dims == 2
        # Precalculate means for each row
        μ = ntuple(m) do d
            _vtmean(view(X,d,:),:)
        end
        # Fill covariance matrix symmetrically
        @inbounds for i = 1:m
            for j = 1:i
                σᵢⱼ = _vtcov(view(X,i,:), view(X,j,:), corrected, μ[i], μ[j])
                Σ[i,j] = Σ[j,i] = σᵢⱼ
            end
        end
    else
        throw("Dimension not in range")
    end
    return Σ
end

"""
```julia
vcor(x::AbstractVector, y::AbstractVector, multithreaded=:auto)
```
Compute the (Pearson's product-moment) correlation between the vectors `x` and `y`.
As `Statistics.cor`, but vectorized and (optionally) multithreaded.

Equivalent to `cov(x,y) / (std(x) * std(y))`.
"""
function vcor(x::AbstractVector, y::AbstractVector; corrected::Bool=true, multithreaded=:auto)
    # Check lengths
    nᵪ = length(x)
    nᵧ = length(y)
    @assert nᵪ == nᵧ

    if (multithreaded==:auto && length(x) > 4095) || multithreaded==true
        μᵪ = _vtmean(x,:)
        μᵧ = _vtmean(y,:)
        σᵪ = _vtstd(μᵪ, corrected, x, :)
        σᵧ = _vtstd(μᵧ, corrected, y, :)
        σᵪᵧ = _vtcov(x, y, corrected, μᵪ, μᵧ)
    else
        μᵪ = _vmean(x,:)
        μᵧ = _vmean(y,:)
        σᵪ = _vstd(μᵪ, corrected, x, :)
        σᵧ = _vstd(μᵧ, corrected, y, :)
        σᵪᵧ = _vcov(x, y, corrected, μᵪ, μᵧ)
    end
    ρᵪᵧ = σᵪᵧ / (σᵪ * σᵧ)
    return ρᵪᵧ
end


"""
```julia
vcor(X::AbstractMatrix; dims::Int=1, multithreaded=:auto)
```
Compute the (Pearson's product-moment) correlation matrix of the matrix `X`,
along dimension `dims`. As `Statistics.cor`, but vectorized and (optionally)
multithreaded.
"""
function vcor(X::AbstractMatrix; dims::Int=1, corrected::Bool=true, multithreaded=:auto)
    if (multithreaded===:auto && length(X) > 4095) || multithreaded===true
        _vtcor(X, dims, corrected)
    else
        _vcor(X, dims, corrected)
    end
end
export vcor

function _vcor(X, dims, corrected)
    Tₒ = Base.promote_op(/, eltype(X), Int)
    n = size(X, dims)
    m = size(X, mod(dims,2)+1)
    Ρ = similar(X, Tₒ, (m, m))
    # Diagonal must be unity
    @inbounds for i = 1:m
        Ρ[i,i] = one(Tₒ)
    end
    # Only two dimensions are possible, so handle each manually
    if dims == 1
        # Precalculate means and standard deviations
        μ = ntuple(m) do d
            _vmean(view(X,:,d),:)
        end
        σ = ntuple(m) do d
            _vstd(μ[d], corrected, view(X,:,d), :)
        end
        # Fill off-diagonals symmetrically
        @inbounds for i = 1:m
            for j = 1:i
                σᵢⱼ = _vcov(view(X,:,i), view(X,:,j), corrected, μ[i], μ[j])
                Ρ[i,j] = Ρ[j,i] = σᵢⱼ / (σ[i] * σ[j])
            end
        end
    elseif dims == 2
        # Precalculate means and standard deviations
        μ = ntuple(m) do d
            _vmean(view(X,d,:),:)
        end
        σ = ntuple(m) do d
            _vstd(μ[d], corrected, view(X,d,:), :)
        end
        @inbounds for i = 1:m
            for j = 1:i-1
                σᵢⱼ = _vcov(view(X,i,:), view(X,j,:), corrected, μ[i], μ[j])
                Ρ[i,j] = Ρ[j,i] = σᵢⱼ / (σ[i] * σ[j])
            end
        end
    else
        throw("Dimension not in range")
    end
    return Ρ
end

function _vtcor(X, dims, corrected)
    Tₒ = Base.promote_op(/, eltype(X), Int)
    n = size(X, dims)
    m = size(X, mod(dims,2)+1)
    Ρ = similar(X, Tₒ, (m, m))
    # Diagonal must be unity
    @inbounds for i = 1:m
        Ρ[i,i] = one(Tₒ)
    end
    # Only two dimensions are possible, so handle each manually
    if dims == 1
        # Precalculate means and standard deviations
        μ = ntuple(m) do d
            _vtmean(view(X,:,d),:)
        end
        σ = ntuple(m) do d
            _vtstd(μ[d], corrected, view(X,:,d), :)
        end
        # Fill off-diagonals symmetrically
        @inbounds for i = 1:m
            for j = 1:i
                σᵢⱼ = _vtcov(view(X,:,i), view(X,:,j), corrected, μ[i], μ[j])
                Ρ[i,j] = Ρ[j,i] = σᵢⱼ / (σ[i] * σ[j])
            end
        end
    elseif dims == 2
        # Precalculate means and standard deviations
        μ = ntuple(m) do d
            _vtmean(view(X,d,:),:)
        end
        σ = ntuple(m) do d
            _vtstd(μ[d], corrected, view(X,d,:), :)
        end
        @inbounds for i = 1:m
            for j = 1:i-1
                σᵢⱼ = _vtcov(view(X,i,:), view(X,j,:), corrected, μ[i], μ[j])
                Ρ[i,j] = Ρ[j,i] = σᵢⱼ / (σ[i] * σ[j])
            end
        end
    else
        throw("Dimension not in range")
    end
    return Ρ
end
