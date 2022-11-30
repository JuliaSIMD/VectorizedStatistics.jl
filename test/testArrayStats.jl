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
            @test vec(vsum(A, dim=i)) ≈ vec(Σ)
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vsum: reduction over dimensions $((j,i))"
                    Σ = sum(A, dims=(j,i))
                    @test vsum(A, dims=(j,i), multithreaded=false) ≈ Σ
                    @test vsum(A, dims=(j,i), multithreaded=true) ≈ Σ
                    @test vec(vsum(A, dim=(j,i))) ≈ vec(Σ)
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
            @test vec(vvar(A, dim=i, corrected=false)) ≈ vec(σ²)
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vvar: reduction over dimensions $((j,i))"
                    σ² = var(A, dims=(j,i), corrected=false)
                    @test vvar(A, dims=(j,i), corrected=false, multithreaded=false) ≈ σ²
                    @test vvar(A, dims=(j,i), corrected=false, multithreaded=true) ≈ σ²
                    @test vec(vvar(A, dim=(j,i), corrected=false)) ≈ vec(σ²)
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
            σ = std(A, dims=i)
            @test vstd(A, dims=i, multithreaded=true) ≈ σ
            @test vstd(A, dims=i, multithreaded=false) ≈ σ
            @test vec(vstd(A, dim=i)) ≈ vec(σ)
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vstd: reduction over dimensions $((j,i))"
                    σ = std(A, dims=(j,i))
                    @test vstd(A, dims=(j,i)) ≈ σ
                    @test vec(vstd(A, dim=(j,i))) ≈ vec(σ)
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

    # Test results when diminsions are out of range
    A = rand(10,10)
    @test vminimum(A, dims=3) == A
    @test vminimum(A, dims=(1,3)) == minimum(A, dims=(1,3))
    @test vsum(A, dims=3, multithreaded=false) == vmean(A, dims=(3,4), multithreaded=false) == A
    @test vsum(A, dims=3, multithreaded=true) == vmean(A, dims=(3,4), multithreaded=true) == A
    @test vmean(A, dims=3, multithreaded=false) == vmean(A, dims=(3,4), multithreaded=false) == A
    @test vmean(A, dims=3, multithreaded=true) == vmean(A, dims=(3,4), multithreaded=true) == A
    @test isequal(vstd(A, dims=(3,4), multithreaded=false), fill(NaN, 10, 10))
    @test isequal(vstd(A, dims=(3,4), multithreaded=true), fill(NaN, 10, 10))
    @test vstd(A, dims=(1,3)) == vstd(A, dims=1)


## -- End of File
