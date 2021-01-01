list_test_str = "light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags."

list_test = split(list_test_str, '\n')

list = readlines("day7_input.txt")

bag = "shiny gold"

#regxrule = r"( bags contain | bag\, | bags\, | bag\.| bags\.)"

regxrule = r"( bags contain | bags?, | bags?.)"

regxrule = r" bags contain | bags?[,.] ?"

regxrule = r" bags contain | bags?(, |\.)"

function get_outer_bag_rules(list)
    outer = Dict()
    for line in list
        parts = split(line, regxrule, keepempty=false)
            for part in parts[2:end]
                if part ≠ "no other"
                    num, bag = split(part, ' ', limit=2)
                    if bag in keys(outer)
                        push!(outer[bag], parts[1])
                    else
                        push!(outer, bag => Set([parts[1]]))
                    end
                end
            end
    end
    return outer
end

function get_outer_bags(bag, outer_bag_rules, outer_set = Set())
    if bag in keys(outer_bag_rules)
        outermost_bags = outer_bag_rules[bag]
        if outermost_bags ∉ outer_set
            union!(outer_set,outermost_bags)
            for outer_bag ∈ outermost_bags
                union!(outer_set, get_outer_bags(outer_bag, outer_bag_rules, outer_set))
            end
        end
    end
    return outer_set
end

get_number_outer_bags(bag, list) = length(get_outer_bags(bag, get_outer_bag_rules(list)))

println("Number of outer bags containing `$bag` bag in test list is $(get_number_outer_bags(bag, list_test))\n")
println("Number of outer bags containing `$bag` bag in problem list is $(get_number_outer_bags(bag, list))\n")

#= 
```julia
julia> @btime get_number_outer_bags("shiny gold", list)
  5.744 ms (99019 allocations: 3.22 MiB)
185

julia> @btime get_outer_bag_rules(list);
  1.970 ms (17606 allocations: 1.25 MiB)

julia> outer_bag_rules = get_outer_bag_rules(list);

julia> @btime length(get_outer_bags(bag, outer_bag_rules));
  3.742 ms (81414 allocations: 1.97 MiB)
```
=#

# Outra versão com mais regex, mas só um pouco mais rápida.

# A versão regex_web foi testada em https://regexr.com/5hutn
regexrule_web = r"(.+)(?: bags contain )((\d+) ([^,\n]*) (bag,|bags,) )?((\d+) ([^,\n]*) (bag,|bags,) )?((\d+) ([^,\n]*) (bag,|bags,) )?((\d+) ([^,\n]*) (bag,|bags,))?((\d+|no) ([^,\n]*) ((bag\.|bags\.)))\n?"
regexrule = r"(.+)(?: bags contain )((\d+) ([^,]*) (bag,|bags,) )?((\d+) ([^,]*) (bag,|bags,) )?((\d+) ([^,]*) (bag,|bags,) )?((\d+) ([^,]*) (bag,|bags,))?((\d+|no) ([^,]*) ((bag\.|bags\.)))"
#regexrule = r"(.+)(?: bags contain )((\d+) ([^,]*) (bag,|bags,) )?{4}((\d+|no) ([^,]*) ((bag\.|bags\.)))"

function get_outer_bag_rules2(list)
    outer = Dict()
    for line in list
        m = match(regexrule, line)
            for j in 3:4:length(m.captures)
                if m[j] ∉ ("", "no") && !(m[j+1] === nothing)
                    num = m[j]
                    bag = m[j+1]
                    if bag in keys(outer)
                        push!(outer[bag], m[1])
                    else
                        push!(outer, bag => Set([m[1]]))
                    end
                end
            end
    end
    return outer
end


# part 2

list_test2_str = "shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags."

list_test2 = split(list_test2_str, '\n')

function get_inner_bag_rules(list)
    inner = Dict()
    for line in list
        parts = split(line, regxrule, keepempty=false)
            for part in parts[2:end]
                if part ≠ "no other"
                    num, bag = split(part, ' ', limit=2)
                    if parts[1] in keys(inner)
                        push!(inner[parts[1]], (bag, parse(Int, num)))
                    else
                        push!(inner, parts[1] => [(bag, parse(Int, num))])
                    end
                end
            end
    end
    return inner
end

function get_next_inner_bags(bag, inner_bag_rules)
    if bag in keys(inner_bag_rules)
        innermost_stuff = inner_bag_rules[bag]
        inner_sum = 1 # start with containing bag
        for (innermost_bag, innermost_num) in innermost_stuff
            # recursively count inner bags
            inner_sum += innermost_num * get_next_inner_bags(innermost_bag, inner_bag_rules)
        end
        return inner_sum
    else
        return 1
    end
end

get_number_inner_bags(bag, list) = get_next_inner_bags(bag, get_inner_bag_rules(list)) - 1 # discount starting bag

println("Number of bags contained in `$bag` bag in test list is $(get_number_inner_bags(bag, list_test))\n")
println("Number of bags contained in `$bag` bag in second test list is $(get_number_inner_bags(bag, list_test2))\n")
println("Number of bags contained in `$bag` bag in problem list is $(get_number_inner_bags(bag, list))\n")

#= 
# In this case, most of the time is taken extracting the rules.
# We don't need to keep growing with the set of color bags, just the number
```julia
julia> @btime get_number_inner_bags("shiny gold", list)
  1.970 ms (17252 allocations: 1.10 MiB)
89084

julia> inner_bag_rules = get_inner_bag_rules(list);

julia> @btime get_inner_bag_rules(list);
  1.906 ms (16404 allocations: 1.07 MiB)

julia> @btime get_next_inner_bags(bag, inner_bag_rules) - 1;
  61.513 μs (848 allocations: 33.66 KiB)

```
=#
