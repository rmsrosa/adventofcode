list_test_str = split(
"",
'\n'
)

list_str = let input = "day_input.txt"
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
end

testit("Test Part 1", part1(list_test_str), ==(nothing))
testit("Challenge Part 1", part1(list_str), ==(nothing))

# Part 2

function part2(list)
end

testit("Test Part 2", part2(list_test_str), ==(nothing))
testit("Challenge Part 2", part2(list_str), ==(nothing))

