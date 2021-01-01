# Toboggan Trajectory

test_terrain_str = "..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#"

test_terrain = split(test_terrain_str, '\n')

terrain = readlines("day3_input.txt")

function count_trees(terrain, right, down)
    col = 1
    trees = 0
    len = length(terrain[1])
    for line in terrain[1:down:end]
        if line[col] == '#'
            trees += 1
        end
        col += right
        if col > len
            col = col % len
        end
    end
    return trees
end

println("Found $(count_trees(test_terrain, 3, 1)) trees in the test example")

println("Found $(count_trees(terrain, 3, 1)) trees in the first test")

println()

function count_second_test(terrain)
    mult = 1
    for (right, down) in [(1,1), (3, 1), (5, 1), (7, 1), (1, 2)]
        count = count_trees(terrain, right, down)
        mult *= count
        println("Found $count trees in the test with right = $right and down = $down")
    end
    println()
    println("Multiplying all trees gives us $mult")
end

count_second_test(terrain)

function count_second_test_noprint(terrain)
    mult = 1
    for (right, down) in [(1,1), (3, 1), (5, 1), (7, 1), (1, 2)]
        count = count_trees(terrain, right, down)
        mult *= count
    end
    return mult
end

#= 
# I got
```julia
julia> @btime count_second_test_noprint(terrain)
  10.658 μs (7 allocations: 12.38 KiB)
1744787392
```
and no gain in using a single-liner:
```julia
julia> @btime prod([count_trees(terrain, right, down)
                   for (right, down) 
                       in ((1,1), (3, 1), (5, 1), (7, 1), (1, 2))])
  10.859 μs (6 allocations: 12.33 KiB)
```
 =#

function count_trees_2(terrain, right, down)
    col = 1
    trees = 0
    len = length(terrain[1])
    for l in 1:down:length(terrain)
        if terrain[l][col] == '#'
            trees += 1
        end
# no gain in speed if we do instead (same time)
#        test = terrain[l][col] == '#' ? trees += 1 : nothing
        col += right
        if col > len
            col = col % len
        end
    end
    return trees
end

function count_second_test_noprint_2(terrain)
    mult = 1
    for (right, down) in [(1,1), (3, 1), (5, 1), (7, 1), (1, 2)]
        count = count_trees_2(terrain, right, down)
        mult *= count
    end
    return mult
end

# Great improvement (half the time) if we index the line
# instead of loop over the lines themselves, surprisingly
#= ```julia
julia> @btime count_second_test_noprint_2(terrain)
  4.534 μs (2 allocations: 176 bytes)
1744787392
```
=#

# Wait! Using iterator is way faster, but it doesn't influence 
# much since is it an outside small loop, but in other situations
# it might make a bit difference

function count_second_test_noprint_2b(terrain)
    mult = 1
    for (right, down) in ((1,1), (3, 1), (5, 1), (7, 1), (1, 2))
        count = count_trees_2(terrain, right, down)
        mult *= count
    end
    return mult
end
# We get 
#= 
```julia
julia> @btime count_second_test_noprint_2(terrain)
  4.528 μs (2 allocations: 176 bytes)
1744787392

julia> @btime count_second_test_noprint_2b(terrain)
  4.465 μs (1 allocation: 16 bytes)
1744787392
```
 =#

###

function count_trees_4(terrain, right, down)
    trees = 0
    len = length(terrain[1])
    for l in 1:down:length(terrain)
        if terrain[l][(div(right*(l-1),down))%length(terrain[1])+1] == '#'
            trees += 1
        end
    end
    return trees
end

function count_second_test_noprint_4(terrain)
    mult = 1
    for (right, down) in [(1,1), (3, 1), (5, 1), (7, 1), (1, 2)]
        mult *= count_trees_4(terrain, right, down)
    end
    return mult
end

# method 4 was way worse:
#= ```julia
julia> @btime count_second_test_noprint_4(terrain)
  51.145 μs (2 allocations: 176 bytes)
1744787392
```
 =#

# I tried with list comprehension but this was not good, probably
# because it had to store too much info and only then compute the result:
# Still, it is interesting to compare the following two codes,
# with the first one needing many more allocations and memory

function count_second_test_listcomprehension_1(terrain)
    mult = 1
    for (right, down) in [(1,1), (3, 1), (5, 1), (7, 1), (1, 2)]
        count = length([c for c in [terrain[l][(div(right*(l-1),down))%length(terrain[1])+1] for l in 1:down:length(terrain)] if c == '#'])
    mult *= count
    end
    return mult
end

function count_second_test_listcomprehension_4(terrain)
    mult = 1
    for (right, down) in [(1,1), (3, 1), (5, 1), (7, 1), (1, 2)]
    mult *= count(c -> c == '#', [terrain[l][(div(right*(l-1),down))%length(terrain[1])+1] for l in 1:down:length(terrain)])
    end
    return mult
end
#=
```julia
julia> @btime count_second_test_listcomprehension_1(terrain)
  65.648 μs (45 allocations: 13.95 KiB)
1744787392

julia> @btime count_second_test_listcomprehension_4(terrain)
  58.912 μs (7 allocations: 6.70 KiB)
1744787392
```
=#

#

function count_trees_5(terrain, right, down)
    trees = 0
    len = length(terrain[1])
    for (l,c) in zip(1:down:length(terrain), 0:right:div(length(terrain)*right, down)-1)
        if terrain[l][c%len+1] == '#'
            trees += 1
        end
    end
    return trees
end

function count_second_test_noprint_5(terrain)
    mult = 1
    for (right, down) in ((1,1), (3, 1), (5, 1), (7, 1), (1, 2))
        mult *= count_trees_5(terrain, right, down)
    end
    return mult
end
# Not bad, but 2 and 2b are still the best
#= 
```julia
julia> @btime count_second_test_noprint_5(terrain)
  7.964 μs (1 allocation: 16 bytes)
1744787392
```
 =#

# Now with a one-liner based on the above
count_second_test_noprint_5b(terrain) = prod( sum(1 for (l,c) in zip(1:down:length(terrain), 0:right:div(length(terrain)*right, down)-1) if terrain[l][c%length(terrain[1])+1] == '#') for (right, down) in ((1,1), (3, 1), (5, 1), (7, 1), (1, 2)))
#= 
```julia
julia> @btime prod( sum(1 for (l,c) in zip(1:down:length(terrain), 0:right:div(length(terrain)*right, down)-1) if terrain[l][c%length(terrain[1])+1] == '#') for (right, down) in ((1,1), (3, 1), (5, 1), (7, 1), (1, 2)))
  276.830 μs (677 allocations: 11.83 KiB)
1744787392
``` =#

# Using iterator is twice faster but computing cls and mod is not that bad:
#=
```julia
julia> @btime [r * d for (r,d) in [(1,1), (3, 1), (5, 1), (7, 1), (1, 2)]];
  99.231 ns (2 allocations: 288 bytes)

julia> @btime [r * d for (r,d) in ((1,1), (3, 1), (5, 1), (7, 1), (1, 2))];
  52.459 ns (1 allocation: 128 bytes)

julia> @btime [mod(2i-1,8) * cld(i,4) for i in 1:5];
  62.881 ns (1 allocation: 128 bytes)
```
=#