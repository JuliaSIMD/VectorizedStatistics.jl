## ---  Test equivalence to Base/Stdlib for other summary statistics

    # Test vsum
    for nd = 1:5
        @info "Testing vsum: $nd-dimensional arrays"
        # Generate random array
        A = rand((1 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        Σ = sum(A)
        @test vsum(A, multithreaded=false) ≈ Σ
        @test vsum(A, multithreaded=true) ≈ Σ

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vsum: reduction over dimension $i"
            Σ = sum(A, dims=i)
            @test vsum(A, dims=i, multithreaded=false) ≈ Σ
            @test vsum(A, dims=i, multithreaded=true) ≈ Σ
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vsum: reduction over dimensions $((j,i))"
                    Σ = sum(A, dims=(j,i))
                    @test vsum(A, dims=(j,i), multithreaded=false) ≈ Σ
                    @test vsum(A, dims=(j,i), multithreaded=true) ≈ Σ
                end
            end
        end

        # Test equivalence when reducing over three dimensions
        if nd > 2
            for i = 3:nd
                for j = 2:i-1
                    for k = 1:j-1
                        @info "Testing vsum: reduction over dimensions $((k,j,i))"
                        Σ = sum(A, dims=(k,j,i))
                        @test vsum(A, dims=(k,j,i), multithreaded=false) ≈ Σ
                        @test vsum(A, dims=(k,j,i), multithreaded=true) ≈ Σ
                    end
                end
            end
        end
    end


    # Test vmean
    for nd = 1:5
        @info "Testing vmean: $nd-dimensional arrays"
        # Generate random array
        A = rand((2 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        μ = mean(A)
        @test vmean(A, multithreaded=false) ≈ μ
        @test vmean(A, multithreaded=true) ≈ μ

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vmean: reduction over dimension $i"
            μ = mean(A, dims=i)
            @test vmean(A, dims=i, multithreaded=false) ≈ μ
            @test vmean(A, dims=i, multithreaded=true) ≈ μ
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vmean: reduction over dimensions $((j,i))"
                    μ = mean(A, dims=(j,i))
                    @test vmean(A, dims=(j,i), multithreaded=false) ≈ μ
                    @test vmean(A, dims=(j,i), multithreaded=true) ≈ μ
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
                        @test vmean(A, dims=(k,j,i), multithreaded=false) ≈ μ
                        @test vmean(A, dims=(k,j,i), multithreaded=true) ≈ μ
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
                            @test vmean(A, dims=(l,k,j,i), multithreaded=false) ≈ μ
                            @test vmean(A, dims=(l,k,j,i), multithreaded=true) ≈ μ
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
        @test vvar(A, corrected=false, multithreaded=false) ≈ σ²
        @test vvar(A, corrected=false, multithreaded=true) ≈ σ²

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vvar: reduction over dimension $i"
            σ² = var(A, dims=i, corrected=false)
            @test vvar(A, dims=i, corrected=false, multithreaded=false) ≈ σ²
            @test vvar(A, dims=i, corrected=false, multithreaded=true) ≈ σ²
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vvar: reduction over dimensions $((j,i))"
                    σ² = var(A, dims=(j,i), corrected=false)
                    @test vvar(A, dims=(j,i), corrected=false, multithreaded=false) ≈ σ²
                    @test vvar(A, dims=(j,i), corrected=false, multithreaded=true) ≈ σ²
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
                        @test vvar(A, dims=(k,j,i), multithreaded=false) ≈ σ²
                        @test vvar(A, dims=(k,j,i), multithreaded=true) ≈ σ²
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
        @test vstd(A, multithreaded=true) ≈ vstd(A, multithreaded=false) ≈ std(A)
        @test vstd(A, corrected=false, multithreaded=true) ≈ vstd(A, corrected=false, multithreaded=false) ≈ std(A, corrected=false)

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vstd: reduction over dimension $i"
            @test vstd(A, dims=i, multithreaded=true) ≈ vstd(A, dims=i, multithreaded=false) ≈ std(A, dims=i)
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
