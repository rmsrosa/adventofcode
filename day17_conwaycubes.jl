test_str=".#.
..#
###"

test_list = split(test_str, '\n')

list = readlines("day17_input.txt")

function cycle3d(list, cycles)
    m = length(list)
    width = m+2*cycles+2
    depth = 1+2*cycles+2
    space = fill(false, width, width, depth) # m + 2*cycles (might grow once on both sides at each cycle) + 2 (padding)
    for i in 1:m
        space[1+cycles+i, 2+cycles:m+1+cycles, 2+cycles] = map(==('#'), collect(list[i]))
    end
    previous_space = copy(space)
    for cycle = 1:cycles
#=          for k in 2:depth-1
            for j in 2:width-1
                for i in 2:width-1 =#
          for k in 2+cycles-cycle:2+cycles+cycle
            for j in 2+cycles-cycle:m+1+cycles+cycle
                for i in 2+cycles-cycle:m+1+cycles+cycle
                    active = sum(previous_space[i-1:i+1,j-1:j+1,k-1:k+1])
                    if space[i,j,k] && active ∉ [3,4]
                        space[i,j,k] = false
                    elseif !space[i,j,k] && active == 3
                        space[i,j,k] = true
                    end
                end
            end
        end
        previous_space = deepcopy(space)
    end
    return count(space)
end

@show cycle3d(test_list, 6) == 112
@show cycle3d(list, 6) == 310

function cycle4d(list, cycles)
    m = length(list)
    width = m+2*cycles+2
    depth = 1+2*cycles+2
    space = fill(false, width, width, depth, depth)
    for i in 1:m
        space[1+cycles+i, 2+cycles:m+1+cycles, 2+cycles, 2+cycles] = map(==('#'), collect(list[i]))
    end
    previous_space = copy(space)
    for cycle = 1:cycles
#=         for l in 2:depth-1
            for k in 2:depth-1
                for j in 2:width-1
                    for i in 2:width-1 =#
        for l in 2+cycles-cycle:2+cycles+cycle
            for k in 2+cycles-cycle:2+cycles+cycle
                for j in 2+cycles-cycle:m+1+cycles+cycle
                    for i in 2+cycles-cycle:m+1+cycles+cycle
                        active = sum(previous_space[i-1:i+1,j-1:j+1,k-1:k+1,l-1:l+1])
                        if space[i,j,k,l] && active ∉ [3,4]
                            space[i,j,k,l] = false
                        elseif !space[i,j,k,l] && active == 3
                            space[i,j,k,l] = true
                        end
                    end
                end
            end
        end
        previous_space = deepcopy(space)
    end
    return count(space)
end

@show cycle4d(test_list, 6) == 848
@show cycle4d(list, 6) == 2056

nothing

#= 
```julia
julia> @btime cycle3d(list,6)
  1.858 ms (13496 allocations: 1.50 MiB)

julia> @btime cycle4d(list,6)
  39.148 ms (283334 allocations: 31.09 MiB)
```
 =#

function cycle3d_onepass(list, cycles)
    m = length(list)
    width = m+2*cycles+2
    depth = 3+2*cycles
    space = fill(false, width, width, depth) # m + 2*cycles (might grow once on both sides at each cycle) + 2 (padding)
    for i in 1:m
        space[1+cycles+i, 2+cycles:m+1+cycles, 2+cycles] = map(==('#'), collect(list[i]))
    end
    sumxyz = fill(0, width, width, depth)
    for cycle = 1:cycles
        sumxyz[:,:,2:end-1] = space[:,:,3:end] + space[:,:,2:end-1] + space[:,:,1:end-2]
        sumxyz[:,2:end-1,:] = sumxyz[:,3:end,:] + sumxyz[:,2:end-1,:] + sumxyz[:,1:end-2,:]
        sumxyz[2:end-1,:,:] = sumxyz[3:end,:,:] + sumxyz[2:end-1,:,:] + sumxyz[1:end-2,:,:]
        space = map(x -> (x[1] && x[2] ∉ [3,4]) ? false : (!x[1] && x[2] == 3) ? true : x[1], zip(space, sumxyz))  
    end
    return count(space)
end

function cycle4d_onepass(list, cycles)
    m = length(list)
    width = m+2*cycles+2
    depth = 3+2*cycles
    space = fill(false, width, width, depth, depth)
    for i in 1:m
        space[1+cycles+i, 2+cycles:m+1+cycles, 2+cycles, 2+cycles] = 
            map(==('#'), collect(list[i]))
    end
    sumxyz = fill(0, width, width, depth, depth)
    for cycle = 1:cycles        
        sumxyz[:,:,:,2:end-1] = space[:,:,:,3:end] + space[:,:,:,2:end-1] + space[:,:,:,1:end-2]
        sumxyz[:,:,2:end-1,:] = sumxyz[:,:,3:end,:] + sumxyz[:,:,2:end-1,:] + sumxyz[:,:,1:end-2,:]
        sumxyz[:,2:end-1,:,:] = sumxyz[:,3:end,:,:] + sumxyz[:,2:end-1,:,:] + sumxyz[:,1:end-2,:,:]
        sumxyz[2:end-1,:,:,:] = sumxyz[3:end,:,:,:] + sumxyz[2:end-1,:,:,:] + sumxyz[1:end-2,:,:,:]
        space = map(x -> (x[1] && x[2] ∉ [3,4]) ? false : (!x[1] && x[2] == 3) ? true : x[1], zip(space, sumxyz))
    end
    return count(space)
end

@show cycle3d_onepass(list, 6) == 310
@show cycle4d_onepass(list, 6) == 2056

#= 
#
# It turns out the nested loop is still faster because I only consider the points
# in space next to points which are possibly active. I mean, the range of the loops 
# grows with the number of cycles, so I minimize the number of neighborhood counts.
# In the one-pass code, I end up counting everything. Of course I can modify the 
# code for the range of the sum to grow with the cycles as well, but it is enough
# for the moment.

```julia
julia> @btime cycle3d(list, 6);
  1.802 ms (14266 allocations: 1.57 MiB)

julia> @btime cycle4d(list, 6);
  40.654 ms (288967 allocations: 31.61 MiB)

julia> @btime cycle3d_onepass(list, 6);
  2.482 ms (921 allocations: 3.00 MiB)

julia> @btime cycle4d_onepass(list, 6);
  63.279 ms (5986 allocations: 61.57 MiB)
``` 
=#