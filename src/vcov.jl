function _vcov(x::AbstractVector, y::AbstractVector, corrected::Bool, μᵪ::Number, μᵧ::Number, multithreaded::False)
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

function _vcov(x::AbstractVector, y::AbstractVector, corrected::Bool, μᵪ::Number, μᵧ::Number, multithreaded::True)
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
vcov(x::AbstractVector, y::AbstractVector; corrected::Bool=true, multithreaded=false)
```
Compute the covariance between the vectors `x` and `y`.
As `Statistics.cov`, but vectorized and (optionally) multithreaded.

If `corrected` is `true` as is the default, _Bessel's correction_ will be applied,
such that the sum is scaled by `n-1` rather than `n`, where `n = length(x)`.
"""
vcov(x::AbstractVector, y::AbstractVector; corrected::Bool=true, multithreaded=False()) = _vcov(x, y, corrected, multithreaded)
_vcov(x::AbstractVector, y::AbstractVector, corrected, multithreaded::Symbol) = _vcov(x, y, corrected, (multithreaded==:auto && length(x) > 4095) ? True() : False())
_vcov(x::AbstractVector, y::AbstractVector, corrected, multithreaded::Bool) = _vcov(x, y, corrected, static(multithreaded))
function _vcov(x::AbstractVector, y::AbstractVector, corrected::Bool, multithreaded::StaticBool)
    # Check lengths
    nᵪ = length(x)
    nᵧ = length(y)
    @assert nᵪ == nᵧ

    μᵪ = _vmean(x, :, multithreaded)
    μᵧ = _vmean(y, :, multithreaded)
    σᵪᵧ = _vcov(x, y, corrected, μᵪ, μᵧ, multithreaded)
    return σᵪᵧ
end

"""
```julia
vcov(X::AbstractMatrix; dims::Int=1, corrected::Bool=true, multithreaded=false)
```
Compute the covariance matrix of the matrix `X`, along dimension `dims`.
As `Statistics.cov`, but vectorized and (optionally) multithreaded.

If `corrected` is `true` as is the default, _Bessel's correction_ will be applied,
such that the sum is scaled by `n-1` rather than `n`, where `n = length(x)`.
"""
vcov(X::AbstractMatrix; dims::Int=1, corrected::Bool=true, multithreaded=False()) = _vcov(X, dims, corrected, multithreaded)
export vcov

_vcov(X::AbstractMatrix, dims, corrected, multithreaded::Symbol) = _vcov(X, dims, corrected, (multithreaded===:auto && size(X,1) > 4095) ? True() : False())
_vcov(X::AbstractMatrix, dims, corrected, multithreaded::Bool) = _vcov(X, dims, corrected, static(multithreaded))
function _vcov(X, dims, corrected, multithreaded::StaticBool)
    Tₒ = Base.promote_op(/, eltype(X), Int)
    n = size(X, dims)
    m = size(X, mod(dims,2)+1)
    Σ = similar(X, Tₒ, (m, m))
    # Only two dimensions are possible, so handle each manually
    if dims == 1
        # Precalculate means for each column
        μ = ntuple(m) do d
            _vmean(view(X,:,d),:,multithreaded)
        end
        # Fill covariance matrix symmetrically
        @inbounds for i = 1:m
            for j = 1:i
                σᵢⱼ = _vcov(view(X,:,i), view(X,:,j), corrected, μ[i], μ[j], multithreaded)
                Σ[i,j] = Σ[j,i] = σᵢⱼ
            end
        end
    elseif dims == 2
        # Precalculate means for each row
        μ = ntuple(m) do d
            _vmean(view(X,d,:),:,True())
        end
        # Fill covariance matrix symmetrically
        @inbounds for i = 1:m
            for j = 1:i
                σᵢⱼ = _vcov(view(X,i,:), view(X,j,:), corrected, μ[i], μ[j], multithreaded)
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
vcor(x::AbstractVector, y::AbstractVector, multithreaded=false)
```
Compute the (Pearson's product-moment) correlation between the vectors `x` and `y`.
As `Statistics.cor`, but vectorized and (optionally) multithreaded.

Equivalent to `cov(x,y) / (std(x) * std(y))`.
"""
vcor(x::AbstractVector, y::AbstractVector; corrected::Bool=true, multithreaded=False()) = _vcor(x, y, corrected, multithreaded)
_vcor(x::AbstractVector, y::AbstractVector, corrected, multithreaded::Symbol) = _vcor(x, y, corrected, (multithreaded===:auto && length(x) > 4095) ? True() : False())
_vcor(x::AbstractVector, y::AbstractVector, corrected, multithreaded::Bool) = _vcor(x, y, corrected, static(multithreaded))
function _vcor(x::AbstractVector, y::AbstractVector, corrected::Bool, multithreaded::StaticBool)
    # Check lengths
    nᵪ = length(x)
    nᵧ = length(y)
    @assert nᵪ == nᵧ

    μᵪ = _vmean(x, :, multithreaded)
    μᵧ = _vmean(y, :, multithreaded)
    σᵪ = _vstd(μᵪ, corrected, x, :, multithreaded)
    σᵧ = _vstd(μᵧ, corrected, y, :, multithreaded)
    σᵪᵧ = _vcov(x, y, corrected, μᵪ, μᵧ, multithreaded)

    ρᵪᵧ = σᵪᵧ / (σᵪ * σᵧ)
    return ρᵪᵧ
end


"""
```julia
vcor(X::AbstractMatrix; dims::Int=1, multithreaded=false)
```
Compute the (Pearson's product-moment) correlation matrix of the matrix `X`,
along dimension `dims`. As `Statistics.cor`, but vectorized and (optionally)
multithreaded.
"""
vcor(X::AbstractMatrix; dims::Int=1, corrected::Bool=true, multithreaded=False()) = _vcor(X, dims, corrected, multithreaded)
export vcor

_vcor(X::AbstractMatrix, dims, corrected, multithreaded::Symbol) = _vcor(X, dims, corrected, (multithreaded===:auto && size(X,1) > 4095) ? True() : False())
_vcor(X::AbstractMatrix, dims, corrected, multithreaded::Bool) = _vcor(X, dims, corrected, static(multithreaded))
function _vcor(X, dims, corrected, multithreaded::StaticBool)
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
            _vmean(view(X,:,d), :, multithreaded)
        end
        σ = ntuple(m) do d
            _vstd(μ[d], corrected, view(X,:,d), :, multithreaded)
        end
        # Fill off-diagonals symmetrically
        @inbounds for i = 1:m
            for j = 1:i
                σᵢⱼ = _vcov(view(X,:,i), view(X,:,j), corrected, μ[i], μ[j], multithreaded)
                Ρ[i,j] = Ρ[j,i] = σᵢⱼ / (σ[i] * σ[j])
            end
        end
    elseif dims == 2
        # Precalculate means and standard deviations
        μ = ntuple(m) do d
            _vmean(view(X,d,:), :, multithreaded)
        end
        σ = ntuple(m) do d
            _vstd(μ[d], corrected, view(X,d,:), :, multithreaded)
        end
        @inbounds for i = 1:m
            for j = 1:i-1
                σᵢⱼ = _vcov(view(X,i,:), view(X,j,:), corrected, μ[i], μ[j], multithreaded)
                Ρ[i,j] = Ρ[j,i] = σᵢⱼ / (σ[i] * σ[j])
            end
        end
    else
        throw("Dimension not in range")
    end
    return Ρ
end
