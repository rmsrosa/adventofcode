list_ex_str = "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"

list_test_str = split(
"be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce",
'\n'
)

list_str = let input = "day8_input.txt"
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

encoding = [
    "abcef"
    "cf"
    "acdeg"
    "acdfg"
    "bcdf"
    "abdfg"
    "abdefg"
    "abcdefg"
    "abcdfg"
]

function part1(list)
    output = []
    for line in list
        u, v = map(split, split(line, " | "))
        ulen = length.(u)
        
        for uleni in ulen
            if count(ulen .== uleni) == 1
                for j in 1:4
                    if length(v[j]) == uleni
                        push!(output, v[j])
                    end
                end
            end
        end
    end
    return output, length(output)
end


testit("Test Part 1", part1(list_test_str)[2], ==(26))
testit("Challenge Part 1", part1(list_str)[2], ==(255))

# Part 2

function part2(list)
    digs = Dict(
        "abcefg" => 0,
        "cf" => 1,
        "acdeg" => 2,
        "acdfg" => 3,
        "bcdf" => 4,
        "abdfg" => 5,
        "abdefg" => 6,
        "acf" => 7,
        "abcdefg" => 8,
        "abcdfg" => 9
        )

    total = 0
    for line in list
        u, v = map(split, split(line, " | "))
        ulen = length.(u)
        
        d = Dict{Char, Char}()
        push!(d, first(reduce(intersect, Set.(u[broadcast(∈((3, 5)), ulen)]))) => 'a')
        push!(d, first(reduce(intersect, Set.(u[broadcast(∈((2, 6)), ulen)]))) => 'f')
        push!(d, first(setdiff(Set(u[ulen .== 2][1]), reduce(intersect, Set.(u[broadcast(∈((2, 6)), ulen)])))) => 'c')
        push!(d, first(reduce(intersect, Set.(u[broadcast(∈((4, 5)), ulen)]))) => 'd')
        push!(d, first(setdiff(reduce(symdiff, Set.(u[broadcast(∈((3, 4)), ulen)])), keys(d))) => 'b')
        push!(d, first(setdiff(reduce(intersect, Set.(u[broadcast(∈((6)), ulen)])), Set(keys(d)))) => 'g')
        push!(d, first(setdiff('a':'g', keys(d))) => 'e')

        total += sum([10^(4-j) * digs[prod(sort(collect(Set(d[k] for k in v[j]))))] for j in eachindex(v)])
    end
    return total
end

testit("Test Part 2", part2(list_test_str), ==(61229))
testit("Challenge Part 2", part2(list_str), ==(982158))
