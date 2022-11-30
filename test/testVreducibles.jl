## --- Test equivalence to Base/Stdlib for `vreduce`-ables

    # Test vminimum
    for nd = 1:5
        @info "Testing vminimum: $nd-dimensional arrays"
        # Generate random array
        A = rand((1 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        @test vminimum(A) ≈ minimum(A)

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vminimum: reduction over dimension $i"
            @test vminimum(A, dims=i) ≈ minimum(A, dims=i)
            @test vec(vminimum(A, dim=i)) ≈ vec(minimum(A, dims=i))
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vminimum: reduction over dimensions $((j,i))"
                    @test vminimum(A, dims=(j,i)) ≈ minimum(A, dims=(j,i))
                    @test vec(vminimum(A, dim=(j,i))) ≈ vec(minimum(A, dims=(j,i)))
                end
            end
        end

        # Test equivalence when reducing over three dimensions
        if nd > 2
            for i = 3:nd
                for j = 2:i-1
                    for k = 1:j-1
                        @info "Testing vminimum: reduction over dimensions $((k,j,i))"
                        @test vminimum(A, dims=(k,j,i)) ≈ minimum(A, dims=(k,j,i))
                    end
                end
            end
        end
    end

    # Test vmaximum
    for nd = 1:5
        @info "Testing vmaximum: $nd-dimensional arrays"
        # Generate random array
        A = rand((1 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        @test vmaximum(A) ≈ maximum(A)

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vmaximum: reduction over dimension $i"
            @test vmaximum(A, dims=i) ≈ maximum(A, dims=i)
            @test vec(vmaximum(A, dim=i)) ≈ vec(maximum(A, dims=i))
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vmaximum: reduction over dimensions $((j,i))"
                    @test vmaximum(A, dims=(j,i)) ≈ maximum(A, dims=(j,i))
                    @test vec(vmaximum(A, dim=(j,i))) ≈ vec(maximum(A, dims=(j,i)))
                end
            end
        end

        # Test equivalence when reducing over three dimensions
        if nd > 2
            for i = 3:nd
                for j = 2:i-1
                    for k = 1:j-1
                        @info "Testing vmaximum: reduction over dimensions $((k,j,i))"
                        @test vmaximum(A, dims=(k,j,i)) ≈ maximum(A, dims=(k,j,i))
                    end
                end
            end
        end
    end

    # Test vextrema
    for nd = 1:3
        @info "Testing vextrema: $nd-dimensional arrays"
        # Generate random array
        A = rand((1 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        @test vextrema(A) == extrema(A)

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            @info "Testing vextrema: reduction over dimension $i"
            @test vextrema(A, dims=i) == extrema(A, dims=i)
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    @info "Testing vextrema: reduction over dimensions $((j,i))"
                    @test vextrema(A, dims=(j,i)) == extrema(A, dims=(j,i))
                end
            end
        end

        # Test equivalence when reducing over three dimensions
        if nd > 2
            for i = 3:nd
                for j = 2:i-1
                    for k = 1:j-1
                        @info "Testing vextrema: reduction over dimensions $((k,j,i))"
                        @test vextrema(A, dims=(k,j,i)) == extrema(A, dims=(k,j,i))
                    end
                end
            end
        end
    end



## -- End of File
