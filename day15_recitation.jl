# Advent of Code 2020 - Day 15

function spoken(list, turn)
    spoken_init = parse.(Int,(split(list, ',')))
    spoken_list = fill(0, turn -1)
    for j=1:length(spoken_init)-1
        spoken_list[spoken_init[j]+1] += j
    end
    last_spoken = spoken_init[end]
    for i=length(spoken_init):turn-1
        if spoken_list[last_spoken+1] == 0
            spoken_list[last_spoken+1] = i
            last_spoken = 0            
        else
            difference = i - spoken_list[last_spoken+1]
            spoken_list[last_spoken+1] = i
            last_spoken = difference
        end
    end
    return last_spoken
end

# The next Int32 version reduces allocations by half and time 
function spoken32(list, turn)
    spoken_init = parse.(Int32,(split(list, ',')))
    spoken_list = fill(Int32(0), turn -1)
    for j=1:length(spoken_init)-1
        spoken_list[spoken_init[j]+1] += Int32(j)
    end
    last_spoken = spoken_init[end]
    for i=length(spoken_init):turn-1
        if spoken_list[last_spoken+1] == 0
            spoken_list[last_spoken+1] = Int32(i)
            last_spoken = 0            
        else
            difference = i - spoken_list[last_spoken+1]
            spoken_list[last_spoken+1] = Int32(i)
            last_spoken = difference
        end
    end
    return last_spoken
end

@show spoken("0,3,6", 2020) == 436
@show spoken("1,3,2", 2020) == 1
@show spoken("2,1,3", 2020) == 10
@show spoken("1,2,3", 2020) == 27
@show spoken("2,3,1", 2020) == 78
@show spoken("3,2,1", 2020) == 438
@show spoken("3,1,2", 2020) == 1836
@show spoken("10,16,6,0,1,17", 2020) == 412

@show spoken("0,3,6", 30000000) == 175594
@show spoken("1,3,2", 30000000) == 2578
@show spoken("2,1,3", 30000000) == 3544142
@show spoken("1,2,3", 30000000) == 261214
@show spoken("2,3,1", 30000000) == 6895259
@show spoken("3,2,1", 30000000) == 18
@show spoken("3,1,2", 30000000) == 362
@show spoken("10,16,6,0,1,17", 30000000) == 243
@show spoken32("10,16,6,0,1,17", 30000000) == 243

#= 
```julia
julia> @btime spoken("10,16,6,0,1,17", 30000000)
  1.568 s (6 allocations: 228.88 MiB)
243

julia> @btime spoken32("10,16,6,0,1,17", 30000000)
  1.328 s (6 allocations: 114.44 MiB)
243
```
 =#