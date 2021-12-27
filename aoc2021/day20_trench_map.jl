list_test_str = split(
"..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###",
'\n'
)

list_str = let input = @__DIR__() * "/day20_input.txt"
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

function enhance!(img, aux, algorithm, num, k)
    n, m = size(img)
    aux .= ifelse(img[1] == '.', algorithm[1], algorithm[end])
    for j in 2:m-1
        for i in 2:m-1
            r = mapreduce(
                u -> last(u) * 2^(9-first(u)),
                +,
                enumerate(reshape([ c == '#' for c in permutedims(@view(img[i-1:i+1, j-1:j+1]))], 1, :))
            )
            aux[i, j] = algorithm[r+1]
        end
    end
    img .= aux
end

function part1(list, num)
    algorithm = list[1]
    n = length(list) + 2 * num
    m = length(list[end]) + 2 * (num + 1)
    img = fill('.', n, m)
    aux = copy(img)
    img[num+2:end-num-1, num+2:end-num-1] .= permutedims(reduce(hcat, collect.(list[3:end])))
    for k in 1:num
        enhance!(img, aux, algorithm, num, k)
    end
    return img, count(img .== '#')
end

testit("Test Part 1", part1(list_test_str, 2)[2], ==(35))
testit("Challenge Part 1", part1(list_str, 2)[2], ==(5884))
# 5944 too high

# Part 2

function part2(list)
end

testit("Test Part 2", part1(list_test_str, 50)[2], ==(3351))
testit("Challenge Part 2", part1(list_str, 50)[2], ==(19043))
