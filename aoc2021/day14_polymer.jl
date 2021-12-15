list_test_str = split(
"NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C",
'\n'
)

list_str = let input = "day14_input.txt"
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

function part1(list, n)
    polymer = list[1]
    rules = Dict{String, String}()
    for l in list[3:end]
        a, b = split(l, " -> ")
        push!(rules, a => first(a) * b)
    end
    while n > 0
        oldpolymer = polymer
        polymer = ""
        for i in 1:length(oldpolymer)-1
            polymer *= rules[oldpolymer[i:i+1]]
        end
        polymer *= last(oldpolymer)
        n -= 1
    end
    res = extrema([count(c -> c == d, polymer) for d in unique(polymer)]) |> u -> last(u) - first(u)
    return polymer, res
end

testit("Test Part 1", part1(list_test_str, 1)[1], ==("NCNBCHB"))
testit("Test Part 1", part1(list_test_str, 2)[1], ==("NBCCNBBBCBHCB"))
testit("Test Part 1", part1(list_test_str, 3)[1], ==("NBBBCNCCNBBNBNBBCHBHHBCHB"))
testit("Test Part 1", part1(list_test_str, 4)[1], ==("NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB"))
testit("Test Part 1", part1(list_test_str, 10)[2], ==(1588))
testit("Challenge Part 1", part1(list_str, 10)[2], ==(3342))

# Part 2

function part2(list, n)
    polymer = list[1]
    rules = Dict{String, Tuple{String, String}}()
    cs = Dict{String, Int}()

    for l in list[3:end]
        a, b = split(l, " -> ")
        push!(rules, a => (first(a) * b, b * last(a)))
        push!(cs, a => length(collect(eachmatch(Regex(a), polymer))))
    end
    
    while n > 0
        for (k, v) in filter(kv -> last(kv) > 0, cs)
            cs[k] -= v
            cs[first(rules[k])] += v
            cs[last(rules[k])] += v
        end
        n -= 1
    end
    ks = Dict{Char, Int}()
    for (k, v) in filter(kv -> last(kv) > 0, cs)
        if first(k) in keys(ks)
            ks[first(k)] += v
        else
            push!(ks, first(k) => v)
        end
    end

    if last(polymer) in keys(ks)
        ks[last(polymer)] += 1
    else
        push!(ks, last(polymer) => 1)
    end
    m, n = extrema(values(ks))
    res = n - m
    return rules, cs, ks, res
end

testit("Test Part 2", part2(list_test_str, 10)[4], ==(1588))
testit("Test Part 2", part2(list_str, 10)[4], ==(3342))
testit("Test Part 2", part2(list_test_str, 40)[4], ==(2188189693529))
testit("Challenge Part 2", part2(list_str, 40)[4], ==(3776553567525))

