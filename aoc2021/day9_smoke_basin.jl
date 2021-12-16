list_test_str = split(
"2199943210
3987894921
9856789892
8767896789
9899965678",
'\n'
)

list_str = let input = @__DIR__() * "/day9_input.txt"
    isfile(input) ? readlines(input) : list_test_str
end

# Test function

function testit(name, result, check::Function)
    if check(result)
        @info "$name successful, with result $result"
    else
        @warn "$name failed, with result $result"
    end
end

# Part 1

function part1(list)
    m = fill(9, length(list)+2, length(list[1])+2)
    m[2:end-1, 2:end-1] .= parse.(Int, permutedims(reduce(hcat, collect.(list))))
    res = 0
    h, w = size(m)
    for i in 2:h-1
        for j in 2:w-1
            if all(p -> m[i, j] < m[i+first(p), j+last(p)], ((1, 0), (-1, 0), (0, 1),  (0, -1)))
                res += 1 + m[i, j]
            end
        end
    end
    return res
end

testit("Test Part 1", part1(list_test_str), ==(15))
testit("Challenge Part 1", part1(list_str), ==(591))

# Part 2

function part2(list)
    function poke!(c, i, j, id)
        if c[i, j] == 0
            c[i, j] = id
            for (u,v) in ((1, 0), (-1, 0), (0, 1), (0, -1))
                poke!(c, i+u, j+v, id)
            end
        end
    end
    c = fill(-1, length(list)+2, length(list[1])+2)
    c[2:end-1, 2:end-1] .= -(parse.(Int, permutedims(reduce(hcat, collect.(list)))) .== 9)
    h, w = size(c)
    id = 0
    for i in 2:h-1
        for j in 2:w-1
            if c[i, j] == 0
                id += 1
                poke!(c, i, j, id)
            end
        end
    end
    return prod(sort([count(c .== j) for j in 1:maximum(c)], rev=true)[1:3])
end

testit("Test Part 2", part2(list_test_str), ==(1134))
testit("Challenge Part 2", part2(list_str), ==(1113424))
