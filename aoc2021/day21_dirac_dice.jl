#= 
Test data:
Player 1 starting position: 4
Player 2 starting position: 8

Challenge data:
Player 1 starting position: 7
Player 2 starting position: 4
=#

# Test function

function testit(name, result, check::Function)
    if check(result)
        @info "$name successful, with result $result"
    else
        @warn "$name failed, with result $result"
    end
end

# Part 1

function part1(x1, x2)
    p1 = 0
    p2 = 0
    ndice = 0
    while true
        dice = mod1(ndice + 1, 100)
        x1 = mod1(x1 + 3 * dice + 3, 10)
        p1 += x1
        ndice += 3
        p1 < 1000 || break
        x2 = mod1(x2 + 3 * dice + 12, 10)
        p2 += x2
        ndice += 3
        p2 < 1000 || break
    end
    return min(p1, p2) * ndice
end

testit("Test Part 1", part1(4, 8), ==(739785))
testit("Challenge Part 1", part1(7, 4), ==(675024))

# Part 2

function part2(x1, x2)
    # `universes[x1, x2, p1, p2]` number of universes where players 1 and 2 are,
    # respectively, in spaces `x1` and `x2`, and with `p1 - 1` and `p2 - 1` points.
    #
    # I was planning to use a sparse array, but SparseArrays only handles vectors
    # and matrices. There seems to be other packages for multidimensional sparse arrays,
    # but I didn't want to bother using them.

    universes = zeros(Int, 10, 10, 21, 21)

    # starts out with one universe with players at `x1` and `x2`, with zero points each
    universes[x1, x2, 1, 1] = 1 
    nextunvrs = zero(universes)

    nw1 = 0 # number of wins for player 1
    nw2 = 0 # same for player 2

    # pairs of total points and number of universes with those points - 27 universes total
    draws = (
        (3, 1),
        (4, 3),
        (5, 6),
        (6, 7),
        (7, 6),
        (8, 3),
        (9, 1)
    )

    while any(!iszero, universes)
        # first player's turn
        for x1 in 1:10, x2 in 1:10, p1 in 1:21, p2 in 1:21
            if universes[x1, x2, p1, p2] > 0
                for (s1, m1) in draws
                    in1 = mod1(x1 + s1, 10)
                    if p1 + in1 ≥ 22
                        nw1 += m1 * universes[x1, x2, p1, p2]
                    else
                        nextunvrs[in1, x2, p1 + in1, p2] += m1 * universes[x1, x2, p1, p2]
                    end
                end
            end
        end
        universes .= nextunvrs
        nextunvrs .= 0
        # second player's turn
        for x1 in 1:10, x2 in 1:10, p1 in 1:21, p2 in 1:21
            if universes[x1, x2, p1, p2] > 0
                for (s2, m2) in draws
                    in2 = mod1(x2 + s2, 10)
                    if p2 + in2 ≥ 22
                        nw2 += m2 * universes[x1, x2, p1, p2]
                    else
                        nextunvrs[x1, in2, p1, p2 + in2] += m2 * universes[x1, x2, p1, p2]
                    end
                end
            end
        end
        universes .= nextunvrs
        nextunvrs .= 0
    end
    return max(nw1, nw2)
end

function part2_dict(x1, x2)
    # `universes` is a Dict where the keys `universes[(x1, x2, p1, p2)]` is the number
    # of universes where players 1 and 2 are, respectively, in spaces `x1` and `x2`
    # and with `p1` and `p2` points
    universes = Dict{NTuple{4, Int}, Int}()
    nextunvrs = Dict{NTuple{4, Int}, Int}()

    # starts out with one universe with players at `x1` and `x2` with zero points each
    push!(universes, (x1, x2, 0, 0) => 1)

    nw1 = 0 # number of wins for player 1
    nw2 = 0 # same for player 2

    # pairs of total points and number of universes with those points - 27 universes total
    draws = (
        (3, 1),
        (4, 3),
        (5, 6),
        (6, 7),
        (7, 6),
        (8, 3),
        (9, 1)
    )

    while length(universes) > 0
        # first player's turn
        for (x1, x2, p1, p2) in keys(universes)
            m = universes[(x1, x2, p1, p2)]
            for (s1, m1) in draws
                in1 = mod1(x1 + s1, 10)
                if p1 + in1 ≥ 21
                    nw1 += m1 * m
                else
                    if haskey(nextunvrs, (in1, x2, p1 + in1, p2))
                        nextunvrs[(in1, x2, p1 + in1, p2)] += m1 * m
                    else
                        push!(nextunvrs, (in1, x2, p1 + in1, p2) => m1 * m)
                    end
                end
            end
        end
        universes = copy(nextunvrs)
        nextunvrs = Dict{NTuple{4, Int}, Int}()
        # second player's turn
        for (x1, x2, p1, p2) in keys(universes)
            m = universes[(x1, x2, p1, p2)]
            for (s2, m2) in draws
                in2 = mod1(x2 + s2, 10)
                if p2 + in2 ≥ 21
                    nw2 += m2 * m
                else
                    if haskey(nextunvrs, (x1, in2, p1, p2 + in2))
                        nextunvrs[(x1, in2, p1, p2 + in2)] += m2 * m
                    else
                        push!(nextunvrs, (x1, in2, p1, p2 + in2) => m2 * m)
                    end
                end
            end
        end
        universes = copy(nextunvrs)
        nextunvrs = Dict{NTuple{4, Int}, Int}()
    end
    return max(nw1, nw2)
end

testit("Test Part 2", part2(4, 8), ==(444356092776315))
testit("Challenge Part 2", part2(7, 4), ==(570239341223618))

testit("Test Part 2", part2_dict(4, 8), ==(444356092776315))
testit("Challenge Part 2", part2_dict(7, 4), ==(570239341223618))
