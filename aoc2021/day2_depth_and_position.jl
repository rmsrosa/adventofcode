
list_test_str = split(
"forward 5
down 5
forward 8
up 3
down 8
forward 2",
'\n'
)

list_str = readlines("day2_input.txt")

# Part 1

function part1(list)
    depth = 0
    pos = 0
    for cmd in list
        m, k = split(cmd, ' ')
        k = parse(Int, k)
        pos += m == "forward" ? k : 0
        depth += m == "up" ? -k : m == "down" ? k : 0
    end
    return pos * depth
end

@info "Part 1"
@info "test:"
@show part1(list_test_str) == 150
@info "challenge:" 
@show part1(list_str) == 1714680

# Part 2

function part2(list)
    depth = 0
    pos = 0
    aim = 0
    for cmd in list
        m, k = split(cmd, ' ')
        k = parse(Int, k)
        pos += m == "forward" ? k : 0
        depth += m == "forward" ? aim * k : 0
        aim += m == "up" ? -k : m == "down" ? k : 0
    end
    return pos * depth
end

@info "Part 2"
@info "test:"
@show part2(list_test_str) == 900
@info "challenge:"
@show part2(list_str) == 1963088820

# Alternative

forward(k) = [0, k]
up(k) = [-k, 0]
down(k) = [k, 0]

function part1_alt(list)
    commands = [split(cmd) |> u -> (Symbol(first(u)), parse(Int, last(u))) for cmd in list]
    return prod(mapreduce(u -> eval(first(u))(last(u)), +, commands))
end

@info "Part 1 alt"
@info "test:"
@show part1_alt(list_test_str) == 150
@info "challenge:" 
@show part1_alt(list_str) == 1714680

nothing

