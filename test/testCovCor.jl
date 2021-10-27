# Test pair-wise correlation and covariance functions
x, y = rand(1000), rand(1000)

@test vcov(x,y, multithreaded=true) ≈ vcov(x,y, multithreaded=false) ≈ cov(x,y)
@test vcov(x,y, corrected=false, multithreaded=true) ≈ vcov(x,y, corrected=false, multithreaded=false) ≈ cov(x,y, corrected=false)
@test vcor(x,y, multithreaded=true) ≈ vcor(x,y, multithreaded=false) ≈ cor(x,y)


# Test correlation and covariance functions as applied to matrices
X = rand(100,10)

@test vcov(X, multithreaded=true) ≈ vcov(X, multithreaded=false) ≈ cov(X)
@test vcov(X, dims=1, multithreaded=true) ≈ vcov(X, dims=1, multithreaded=false) ≈ cov(X, dims=1)
@test vcov(X, dims=2, multithreaded=true) ≈ vcov(X, dims=2, multithreaded=false) ≈ cov(X, dims=2)
@test vcov(X, corrected=false, multithreaded=true) ≈ vcov(X, corrected=false, multithreaded=false) ≈ cov(X, corrected=false)

@test vcor(X, multithreaded=true) ≈ vcor(X, multithreaded=false) ≈ cor(X)
@test vcor(X, dims=1, multithreaded=true) ≈ vcor(X, dims=1, multithreaded=false) ≈ cor(X, dims=1)
@test vcor(X, dims=2, multithreaded=true) ≈ vcor(X, dims=2, multithreaded=false) ≈ cor(X, dims=2)
