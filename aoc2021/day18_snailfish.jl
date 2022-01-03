list_test_str = split(
"[1,2]
[[1,2],3]
[9,[8,7]]
[[1,9],[8,5]]
[[[[1,2],[3,4]],[[5,6],[7,8]]],9]
[[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]
[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]",
'\n'
)

list_str = let input = @__DIR__() * "/day18_input.txt"
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

function encode(s::Int, l)
    return [[l, s]]
end

function encode(s::Vector, l)
    return reduce(vcat, encode.(s, l+1))
end

function reduce_code(code)
    reduced = deepcopy(code)
    while any(>(4), getindex.(reduced, 1)) || any(≥(10), getindex.(reduced, 2))
        if any(>(4), getindex.(reduced, 1))
            n = findfirst(getindex.(reduced, 1) .> 4)
            level, data = reduced[n]
            if n == 1
                reduced[n] = [level-1, 0]
                reduced[n+2][2] = last(reduced[n+2]) + last(reduced[n+1])
                deleteat!(reduced, n+1)
            elseif n == length(reduced) - 1
                reduced[n-1][2] = last(reduced[n-1]) + data
                reduced[n] = [level-1, 0]
                deleteat!(reduced, n+1)
            else
                reduced[n-1][2] = last(reduced[n-1]) + data
                reduced[n] = [level-1, 0]
                reduced[n+2][2] = last(reduced[n+2]) + last(reduced[n+1])
                deleteat!(reduced, n+1)
            end
        else
            n = findfirst(getindex.(reduced, 2) .≥ 10)
            level, data = reduced[n]
            reduced[n] = [level+1, div(data, 2)]
            insert!(reduced, n+1, [level+1, div(data+1, 2)])
        end
    end
    return reduced
end

function magnitude(reduced)
    redmag = deepcopy(reduced)
    lv = 4
    while lv ≥ 1
        n = 1
        while n ≤ length(redmag)
            if n < length(redmag) && all(==(lv), first.(redmag[n:n+1]))
                redmag[n] = [lv - 1, 3 * last(redmag[n]) + 2 * last(redmag[n+1])]
                deleteat!(redmag, n+1)
            end
            n += 1
        end
        lv -= 1
    end
    return last(first(redmag))
end

function part1(list)
    sn = eval.(Meta.parse.(list))
    reduced = encode(sn[begin], 0)
    for s in sn[begin+1:end]
        reduced = [[a+1, b] for (a, b) in reduced]
        scode = encode(s, 1)
        reduced = reduce_code(vcat(reduced, scode))
    end
    return reduced, magnitude(reduced)
end

testit("Test Part 1", part1(split("[1,1]\n[2,2]\n[3,3]\n[4,4]", '\n')), ==(part1("[[[[1,1],[2,2]],[3,3]],[4,4]]")))
testit("Test Part 1", part1(split("[1,1]
[2,2]
[3,3]
[4,4]", '\n')), ==(part1("[[[[1,1],[2,2]],[3,3]],[4,4]]")))
testit("Test Part 1", part1(split("[1,1]\n[2,2]\n[3,3]\n[4,4]\n[5,5]", '\n')), ==(part1("[[[[3,0],[5,3]],[4,4]],[5,5]]")))
testit("Test Part 1", part1(split("[1,1]\n[2,2]\n[3,3]\n[4,4]\n[5,5]\n[6,6]", '\n')), ==(part1("[[[[5,0],[7,4]],[5,5]],[6,6]]")))
testit("Test Part 1", part1(split("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]", '\n')), ==(part1("[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]")))
testit("Test Part 1", part1(split("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]", '\n')), ==(part1("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")))

testit("Test Part 1", part1("[[1,2],[[3,4],5]]")[2], ==(143))
testit("Test Part 1", part1("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")[2], ==(1384))
testit("Test Part 1", part1("[[[[1,1],[2,2]],[3,3]],[4,4]]")[2], ==(445))
testit("Test Part 1", part1("[[[[3,0],[5,3]],[4,4]],[5,5]]")[2], ==(791))
testit("Test Part 1", part1("[[[[5,0],[7,4]],[5,5]],[6,6]]")[2], ==(1137))
testit("Test Part 1", part1("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")[2], ==(3488))

testit("Test Part 1", part1(split("[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]", '\n'))[2], ==(4140))

testit("Challenge Part 1", part1(list_str)[2], ==(3411))

# Part 2

function part2(list)
    sn = eval.(Meta.parse.(list))
    mag = 0
    k = length(sn)
    for k1 in 1:k, k2 in 1:k
        if k1 ≠ k2
            c1 = encode(sn[k1], 1)
            c2 = encode(sn[k2], 1)
            reduced = reduce_code(vcat(c1, c2))
            mag = max(mag, magnitude(reduced))
        end
    end
    return mag
end

testit("Test Part 2", part2(split("[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]", '\n')), ==(3993))

testit("Challenge Part 2", part2(list_str), ==(4680))

