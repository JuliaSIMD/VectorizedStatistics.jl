@precompile_setup begin
    maxdims = 3

    @precompile_all_calls begin

        for T in (Float64,)
            for nd in 1:maxdims
                A = ones(T, ntuple(i->10, nd))
                vsum(A)
                vmean(A)
                vstd(A)
                vvar(A)
                vminimum(A)
                vmaximum(A)

                if nd > 1
                    for d in 1:nd
                        vsum(A, dims=d)
                        vmean(A, dims=d)
                        vstd(A, dims=d)
                        vvar(A, dims=d)
                        vminimum(A, dims=d)
                        vmaximum(A, dims=d)
                    end

                    for i = 2:nd
                        for j = 1:i-1
                            vsum(A, dims=(j,i))
                            vmean(A, dims=(j,i))
                            vstd(A, dims=(j,i))
                            vvar(A, dims=(j,i))
                            vminimum(A, dims=(j,i))
                            vmaximum(A, dims=(j,i))
                        end
                    end
                end

            end
        end

        for T in (Int,)
            for nd in 1:maxdims
                A = ones(T, ntuple(i->10, nd))
                vsum(A)
                vmean(A)
                vstd(A)
                vvar(A)
                vminimum(A)
                vmaximum(A)
            end
        end
    end
end
