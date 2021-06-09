# Test equivalence to Base/Stdlib for `vreduce`-ables

vreducibles = zip((:minimum, :maximum, :sum), (:vminimum, :vmaximum, :vsum))
for nd = 1:5
    # Generate random array
    let A = rand((10 .+ (1:nd))...)

        # Test equivlalence when reducing over all dims
        for (fn, vfn) in vreducibles
            @info "Testing $vfn: $nd-dimensional arrays"
            eval(:(@test $vfn($A) ≈ $fn($A);))
        end

        # Test equivalence when reducing over a single dimension
        for i = 1:nd
            for (fn, vfn) in vreducibles
                @info "Testing $vfn: reduction over dimension $i"
                eval(:(@test $vfn($A, dims=$i) ≈ $fn($A, dims=$i);))
            end
        end

        # Test equivalence when reducing over two dimensions
        if nd > 1
            for i = 2:nd
                for j = 1:i-1
                    dims = (j,i)
                    for (fn, vfn) in vreducibles
                        @info "Testing $vfn: reduction over dimensions $dims"
                        eval(:(@test $vfn($A, dims=$dims) ≈ $fn($A, dims=$dims);))
                    end
                end
            end
        end
    end
end
