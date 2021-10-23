function _vtcov(x::AbstractVector, y::AbstractVector, corrected::Bool, μᵪ::Number, μᵧ::Number)
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


"""
```julia
vtcov(x::AbstractVector, y::AbstractVector; corrected::Bool=true)
```
Compute the covariance between the vectors `x` and `y`.
As `Statistics.cov`, but vectorized and multithreaded.

If `corrected` is `true` as is the default, _Bessel's correction_ will be applied,
such that the sum is scaled by `n-1` rather than `n`, where `n = length(x)`.
"""
function vtcov(x::AbstractVector, y::AbstractVector; corrected::Bool=true)
    # Check lengths
    nᵪ = length(x)
    nᵧ = length(y)
    @assert nᵪ == nᵧ

    μᵪ = _vtmean(x,:)
    μᵧ = _vtmean(y,:)
    σᵪᵧ = _vtcov(x, y, corrected, μᵪ, μᵧ)
    return σᵪᵧ
end

"""
```julia
vtcov(X::AbstractMatrix; dims::Int=1, corrected::Bool=true)
```
Compute the covariance matrix of the matrix `X`, along dimension `dims`.
As `Statistics.cov`, but vectorized and multithreaded.

If `corrected` is `true` as is the default, _Bessel's correction_ will be applied,
such that the sum is scaled by `n-1` rather than `n`, where `n = length(x)`.
"""
function vtcov(X::AbstractMatrix; dims::Int=1, corrected::Bool=true)
    Tₒ = Base.promote_op(/, eltype(X), Int)
    n = size(X, dims)
    m = size(X, mod(dims,2)+1)
    Σ = similar(X, Tₒ, (m, m))
    # Only two dimensions are possible, so handle each manually
    if dims == 1
        # Precalculate means for each column
        μ = ntuple(m) do d
            vtmean(view(X,:,d))
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
            vtmean(view(X,d,:))
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
export vtcov



"""
```julia
vtcor(x::AbstractVector, y::AbstractVector)
```
Compute the (Pearson's product-moment) correlation between the vectors `x` and `y`.
As `Statistics.cor`, but vectorized and multithreaded.

Equivalent to `cov(x,y) / (std(x) * std(y))`.
"""
function vtcor(x::AbstractVector, y::AbstractVector; corrected::Bool=true)
    # Check lengths
    nᵪ = length(x)
    nᵧ = length(y)
    @assert nᵪ == nᵧ

    μᵪ = vtmean(x)
    μᵧ = vtmean(y)
    σᵪ = vtstd(x, mean=μᵪ, corrected=corrected)
    σᵧ = vtstd(y, mean=μᵧ, corrected=corrected)
    σᵪᵧ = _vtcov(x, y, corrected, μᵪ, μᵧ)
    ρᵪᵧ = σᵪᵧ / (σᵪ * σᵧ)

    return ρᵪᵧ
end


"""
```julia
vtcor(X::AbstractMatrix; dims::Int=1)
```
Compute the (Pearson's product-moment) correlation matrix of the matrix `X`,
along dimension `dims`. As `Statistics.cor`, but vectorized.
"""
function vtcor(X::AbstractMatrix; dims::Int=1, corrected::Bool=true)
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
            vtmean(view(X,:,d))
        end
        σ = ntuple(m) do d
            vtstd(view(X,:,d), mean=μ[d], corrected=corrected)
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
            vtmean(view(X,d,:))
        end
        σ = ntuple(m) do d
            vtstd(view(X,d,:), mean=μ[d], corrected=corrected)
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
export vtcor
