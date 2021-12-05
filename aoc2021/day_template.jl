list_test_str = split(
"",
'\n'
)

list_str = readlines("day_input.txt")

# Part 1

function part1(list)
end

@info "Part 1"
let result = part1(list_test_str)
    if result == 0
        @info "Test successful, with result $result"
    else
        @warn "Test failed, with result $result"
    end
end
let result = part1(list_str)
    if result == 0
        @info "Challenge successful, with result $result"
    else
        @warn "Challenge failed, with result $result"
    end
end

# Part 2

function part2(list)
end

@info "Part 2"
let result = part2(list_test_str)
    if result == 0
        @info "Test successful, with result $result"
    else
        @warn "Test failed, with result $result"
    end
end
let result = part2(list_str)
    if result == 0
        @info "Challenge successful, with result $result"
    else
        @warn "Challenge failed, with result $result"
    end
end
