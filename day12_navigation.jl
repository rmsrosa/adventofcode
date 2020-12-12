test_str = "F10
N3
F7
R90
F11"

test_list = split(test_str, '\n')

list = readlines("day12_input.txt")

function navigate(list)
    instructions = map(x -> (x[1], parse(Int, x[2:end])), list)
    direction_table = Dict('N' => (0,1), 'S' => (0,-1), 'E' => (1,0), 'W' => (-1,0))
    rotate_right = Dict('N' => 'E', 'E' => 'S', 'S' => 'W', 'W' => 'N')
    rotate_left = Dict('N' => 'W', 'W' => 'S', 'S' => 'E', 'E' => 'N')
    heading = 'E'
    pos = (0,0) # (W-E, S-N) with negative values being W or S and positive, E and N
    for (i,v) in instructions
        if i in "NESW"
            pos = pos .+ (v .* direction_table[i])
        elseif i == 'F'
            pos = pos .+ (v .* direction_table[heading])
        elseif i == 'R'
            for j in 1:div(v, 90)
                heading = rotate_right[heading]
            end
        elseif i == 'L'
            for j in 1:div(v, 90)
                heading = rotate_left[heading]
            end
        end
    end
    return sum(abs.(pos))
end

@show navigate(test_list)
@show navigate(list)
@show navigate(test_list) == 25
@show navigate(list) == 2270


function navigate_waypoint(list)
    instructions = map(x -> (x[1], parse(Int, x[2:end])), list)
    direction_table = Dict('N' => (0,1), 'S' => (0,-1), 'E' => (1,0), 'W' => (-1,0))   
    waypoint = (10,1)
    pos = (0,0) # (W-E, S-N) with negative values being W or S and positive, E and N
    for (i,v) in instructions
        if i in "NESW"
            waypoint = waypoint .+ (v .* direction_table[i])
        elseif i == 'F'
            pos = pos .+ (v .* waypoint)
        elseif i == 'R'
            for j in 1:div(v, 90)
                waypoint = (waypoint[2], -waypoint[1])
            end
        elseif i == 'L'
            for j in 1:div(v, 90)
                waypoint = (-waypoint[2], waypoint[1])
            end
        end
    end
    return sum(abs.(pos))
end

@show navigate_waypoint(test_list)
@show navigate_waypoint(list)
@show navigate_waypoint(test_list) == 286
@show navigate_waypoint(list) == 138669

nothing

# Counting ocurrences:
#= 
```julia
ulia> count(in("NSEW"), join([i for (i,v) in instructions]))
408

julia> count(==("F"), join([i for (i,v) in instructions]))
0

julia> count(==('F'), join([i for (i,v) in instructions]))
206

julia> count(==('R'), join([i for (i,v) in instructions]))
99
```
 =#
#= 
# Timings
```julia
 julia> @btime navigate(test_list)
  1.672 μs (13 allocations: 1.75 KiB)
25

julia> @btime navigate(list)
  126.258 μs (809 allocations: 39.02 KiB)
2270

julia> @btime navigate_waypoint(test_list)
  1.176 μs (5 allocations: 832 bytes)
286

julia> @btime navigate_waypoint(list)
  122.945 μs (801 allocations: 38.08 KiB)
138669
```
=#