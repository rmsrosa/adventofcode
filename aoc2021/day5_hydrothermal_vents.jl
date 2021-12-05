list_test_str = split(
"0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2",
'\n'
)

list_str = readlines("day5_input.txt")

# Part 1

function part1(list)
    vents = Matrix{Int}(undef, length(list), 4)
    for (i,l) in enumerate(list)
        m = match(r"(\d+)\,(\d+)\s..\s(\d+)\,(\d+)", l)
        vents[i, :] .= parse.(Int, m.captures) .+ 1
    end
    xmax = maximum(@view(vents[:, [1,3]]))
    ymax = maximum(@view(vents[:, [2,4]]))
    diagram = zeros(Int, ymax, xmax)
    for row in eachrow(vents)
        if row[1] == row[3]
            s = sign(row[4] - row[2])
            diagram[row[2]:s:row[4], row[1]] .+= 1
        elseif row[2] == row[4]
            r = sign(row[3] - row[1])
            diagram[row[2], row[1]:r:row[3]] .+= 1
        end
    end
    return count(diagram .> 1)
end

@info "Part 1"
let result = part1(list_test_str)
    if result == 5
        @info "Test successful, with result $result"
    else
        @warn "Test failed, with result $result"
    end
end
let result = part1(list_str)
    if result == 6283
        @info "Challenge successful, with result $result"
    else
        @warn "Challenge failed, with result $result"
    end
end

# Part 2

function part2(list)
    vents = Matrix{Int}(undef, length(list), 4)
    for (i,l) in enumerate(list)
        m = match(r"(\d+)\,(\d+)\s..\s(\d+)\,(\d+)", l)
        vents[i, :] .= parse.(Int, m.captures) .+ 1
    end
    xmax = maximum(@view(vents[:, [1,3]]))
    ymax = maximum(@view(vents[:, [2,4]]))
    diagram = zeros(Int, ymax, xmax)
    for row in eachrow(vents)
        if row[1] == row[3]
            s = sign(row[4] - row[2])
            diagram[row[2]:s:row[4], row[1]] .+= 1
        elseif row[2] == row[4]
            r = sign(row[3] - row[1])
            diagram[row[2], row[1]:r:row[3]] .+= 1
        else
            l = abs(row[3] - row[1])
            r = sign(row[3] - row[1])
            s = sign(row[4] - row[2])
            rx = row[1]
            ry = row[2]
            for _ in 0:l
                diagram[ry, rx] += 1
                rx += r
                ry += s
            end
        end
    end
    count(diagram .> 1)
end

@info "Part 2"
let result = part2(list_test_str)
    if result == 12
        @info "Test successful, with result $result"
    else
        @warn "Test failed, with result $result"
    end
end
let result = part2(list_str)
    if result == 18864
        @info "Challenge successful, with result $result"
    else
        @warn "Challenge failed, with result $result"
    end
end

# Split functions

function init(list)
    vents = Matrix{Int}(undef, length(list), 4)
    for (i,l) in enumerate(list)
        m = match(r"(\d+)\,(\d+)\s..\s(\d+)\,(\d+)", l)
        vents[i, :] .= parse.(Int, m.captures) .+ 1
    end
    xmax = maximum(@view(vents[:, [1,3]]))
    ymax = maximum(@view(vents[:, [2,4]]))
    diagram = zeros(Int, ymax, xmax)
    return diagram, vents
end

function diagram_part1!(diagram, vents)
    for row in eachrow(vents)
        if row[1] == row[3]
            s = sign(row[4] - row[2])
            diagram[row[2]:s:row[4], row[1]] .+= 1
        elseif row[2] == row[4]
            r = sign(row[3] - row[1])
            diagram[row[2], row[1]:r:row[3]] .+= 1
        end
    end
    return diagram
end

function diagram_part2!(diagram, vents)
    for row in eachrow(vents)
        if row[1] == row[3]
            s = sign(row[4] - row[2])
            diagram[row[2]:s:row[4], row[1]] .+= 1
        elseif row[2] == row[4]
            r = sign(row[3] - row[1])
            diagram[row[2], row[1]:r:row[3]] .+= 1
        else
            l = abs(row[3] - row[1])
            r = sign(row[3] - row[1])
            s = sign(row[4] - row[2])
            rx = row[1]
            ry = row[2]
            for _ in 0:l
                diagram[ry, rx] += 1
                rx += r
                ry += s
            end
        end
    end
    return diagram
end

function part1_alt(list)
    diagram, vents = init(list)
    diagram_part1!(diagram, vents)
    return count(diagram .> 1)
end

function part2_alt(list)
    diagram, vents = init(list)
    diagram_part2!(diagram, vents)
    return count(diagram .> 1)
end

@info "Part 1 alt"
let result = part1_alt(list_test_str)
    if result == 5
        @info "Test successful, with result $result"
    else
        @warn "Test failed, with result $result"
    end
end
let result = part1_alt(list_str)
    if result == 6283
        @info "Challenge successful, with result $result"
    else
        @warn "Challenge failed, with result $result"
    end
end

@info "Part 2"
let result = part2(list_test_str)
    if result == 12
        @info "Test successful, with result $result"
    else
        @warn "Test failed, with result $result"
    end
end
let result = part2(list_str)
    if result == 18864
        @info "Challenge successful, with result $result"
    else
        @warn "Challenge failed, with result $result"
    end
end

# Surface plot

function surface_plot(list)
    diagram, vents = init(list)
    diagram_part2!(diagram, vents)
    display(
        surface(
            diagram,
            title="Advent of Code - Day 5 - Hydrothermal Vents",
            titlefont = 12
        )
    )
end

surface_plot(list_test_str)
surface_plot(list_str)
savefig("hydrothermal_vents.png")
