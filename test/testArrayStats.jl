## ---  Test equivalence to Base/Stdlib for other summary statistics

    # Test vmean
    for nd = 1:5
        @info "Testing vmean: $nd-dimensional arrays"
        # Generate random array
        A = rand((2 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        @test vmean(A) ≈ mean(A)

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vmean: reduction over dimension $i"
            @test vmean(A, dims=i) ≈ mean(A, dims=i)
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vmean: reduction over dimensions $((j,i))"
                    @test vmean(A, dims=(j,i)) ≈ mean(A, dims=(j,i))
                end
            end
        end

        # Test equivalence when reducing over three dimensions
        if nd > 2
            for i = 3:nd
                for j = 2:i-1
                    for k = 1:j-1
                        @info "Testing vmean: reduction over dimensions $((k,j,i))"
                        @test vmean(A, dims=(k,j,i)) ≈ mean(A, dims=(k,j,i))
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
        @test vvar(A, corrected=false) ≈ var(A, corrected=false);

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vvar: reduction over dimension $i"
            @test vvar(A, dims=i, corrected=false) ≈ var(A, dims=i, corrected=false);
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vvar: reduction over dimensions $((j,i))"
                    @test vvar(A, dims=(j,i), corrected=false) ≈ var(A, dims=(j,i), corrected=false);
                end
            end
        end

        # Test equivalence when reducing over three dimensions
        if nd > 2
            for i = 3:nd
                for j = 2:i-1
                    for k = 1:j-1
                        @info "Testing vvar: reduction over dimensions $((k,j,i))"
                        @test vvar(A, dims=(k,j,i)) ≈ var(A, dims=(k,j,i))
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
        @test vstd(A) ≈ std(A)
        @test vstd(A, corrected=false) ≈ std(A, corrected=false)

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vstd: reduction over dimension $i"
            @test vstd(A, dims=i) ≈ std(A, dims=i)
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
    end

    # Test fallbacks for complex reductions
    A = randn((2 .+ (1:6))...);
    @test vmean(A, dims=(4,5,6)) ≈ mean(A, dims=(4,5,6))
    @test vstd(A, dims=(4,5,6)) ≈ std(A, dims=(4,5,6))
    @test vstd(A, dims=(4,5,6)) ≈ vstd(A, dims=(4,5,6), mean=vmean(A, dims=(4,5,6)))


## -- End of File
