test_string ="abc

a
b
c

ab
ac

a
a
a
a

b"

test_list = split(test_string,'\n')

list = readlines("day6_input.txt")

function get_union(list)
    groups = ""
    total = 0
    for n in 1:length(list)
        if list[n] == ""
            groups *= ","
        else
            groups *= list[n]
        end
    end
    return groups
end

function get_union_total_from_groups(list)
    return sum(length.(Set.(split(get_union(list), ','))))
end

function get_union_and_total(list)
    groups = Set()
    group = ""
    total = 0
    for n in 1:length(list)
        if list[n] == ""
            push!(groups, group)
            total += length(group)
            group = ""
        else
            group = union(group, list[n])
        end
    end
    push!(groups, group)
    total += length(group)
    return groups, total
end

function get_union_total(list)
    group = ""
    total = 0
    for n in 1:length(list)
        if list[n] == ""
            total += length(group)
            group = ""
        else
            group = union(group, list[n])
        end
    end
    total += length(group)
    return total
end

get_union_total_oneliner(list) = sum(length.(Set.(split(join(map(
        x -> x == "" ? "," : x, list)), ','
    ))))

get_intersection_total_oneliner(list) = sum(length.(Set.(split(join(map(
        x -> x == "" ? "," : x, list)), ','
    ))))

# No gain in making a map to broadcast directly to the composition 
# of length and Set. I thought that would avoid one more loop through
# the list, but it either doesn't avoid or it does, but makes no difference
# somehow

get_union_total_oneliner2(list) = sum((length∘Set).(split(join(map(
    x -> x == "" ? "," : x, list)),',')))

@show get_union_total_from_groups(test_list)

@show get_union_total_from_groups(list)

@show get_union_total(list)

#= 
```julia
julia> @btime get_union_total_from_groups(list)
  3.438 ms (8115 allocations: 18.38 MiB)
6809

julia> @btime get_union_total(list)
  1.860 ms (18572 allocations: 1.64 MiB)
6809

julia> @btime get_union_total_oneliner(list)
  660.330 μs (4136 allocations: 431.29 KiB)
6809

julia> @btime get_union_total_oneliner2(list)
  757.013 μs (5137 allocations: 454.79 KiB)
6809
```
 =#
function get_intersection_and_total(list)
    nmax = length(list)
    groups = Set()
    abc = "abcdefghijklmnopqrstuvwxyz"
    group = abc
    total = 0
    for n in 1:nmax
        if list[n] == ""
            push!(groups, group)
            total += length(group)
            group = abc
        else
            group = intersect(group, list[n])
        end
    end
    push!(groups, group)
    total += length(group)
    return groups, total
end

function get_intersection_total(list)
    nmax = length(list)
    abc = "abcdefghijklmnopqrstuvwxyz"
    group = abc
    total = 0
    for n in 1:nmax
        if list[n] == ""
            total += length(group)
            group = abc
        else
            group = intersect(group, list[n])
        end
    end
    total += length(group)
    return total
end

@show get_intersection_total(list)

#= 
```julia
julia> @btime get_intersection_total(list)
  4.145 ms (29922 allocations: 2.80 MiB)
3394
```
 =#

function get_totals(list)
    nmax = length(list)
    abc = "abcdefghijklmnopqrstuvwxyz"
    group_union = ""
    total_union = 0
    group_intersection = abc
    total_intersection = 0
    for n in 1:nmax
        if list[n] == ""
            total_union += length(group_union)
            total_intersection += length(group_intersection)
            group_union = ""
            group_intersection = abc
        else
            group_union = union(group_union, list[n])
            group_intersection = intersect(group_intersection, list[n])
        end
    end
    total_union += length(group_union)
    total_intersection += length(group_intersection)
    return total_union, total_intersection
end

# No gain in time doing both at once:
#= 
```julia
julia> @btime get_union_total(list)
  1.860 ms (18572 allocations: 1.64 MiB)
6809

julia> @btime get_intersection_total(list)
  4.145 ms (29922 allocations: 2.80 MiB)
3394

julia> @btime get_totals(list)
  6.185 ms (48493 allocations: 4.44 MiB)
(6809, 3394)
``` =#
