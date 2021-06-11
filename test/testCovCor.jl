# Test pair-wise correlation and covariance functions
x, y = rand(1000), rand(1000)

@test vcov(x,y) ≈ cov(x,y)
@test vcor(x,y) ≈ cor(x,y)


# Test correlation and covariance functions as applied to matrices
X = rand(100,10)

@test vcov(X) ≈ cov(X)
@test vcov(X, dims=1) ≈ cov(X, dims=1)
@test vcov(X, dims=2) ≈ cov(X, dims=2)

@test vcor(X) ≈ cor(X)
@test vcor(X, dims=1) ≈ cor(X, dims=1)
@test vcor(X, dims=2) ≈ cor(X, dims=2)
