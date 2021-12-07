list_test_str = split(
"",
'\n'
)

let input = "day_input.txt"
    isfile(input) && (list_str = readlines(input))
end

# Test function

function testit(name, result, check = (args...) -> false)
    if check(result)
        @info "$name successful, with result $result"
    else
        @warn "$name failed, with result $result"
    end
end

# Part 1

function part1(list)
end

testit("Test Part 1", part1(list_test_str), ==(0))
testit("Challenge Part 1", part1(list_str), ==(0))

# Part 2

function part2(list)
end

testit("Test Part 2", part2(list_test_str), ==(0))
testit("Challenge Part 2", part2(list_str), ==(0))

