# Test function

function testit(name, result, check::Function)
    if check(result)
        @info "$name successful, with result $result"
    else
        @warn "$name failed, with result $result"
    end
end

# Part 2

# spaces:
#    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 # hallway
#    12, 13, 14, 15 # Room for As
#    16, 17, 18, 19 # Room for Bs
#    20, 21, 22, 23 # Room for Cs
#    24, 25, 26, 27 # Room for Ds

const AMPHIPODS = Dict(
    'A' => (:A1, :A2, :A3, :A4),
    'B' => (:B1, :B2, :B3, :B4),
    'C' => (:C1, :C2, :C3, :C4),
    'D' => (:D1, :D2, :D3, :D4)
)


const SIBLINGS = reduce(
    merge, 
    [Dict(a => Set(filter(≠(a), AMPHIPODS[s])) for a in AMPHIPODS[s]) for s in 'A':'D']
)


const MULTIPLIER = reduce(
    merge,
    Dict(k => 10^(j-1) for k in AMPHIPODS[c]) for (j, c) in enumerate('A':'D')
)

function entry(k)
    for (i, c) in enumerate('A':'D')
        if k in AMPHIPODS[c]
            return (1 + 2 * i, 12 + 4 * (i-1))
        end
    end
end

exit(n) = div(n - 12, 4) |> m -> (3 + 2 * m, 12 + 4 * m)

# initial configuration for the test

#############
#...........#
###B#C#B#D###
  #D#C#B#A#
  #D#B#A#C#
  #A#D#C#A#
  #########

initial_positions_test = Dict(
    :A1 => 15,
    :A2 => 22,
    :A3 => 25,
    :A4 => 27,
    :B1 => 12,
    :B2 => 18,
    :B3 => 20,
    :B4 => 21,
    :C1 => 16,
    :C2 => 17,
    :C3 => 23,
    :C4 => 26,
    :D1 => 13,
    :D2 => 14,
    :D3 => 19,
    :D4 => 24
)

# An easy one for testing 4 x 1 + 4 x 10 + 2 x 1 = 46 points

#############
#...........#
###B#A#C#D###
  #A#B#C#D#
  #A#B#C#D#
  #A#B#C#D#
  #########

initial_positions_test_almostgameoverAB = Dict(
    :A1 => 16,
    :A2 => 13,
    :A3 => 14,
    :A4 => 15,
    :B1 => 12,
    :B2 => 17,
    :B3 => 18,
    :B4 => 19,
    :C1 => 20,
    :C2 => 21,
    :C3 => 22,
    :C4 => 23,
    :D1 => 24,
    :D2 => 25,
    :D3 => 26,
    :D4 => 27
)

initial_positions_test_almostgameoverCD = Dict(
    :A1 => 12,
    :A2 => 13,
    :A3 => 14,
    :A4 => 15,
    :B1 => 16,
    :B2 => 17,
    :B3 => 18,
    :B4 => 19,
    :C1 => 24,
    :C2 => 21,
    :C3 => 22,
    :C4 => 23,
    :D1 => 20,
    :D2 => 25,
    :D3 => 26,
    :D4 => 27
)

initial_positions_test_almostgameoverAADD = Dict(
    :A1 => 24,
    :A2 => 25,
    :A3 => 14,
    :A4 => 15,
    :B1 => 16,
    :B2 => 17,
    :B3 => 18,
    :B4 => 19,
    :C1 => 20,
    :C2 => 21,
    :C3 => 22,
    :C4 => 23,
    :D1 => 12,
    :D2 => 13,
    :D3 => 26,
    :D4 => 27
)

# initial configuration for the challenge

#############
#...........#
###B#D#C#A###
  #D#C#B#A#
  #D#B#A#C#
  #C#D#B#A#
  #########

initial_positions_challenge = Dict(
    :A1 => 22,
    :A2 => 24,
    :A3 => 25,
    :A4 => 27,
    :B1 => 12,
    :B2 => 18,
    :B3 => 21,
    :B4 => 23,
    :C1 => 15,
    :C2 => 17,
    :C3 => 20,
    :C4 => 26,
    :D1 => 13,
    :D2 => 14,
    :D3 => 16,
    :D4 => 19
)

