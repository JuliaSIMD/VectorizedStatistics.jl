# Test pair-wise correlation and covariance functions
x, y = rand(1000), rand(1000)

@test vtcov(x,y) ≈ vcov(x,y) ≈ cov(x,y)
@test vtcov(x,y, corrected=false) ≈ vcov(x,y, corrected=false) ≈ cov(x,y, corrected=false)
@test vtcor(x,y) ≈ vcor(x,y) ≈ cor(x,y)


# Test correlation and covariance functions as applied to matrices
X = rand(100,10)

@test vtcov(X) ≈ vcov(X) ≈ cov(X)
@test vtcov(X, dims=1) ≈ vcov(X, dims=1) ≈ cov(X, dims=1)
@test vtcov(X, dims=2) ≈ vcov(X, dims=2) ≈ cov(X, dims=2)
@test vtcov(X, corrected=false) ≈ vcov(X, corrected=false) ≈ cov(X, corrected=false)

@test vtcor(X) ≈ vcor(X) ≈ cor(X)
@test vtcor(X, dims=1) ≈ vcor(X, dims=1) ≈ cor(X, dims=1)
@test vtcor(X, dims=2) ≈ vcor(X, dims=2) ≈ cor(X, dims=2)
