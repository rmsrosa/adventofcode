# Test function

function testit(name, result, check::Function)
    if check(result)
        @info "$name successful, with result $result"
    else
        @warn "$name failed, with result $result"
    end
end

# Part 1

# spaces:
#    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 # hallway
#    12, 13 # Room for As
#    14, 15 # Room for Bs
#    16, 17 # Room for Cs
#    18, 19 # Room for Ds

const MULTIPLIER = Dict(
    :A1 => 1,
    :A2 => 1,
    :B1 => 10,
    :B2 => 10,
    :C1 => 100,
    :C2 => 100,
    :D1 => 1000,
    :D2 => 1000
)

const ENTRY_POINTS = Dict(
    :A1 => 3, :A2 => 3,
    :B1 => 5, :B2 => 5,
    :C1 => 7, :C2 => 7,
    :D1 => 9, :D2 => 9
)

const SIBLING = Dict(
    k1 => k2 for k1 in keys(ENTRY_POINTS) for k2 in keys(ENTRY_POINTS)
    if k1 ≠ k2 && ENTRY_POINTS[k1] == ENTRY_POINTS[k2]
)

# initial configuration for the test

#############
#...........#
###B#C#B#D###
  #A#D#C#A#
  #########

initial_positions_test = Dict(
    :A1 => 13,
    :A2 => 19,
    :B1 => 12,
    :B2 => 16,
    :C1 => 14,
    :C2 => 17,
    :D1 => 15,
    :D2 => 18
)

# An easy one for testing 4 x 1 + 4 x 10 + 2 x 1 = 46 points

#############
#...........#
###B#A#C#D###
  #A#B#C#D#
  #########

initial_positions_test_almostgameoverAB = Dict(
    :A1 => 14,
    :A2 => 13,
    :B1 => 12,
    :B2 => 15,
    :C1 => 16,
    :C2 => 17,
    :D1 => 18,
    :D2 => 19
)

initial_positions_test_almostgameoverCD = Dict(
    :A1 => 12,
    :A2 => 13,
    :B1 => 14,
    :B2 => 15,
    :C1 => 18,
    :C2 => 17,
    :D1 => 16,
    :D2 => 19
)

initial_positions_test_almostgameoverAD = Dict(
    :A1 => 18,
    :A2 => 13,
    :B1 => 14,
    :B2 => 15,
    :C1 => 16,
    :C2 => 17,
    :D1 => 12,
    :D2 => 19
)

#############
#...........#
###D#B#C#A###
  #D#B#C#A#
  #########

initial_positions_test_almostgameoverAADD = Dict(
    :A1 => 18,
    :A2 => 19,
    :B1 => 14,
    :B2 => 15,
    :C1 => 16,
    :C2 => 17,
    :D1 => 12,
    :D2 => 13
)

# initial configuration for the challenge

#############
#...........#
###B#D#C#A###
  #C#D#B#A#
  #########

initial_positions_challenge = Dict(
    :A1 => 18,
    :A2 => 19,
    :B1 => 12,
    :B2 => 17,
    :C1 => 13,
    :C2 => 16,
    :D1 => 14,
    :D2 => 15
)

# Part 1

gameover(positions) = all(
    Set(get.(identity, Ref(positions), keys)) == Set(pos)
    for (keys, pos) in zip(
        ((:A1, :A2), (:B1, :B2), (:C1, :C2), (:D1, :D2)),
        ((i, i+1) for i in 12:2:18)
    )
)

function allowedmoves(positions, k)
    pk = positions[k]
    mvs = []
    e = ENTRY_POINTS[k]

    e9 = e + 9
    e10 = e + 10
    if pk ≤ 11
        if isdisjoint(values(positions), union(e:pk-1, pk+1:e, e9:e10))
            push!(mvs, (e10, length(e:pk-1) + length(pk+1:e) + 2))
        elseif isdisjoint(values(positions), union(e:pk-1, pk+1:e, e9)) &&
            positions[SIBLING[k]] == e10
            push!(mvs, (e9, length(e:pk-1) + length(pk+1:e) + 1))
        end
    elseif pk != e10 && pk:positions[SIBLING[k]] != e9:e10
        if pk in 12:2:18 && isdisjoint(values(positions), union(pk-9:e, e:pk-9, e9:e10))
            push!(mvs, (e10, length(pk-9:e) + length(e:pk-9) + 2))
        elseif pk in 12:2:18 && isdisjoint(values(positions), union(pk-9:e, e:pk-9, e9)) &&
            positions[SIBLING[k]] == e10
            push!(mvs, (e9, length(pk-9:e) + length(e:pk-9) + 1))
        elseif pk in 13:2:19 && isdisjoint(values(positions), union(pk-1, pk-10:e, e:pk-10, e9:e10))
            push!(mvs, (e10, length(pk-10:e) + length(e:pk-10) + 3))
        elseif pk in 13:2:19 && isdisjoint(values(positions), union(pk-1, pk-10:e, e:pk-10, e9)) &&
            positions[SIBLING[k]] == e10
            push!(mvs, (e9, length(pk-10:e) + length(e:pk-10) + 2))
        else
            for p in (1, 2, 4, 6, 8, 10, 11)
                if pk in 12:2:18 && isdisjoint(values(positions), union(p:pk-9, pk-9:p))
                    push!(mvs, (p, length(p:pk-9) + length(pk-9:p)))
                elseif isdisjoint(values(positions), union(pk-1, p:pk-10, pk-10:p))
                    push!(mvs, (p, length(p:pk-10) + length(pk-10:p) + 1))
                end
            end
        end
    end
    return mvs
end

function move(positions, points = 0, minpoints = typemax(Int),
    moves = Vector{Tuple{Symbol, Pair{Int, Int}, Int}}(), minmoves = Vector{Tuple{Symbol, Pair{Int, Int}, Int}}())
    if points < minpoints && gameover(positions)
        minpoints = points
        minmoves = moves
    else
        for k in keys(positions)
            for (pos, steps) in allowedmoves(positions, k)
                step_pts = MULTIPLIER[k] * steps
                newpoints = points + step_pts                
                if newpoints < minpoints
                    newpositions = copy(positions)
                    newpositions[k] = pos
                    newmoves = [moves; (k, positions[k] => pos, step_pts)]
                    minmoves, minpoints = move(newpositions, newpoints, minpoints, newmoves, minmoves)
                end
            end
        end
    end
    return minmoves, minpoints
end

function part1(initial_positions)
    move(initial_positions)
end

testit("Test Part 1 AB", part1(initial_positions_test_almostgameoverAB)[2], ==(46))
testit("Test Part 1 CD", part1(initial_positions_test_almostgameoverCD)[2], ==(4600))
testit("Test Part 1 DC", part1(initial_positions_test_almostgameoverAD)[2], ==(8010))
testit("Test Part 1 AADD", part1(initial_positions_test_almostgameoverAADD)[2], ==(18022))
testit("Test Part 1", part1(initial_positions_test)[2], ==(12521))
testit("Challenge Part 1", part1(initial_positions_challenge)[2], ==(15322))