# Part 2

gameover(positions) = all(
    u -> Set(positions[a] for a in AMPHIPODS[last(u)]) == Set((8 + 4*first(u) + j for j in 0:3)),
    enumerate('A':'D')
)

function allowedmoves(positions, k)
    pk = positions[k]
    mvs = []
    enh, enr = entry(k) # entry point in hallway and in room
    exh, exr = exit(positions[k]) # exit point in hallway and in room
    if pk ≤ 11
        for i in 3:-1:0
            if isdisjoint(values(positions), union(enh:pk-1, pk+1:enh, enr:enr+i)) &&
                    enr+i+1:enr+3 ⊆ (positions[sk] for sk in SIBLINGS[k])
                push!(mvs, (enr+i, length(enh:pk-1) + length(pk+1:enh) + i + 1))
                return mvs
            end
        end
    elseif pk ∉ enr:enr+3 || pk+1:enr+3 ⊈ (positions[sk] for sk in SIBLINGS[k])
        for i in 3:-1:0
            if isdisjoint(values(positions), union(exr:pk-1, exh:enh, enh:exh, enr:enr+i)) &&
                enr+i+1:enr+3 ⊆ (positions[sk] for sk in SIBLINGS[k])
                push!(mvs, (enr+i, length(exr:pk-1) + length(exh:enh) + length(enh:exh) + i + 1))
                return mvs
            end
        end
        for p in (1, 2, 4, 6, 8, 10, 11)
            if isdisjoint(values(positions), union(exr:pk-1, exh:p, p:exh))
                push!(mvs, (p, length(exr:pk-1) + length(exh:p) + length(p:exh)))
            end
        end
    end
    return mvs
end

function move(positions, points = 0, minpoints = typemax(Int),
    moves = Vector{Tuple{Symbol, Pair{Int, Int}, Int}}(),
    minmoves = Vector{Tuple{Symbol, Pair{Int, Int}, Int}}()
)
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

function part2(initial_positions)
    move(initial_positions)
end

testit("Test Part 2 AB", part2(initial_positions_test_almostgameoverAB)[2], ==(46))
testit("Test Part 2 CD", part2(initial_positions_test_almostgameoverCD)[2], ==(4600))
testit("Test Part 2 AADD", part2(initial_positions_test_almostgameoverAADD)[2], ==(18022))
testit("Test Part 2", part2(initial_positions_test)[2], ==(44169))
testit("Challenge Part 2", part2(initial_positions_challenge)[2], ==(15322))

# Visualization

# A better approach is to make `Board` a subtype of AbstractVector, with length 27, and
# just set directly the element at a given position on the board, instead of rebuilding
# the entire board after each move.

struct Board
    mat::Matrix{Char}
end

function Board(positions::Dict = Dict())
    b = Board(fill('#', 7, 13))
    b.mat[4:end, 1:2] .= ' '
    b.mat[4:end, 12:13] .= ' '
    b.mat[2, 2:12] .= '.'
    b.mat[3:6, [4, 6, 8, 10]] .= '.'
    for (k, v) in positions
        if 1 ≤ v ≤ 11
            b.mat[2, 1 + v] = first(string(k))
        else
            d, r = divrem(v - 12, 4)
            b.mat[3 + r, 4 + 2*d] = first(string(k))
        end
    end
    return b
end

function Base.show(io::IO, b::Board)
    for bi in eachrow(b.mat)
        println(join(bi))
    end
end

function showsolution(positions, moves)
    b = Board(positions)
    println(b)
    sleep(5)
    for p in moves
        positions[p[1]] = last(p[2])
        b = Board(positions)
        println(b)
        sleep(1)
    end
    sleep(5)
end

# positions = copy(initial_positions_test)
# minmoves, minpoints = part2(positions)
# showsolution(positions, minmoves)

