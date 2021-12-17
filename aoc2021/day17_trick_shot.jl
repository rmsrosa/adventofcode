list_test_str = "target area: x=20..30, y=-10..-5"

list_str = "target area: x=156..202, y=-110..-69"

# Test function

function testit(name, result, check::Function)
    if check(result)
        @info "$name successful, with result $result"
    else
        @warn "$name failed, with result $result"
    end
end

# Solving both at the same time

function solve(list)
    a, b, c, d = parse.(Int, match(r"(-?\d*)\.\.(-?\d*), y=(-?\d*)\.\.(-?\d*)", list).captures)
    good = Matrix{Int}(undef, 0, 3)
    for vx in 0:b
        for vy in c:-2c
            xmax = div(vx * (vx + 1), 2)
            y = 0
            n = 0
            while y ≥ c
                n += 1
                # iterating vx, vy and then x and y is probably faster, though
                x = n < vx ? n * vx - div(n * (n - 1), 2) : xmax
                y = n * vy - div(n * (n - 1), 2)
                if x ∈ a:b && y ∈ c:d
                    good = vcat(good, [vx vy n])
                end
            end
        end
    end
    goodmaxima = [maximum(n * g[2] - div(n * (n - 1), 2) for n in 1:g[3]) for g in eachrow(good)]
    return good, size(unique(good[:, 1:2], dims=1), 1), maximum(goodmaxima)
end

# Part 1

testit("Test Part 1", solve(list_test_str)[3], ==(45))
testit("Challenge Part 1", solve(list_str)[3], ==(5995))

# Part 2

testit("Test Part 2", solve(list_test_str)[2], ==(112))
testit("Challenge Part 2", solve(list_str)[2], ==(3202))
