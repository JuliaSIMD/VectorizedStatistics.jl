## --- Test equivalence to Base/Stdlib for `vreduce`-ables

    # Test vminimum
    for nd = 1:5
        @info "Testing vminimum: $nd-dimensional arrays"
        # Generate random array
        A = rand((10 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        @test vminimum(A) ≈ minimum(A)

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vminimum: reduction over dimension $i"
            @test vminimum(A, dims=i) ≈ minimum(A, dims=i)
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vminimum: reduction over dimensions $((j,i))"
                    @test vminimum(A, dims=(j,i)) ≈ minimum(A, dims=(j,i))
                end
            end
        end
    end

    # Test vmaximum
    for nd = 1:5
        @info "Testing vmaximum: $nd-dimensional arrays"
        # Generate random array
        A = rand((10 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        @test vmaximum(A) ≈ maximum(A)

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vmaximum: reduction over dimension $i"
            @test vmaximum(A, dims=i) ≈ maximum(A, dims=i)
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vmaximum: reduction over dimensions $((j,i))"
                    @test vmaximum(A, dims=(j,i)) ≈ maximum(A, dims=(j,i))
                end
            end
        end
    end

    # Test vsum
    for nd = 1:5
        @info "Testing vsum: $nd-dimensional arrays"
        # Generate random array
        A = rand((10 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        @test vsum(A) ≈ sum(A)

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vsum: reduction over dimension $i"
            @test vsum(A, dims=i) ≈ sum(A, dims=i)
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vsum: reduction over dimensions $((j,i))"
                    @test vsum(A, dims=(j,i)) ≈ sum(A, dims=(j,i))
                end
            end
        end
    end

## -- End of File
