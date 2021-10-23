## ---  Test equivalence to Base/Stdlib for other summary statistics

    # Test vmean
    for nd = 1:5
        @info "Testing vmean: $nd-dimensional arrays"
        # Generate random array
        A = rand((2 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        μ = mean(A)
        @test vmean(A) ≈ μ
        @test vtmean(A) ≈ μ

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vmean: reduction over dimension $i"
            μ = mean(A, dims=i)
            @test vmean(A, dims=i) ≈ μ
            @test vtmean(A, dims=i) ≈ μ
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vmean: reduction over dimensions $((j,i))"
                    μ = mean(A, dims=(j,i))
                    @test vmean(A, dims=(j,i)) ≈ μ
                    @test vtmean(A, dims=(j,i)) ≈ μ
                end
            end
        end

        # Test equivalence when reducing over three dimensions
        if nd > 2
            for i = 3:nd
                for j = 2:i-1
                    for k = 1:j-1
                        @info "Testing vmean: reduction over dimensions $((k,j,i))"
                        μ = mean(A, dims=(k,j,i))
                        @test vmean(A, dims=(k,j,i)) ≈ μ
                        @test vtmean(A, dims=(k,j,i)) ≈ μ
                    end
                end
            end
        end

        # Test equivalence when reducing over four dimensions
        if nd > 3
            for i = 4:nd
                for j = 2:i-1
                    for k = 1:j-1
                        for l = 1:k-1
                            @info "Testing vmean: reduction over dimensions $((l,k,j,i))"
                            μ = mean(A, dims=(l,k,j,i))
                            @test vmean(A, dims=(l,k,j,i)) ≈ μ
                            @test vtmean(A, dims=(l,k,j,i)) ≈ μ
                        end
                    end
                end
            end
        end
    end


    # Test vvar
    for nd = 1:5
        @info "Testing vvar: $nd-dimensional arrays"
        # Generate random array
        A = randn((2 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        σ² = var(A, corrected=false)
        @test vvar(A, corrected=false) ≈ σ²
        @test vtvar(A, corrected=false) ≈ σ²

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vvar: reduction over dimension $i"
            σ² = var(A, dims=i, corrected=false)
            @test vvar(A, dims=i, corrected=false) ≈ σ²
            @test vtvar(A, dims=i, corrected=false) ≈ σ²
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vvar: reduction over dimensions $((j,i))"
                    σ² = var(A, dims=(j,i), corrected=false)
                    @test vvar(A, dims=(j,i), corrected=false) ≈ σ²
                    @test vtvar(A, dims=(j,i), corrected=false) ≈ σ²
                end
            end
        end

        # Test equivalence when reducing over three dimensions
        if nd > 2
            for i = 3:nd
                for j = 2:i-1
                    for k = 1:j-1
                        @info "Testing vvar: reduction over dimensions $((k,j,i))"
                        σ² = var(A, dims=(k,j,i))
                        @test vvar(A, dims=(k,j,i)) ≈ σ²
                        @test vtvar(A, dims=(k,j,i)) ≈ σ²
                    end
                end
            end
        end
    end


    # Test vstd
    for nd = 1:5
        @info "Testing vstd: $nd-dimensional arrays"
        # Generate random array
        A = randn((2 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        @test vtstd(A) ≈ vstd(A) ≈ std(A)
        @test vtstd(A, corrected=false) ≈ vstd(A, corrected=false) ≈ std(A, corrected=false)

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vstd: reduction over dimension $i"
            @test vtstd(A, dims=i) ≈ vstd(A, dims=i) ≈ std(A, dims=i)
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vstd: reduction over dimensions $((j,i))"
                    @test vstd(A, dims=(j,i)) ≈ std(A, dims=(j,i))
                end
            end
        end

        # Test equivalence when reducing over three dimensions
        if nd > 2
            for i = 3:nd
                for j = 2:i-1
                    for k = 1:j-1
                        @info "Testing vstd: reduction over dimensions $((k,j,i))"
                        @test vstd(A, dims=(k,j,i)) ≈ std(A, dims=(k,j,i))
                    end
                end
            end
        end

        # Test equivalence when reducing over four dimensions
        if nd > 3
            for i = 4:nd
                for j = 2:i-1
                    for k = 1:j-1
                        for l = 1:k-1
                            @info "Testing vstd: reduction over dimensions $((l,k,j,i))"
                            @test vstd(A, dims=(l,k,j,i)) ≈ std(A, dims=(l,k,j,i))
                        end
                    end
                end
            end
        end
    end

    # Test fallbacks for complex reductions
    A = randn((2 .+ (1:6))...);
    @test vmean(A, dims=(4,5,6)) ≈ mean(A, dims=(4,5,6))
    @test vstd(A, dims=(4,5,6)) ≈ std(A, dims=(4,5,6))
    @test vstd(A, dims=(4,5,6)) ≈ vstd(A, dims=(4,5,6), mean=vmean(A, dims=(4,5,6)))


## -- End of File
