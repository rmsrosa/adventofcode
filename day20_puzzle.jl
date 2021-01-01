# Advent of Code 2020 - Day 20

using Combinatorics
using Logging

test_str = "Tile 2311:
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###

Tile 1951:
#.##...##.
#.####...#
.....#..##
#...######
.##.#....#
.###.#####
###.##.##.
.###....#.
..#.#..#.#
#...##.#..

Tile 1171:
####...##.
#..##.#..#
##.#..#.#.
.###.####.
..###.####
.##....##.
.#...####.
#.##.####.
####..#...
.....##...

Tile 1427:
###.##.#..
.#..#.##..
.#.##.#..#
#.#.#.##.#
....#...##
...##..##.
...#.#####
.#.####.#.
..#..###.#
..##.#..#.

Tile 1489:
##.#.#....
..##...#..
.##..##...
..#...#...
#####...#.
#..#.#.#.#
...#.#.#..
##.#...##.
..##.##.##
###.##.#..

Tile 2473:
#....####.
#..#.##...
#.##..#...
######.#.#
.#...#.#.#
.#########
.###.#..#.
########.#
##...##.#.
..###.#.#.

Tile 2971:
..#.#....#
#...###...
#.#.###...
##.##..#..
.#####..##
.#..####.#
#..#.#..#.
..####.###
..#.#.###.
...#.#.#.#

Tile 2729:
...#.#.#.#
####.#....
..#.#.....
....#..#.#
.##..##.#.
.#.####...
####.#.#..
##.####...
##..#.##..
#.##...##.

Tile 3079:
#.#.#####.
.#..######
..#.......
######....
####.#..#.
.#...#.##.
#.#####.##
..#.###...
..#.......
..#.###..."

test_list = split(test_str, '\n')

list = readlines("day20_input.txt")

"""
The operators are not always commutative, but when looking for all combinations,
it suffices to fix the order. Thus, in all what follows, it is assumed that rotations
are applied first, and then, flips.

In fact:
    * Commutative:
        * R0∘FH = FH∘R0 (R0 = identity)
        * R0∘FV = FV∘R0 (R0 = identity)
        * R180∘FH = FH∘R180
        * R180∘FV = FV∘R180
    * Non-commutative:
        * R90*FH = FV∘R90 = FH*R270
        * R90∘FV = FH∘R90 = FV∘R270
        * R270∘FH = FV∘R270 = FH∘R90
        * R270∘FV = FH∘R270 = FV∘R90

Notice from the above that there are some redundancies, even fixing the order:
    * FH∘R0 = FV∘R180
    * FH∘R90 = FV∘R270
    * FH∘R180 = FV∘R0
    * FH∘R270 = FV∘R90

The last three also follow from the first one by repeatedly applying R90 from the right.

From these, we see that we may consider only FH or only FV.

It is easy to deduce the relations above imagining a 2D square, but it is even
easier in the complex plane, with z=x+iy:
    * R0 = 1
    * R90 = multiplication by i
    * R180 = i^2 = -1
    * R270 = i^3 = -i
    * FN = 1
    * FV = conjugate (z -> z̄ )
    * FH = z -> -z̄ (in fact z = x+iy -> -x+iy = -(x-iy) = -z̄ ) (i.e. FH∘R0 = FV∘R180)
"""
const R0, R90, R180, R270 = Int8.((1, 2, 3, 4))
const FN, FH, FV = Int8.((1, 2, 3))
const RIGHT, LEFT, TOP, BOTTOM = Int8.((1, 2, 3, 4))

function get_side(tile, rotation, flip, side)
    """
        get_side(tile, orientation, side)

    Return the desired `side` for a given `tile` with the given `orientation`
    and `flip`

    The sides are, of course, `RIGHT`, `LEFT`, `TOP`, and `BOTTOM`

    The rotations are `R0`, `R90`, `R180`, and `R270` for,
    respectively 0ᵒ, 90ᵒ, 180ᵒ, and 270ᵒ anticlockwise rotations
    
    The possible flips are `FN`, `FH`, and `FV` for no-flip and horizontal
    and vertical flips, respectively.

    The returned side is from left to right, for `top` and `bottom` sides,
    and from top to bottom, for `LEFT` and `RIGHT` sides.
    """
    if (rotation, flip, side) ∈ ((R0, FN, RIGHT), (R0, FH, LEFT), (R90, FN, TOP), (R90, FV, BOTTOM), (R180, FV, LEFT), (R270, FH, BOTTOM))
        return tile[:,end]
    elseif (rotation, flip, side) ∈ ((R0, FV, RIGHT), (R90, FH, TOP), (R180, FN, LEFT), (R180, FH, RIGHT), (R270, FN, BOTTOM), (R270, FV, TOP))
        return tile[end:-1:1,end]
    elseif (rotation, flip, side) ∈ ((R0, FN, TOP), (R0, FV, BOTTOM), (R90, FV, LEFT), (R180, FH, BOTTOM), (R270, FN, RIGHT), (R270, FH, LEFT))
        return tile[1,:]
    elseif (rotation, flip, side) ∈ ((R0, FH, TOP), (R90, FN, LEFT), (R90, FH, RIGHT), (R180, FN, BOTTOM), (R180, FV, TOP), (R270, FV, RIGHT))
        return tile[1,end:-1:1]
    elseif (rotation, flip, side) ∈ ((R0, FN, LEFT), (R0, FH, RIGHT), (R90, FN, BOTTOM), (R90, FV, TOP), (R180, FV, RIGHT), (R270, FH, TOP))
        return tile[:,1]
    elseif (rotation, flip, side) ∈ ((R0, FV, LEFT), (R90, FH, BOTTOM), (R180, FN, RIGHT), (R180, FH, LEFT), (R270, FN, TOP), (R270, FV, BOTTOM))
        return tile[end:-1:1,1]
    elseif (rotation, flip, side) ∈ ((R0, FN, BOTTOM), (R0, FV, TOP), (R90, FV, RIGHT), (R180, FH, TOP), (R270, FN, LEFT), (R270, FH, RIGHT))
        return tile[end,:]
    elseif (rotation, flip, side) ∈ ((R0, FH, BOTTOM), (R90, FN, RIGHT), (R90, FH, LEFT), (R180, FN, TOP), (R180, FV, BOTTOM), (R270, FV, LEFT))
        return tile[end, end:-1:1]
    end
end

"""
    get_encoded_sides(tile)

Return an array with all the integer-encoded sides after all the possible transformations.

The sides of the tile are given as an array with dimensions 12 x 4, 
representing all 12 transformations (4 rotations x 3 flips) and all 4 sides,
despite the fact that some transformations are redundant.

Each side is encoded into an integer, i.e. the decimal representation of
the binary number obtained when translating `"#" => true, "."` => false`.
"""
function get_encoded_sides(tile)
    sides = fill(Int16(0),4,3,4) # 4 rotations, 3 flips, 4 sides
    for s=1:4, f=1:3, r=1:4 # s=side, f=flip, r=rotation
        side = get_side(tile, r, f, s)
        sides[r,f,s] = [2^(k-1) for k=1:length(side)]' * side
    end
    return sides
end

"""
    get_tiles(list)

Return array with a binary representation of all the tiles in the `list`.

The translation of each tile is done according to `"#" => true, "."` => false`.
"""
function get_tiles(list)
    tile_side_length = findfirst(==(""), list) - 2 # discount header and empty line
    num_tiles = div(length(list)+1, tile_side_length+2) # add one since last tile is not followed by empty line
    tiles = Dict()
    tile = fill(false, tile_side_length, tile_side_length)
    for i in 1:num_tiles
        for j=1:tile_side_length
            tile[j,:] = map(==('#'), collect(list[(tile_side_length+2)*(i-1)+1+j]))
        end
        push!(tiles, parse(Int, match(r"Tile (\d*):", list[(tile_side_length+2)*(i-1) + 1])[1]) => copy(tile))
    end
    return tiles
end

"""
    get_sides_tiles(list)

Return a Dict with the array of sides of all the tiles.

The sides of each tile are assembled into an array with dimensions 12 x 4, 
representing all 12 transformations (4 rotations x 3 flips) and all 4 sides,
despite reduntant transformations.

Each side is encoded into an integer, i.e. the decimal representation of
the binary number obtained when translating `"#" => true, "."` => false`.
"""
function get_sides_tiles(list)
    tile_side_length = findfirst(==(""), list) - 2 # discount header and empty line
    num_tiles = div(length(list)+1, tile_side_length+2) # add one since last tile is not followed by empty line
    sides_tiles = Dict()
    tile = fill(false, tile_side_length, tile_side_length)

    for n in 1:num_tiles
        for i=1:tile_side_length
            tile[i,:] = map(==('#'), collect(list[(tile_side_length+2)*(n-1)+1+i]))
        end
        push!(sides_tiles, parse(Int, match(r"Tile (\d*):",
            list[(tile_side_length+2)*(n-1) + 1])[1]) => get_encoded_sides(tile))
    end
    return sides_tiles
end

"""
solve_jigsaw_combinatorics(list, flipstep=1)

Solve jigsaw by finding all possible horizontal matches and matching them vertically.

It is very expensive computationally. It is feasible for the 3x3 test puzzle
but not for the 12x12 one.

With `flipstep=2`, it skips the redundant horizontal flip `FH`, while
if `flipstep=1`, it considers `FH` and `FV`, besides no flip `FN`.
"""
function solve_jigsaw_combinatorics(list, flipstep=1)
    sides_tiles = get_sides_tiles(list)
    num_tiles = length(sides_tiles)
    side_length = isqrt(num_tiles)

    horizontal_matches = Set()
    num_matches = 0
    for c in combinations(collect(keys(sides_tiles)), side_length)
        for p in permutations(c)
            for j in 0:4^side_length-1 # vary orientations for each tile
                r = digits(j, base=4, pad=side_length) .+ fill(1,side_length)
                for l in 0:flipstep:3^side_length-1 # vary flips for each tile, if flipstep=2, skip FH=R180∘FV=FV∘R180, it should find some suitable solutions
                    f = digits(l, base=3, pad=side_length) .+ fill(1,side_length)
                    matched = true
                    for k in 1:side_length-1
                        if sides_tiles[p[k]][r[k],f[k], 1] !=
                                sides_tiles[p[k+1]][r[k+1],f[k+1], 2]
                            matched = false
                            break
                        end
                    end
                    if matched
                        push!(horizontal_matches, collect(zip(p, r, f)))
                    end
                end
            end
        end
    end

    solutions = Set()
    for c in combinations(unique(horizontal_matches), side_length)
        if length(Set([c[i][j][1] for i=1:3,j=1:3])) == num_tiles
            for p in permutations(c)
                matched = true
                for j in 1:side_length-1, k in 1:side_length           
                    if sides_tiles[p[j][k][1]][p[j][k][2],p[j][k][3],4] !=
                        sides_tiles[p[j+1][k][1]][p[j+1][k][2],p[j+1][k][3],3]
                        matched = false
                        break
                    end
                end
                if matched
                    push!(solutions, p)
                end
            end
        end
    end

    if length(solutions) == 0
        return nothing, nothing
    else
        corners_product =
            prod([first(solutions)[i][j][1] for i=[1;side_length], j=[1;side_length]])
        return solutions, corners_product
    end
end

"""
attach_tile(n, tableau, tile_key, sides_of_tiles, side_length, flipstep)

Return a new set of tableaux with all possible attachments of given tile to the given tableau.

Look for all possible attachments of tile `sides_of_tiles[tile_key]` to the
given `tableau`.

If `flipstep=2`, it skips the redundant horizontal flip `FH` of the given tile,
while if `flipstep=1`, all `FN`, `FH` and `FV` are considered.

`n` is the number of tiles already attached to the tableau. It could
"""
function attach_tile(n, tableau, tile_key, sides_of_tiles, side_length, flipstep)
    tile_sides = sides_of_tiles[tile_key]
    new_tableaux = Set()

    n = count(!=((0,0,0)), tableau) + 1
    side_length = size(tableau)[1]

    i, j = divrem(n-1,side_length) .+ (1,1)
    for r=1:4, f=1:flipstep:3 # rotations and FN and FV flips (if flipstep = 2, skip FH since FH = FV∘R180)
        side_matches = 0
        for (di, dj, s1, s2) in ((-1, 0, TOP, BOTTOM), (0, -1, LEFT, RIGHT))
            if 1 ≤ i+di ≤ side_length && 1 ≤ j+dj ≤ side_length && tableau[i+di,j+dj] != (0,0,0)
                if tile_sides[r,f,s1] == sides_of_tiles[tableau[i+di,j+dj][1]][tableau[i+di,j+dj][2],tableau[i+di,j+dj][3],s2]
                    side_matches += 1
                end
            else
                side_matches += 1
            end
        end
        if side_matches == 2
            new_tableau = copy(tableau)
            new_tableau[i,j] = (tile_key,r,f)
            push!(new_tableaux, new_tableau)
        end
    end

    return new_tableaux
end

function solve_jigsaw(list, flipstep=2, all=false)
    sides_of_tiles = get_sides_tiles(list)
    num_tiles = length(sides_of_tiles)
    side_length = isqrt(num_tiles)

    tableaux = Set()
    if all # This find all solutions accounting for symmetries (eight total)
        rrange = 1:4
        frange = 1:flipstep:3 # it suffices to consider FV, may skip FH, which is FV∘R180
    else # By symmetry, it suffices to put the 1st tile in the original position to find a solution
        rrange = 1:1
        frange = 1:1
    end
    for tk in keys(sides_of_tiles)
        for r ∈ rrange, f ∈ frange
            tableau = fill((0,0,0), side_length, side_length)
            tableau[1, 1] = (tk, r, f)
            push!(tableaux, tableau)
        end
    end
    for n in 2:num_tiles
        new_tableaux = Set()
        for tableau in tableaux
            for tk in keys(sides_of_tiles)
                if tk ∉ Set([k for (k,o) in tableau])
                    union!(new_tableaux, attach_tile(n, tableau, tk, sides_of_tiles, side_length, flipstep))
                end
            end
        end       
        tableaux = copy(new_tableaux)
    end

    if length(tableaux) == 0
        return nothing, nothing
    else
        corners_product =
            prod([first(tableaux)[i,j][1] for i=[1;side_length], j=[1;side_length]])
        return tableaux, corners_product
    end
end

# solution given in AoC's page
aoc_test_sol = [
    (1951,R0,FV) (2311,R0,FV) (3079,R0,FN);
    (2729,R0,FV) (1427,R0,FV) (2473,R270,FV);
    (2971,R0,FV) (1489,R0,FV) (1171,R180,FV);
]

# AoC solution flipped vertically
aoc_test_sol_FV = [
    (2971,R0,FN) (1489,R0,FN) (1171,R180,FN);
    (2729,R0,FN) (1427,R0,FN) (2473,R270,FN);
    (1951,R0,FN) (2311,R0,FN) (3079,R0,FV);    
] 

"""
    all_prod_tree(list, flipstep=2)

Return a set with the product of the corners of all solutions.

Aim to check whether all solutions yield the same corner's product.
"""
function all_prod_tree(list, flipstep=2)
    tableaux, = solve_jigsaw(list, flipstep)
    prods = Set()
    side_length = isqrt(length(first(tableaux)))
    for tb in tableaux
        corners_product =
            prod([tb[i,j][1] for i=[1;side_length], j=[1;side_length]])
        push!(prods, corners_product)
    end
    return prods
end

@show solve_jigsaw_combinatorics(test_list, 1)[2] == 20899048083289
@show solve_jigsaw(test_list, 1)[2] == 20899048083289
@show aoc_test_sol_FV ∈ solve_jigsaw(test_list, 1)[1]
@show aoc_test_sol ∈ solve_jigsaw(test_list, 1, true)[1]
@show length(solve_jigsaw(test_list, 2, true)[1]) == 8
@show solve_jigsaw(list, 2)[2] == 22878471088273

#= 
```julia
julia> @btime solve_jigsaw_combinatorics(test_list, 1); # no skipping FH
  983.581 ms (8762301 allocations: 498.44 MiB)

julia> @btime solve_jigsaw_combinatorics(test_list, 2); # skipping FH
  181.198 ms (2170275 allocations: 138.39 MiB)

julia> @btime solve_jigsaw(test_list, 1); # no skipping FH
  803.124 μs (8118 allocations: 505.52 KiB)

julia> @btime solve_jigsaw(test_list, 2); # skipping FH
  626.993 μs (6072 allocations: 443.05 KiB)

julia> @btime solve_jigsaw(list, 2);
  1.312 s (6099477 allocations: 1.05 GiB)
``` =#

# Part 2

# One does not need to find all solutions with `all=true` in `solve_jigsaw(list, flipstep=2, all=true)`,
# it suffices (it is faster) to find just one and then transform this one (i.e. transform 
# the whole jigsaw.

"""
    transform(tile, rotation, flip)

First rotate and then flip a `tile`, with the given `rotation` and `flip` arguments.
"""
function transform(tile, rotation, flip)
    side_length = isqrt(length(tile))

    if rotation == R0
        rotated_tile = copy(tile)
    elseif rotation == R90
        rotated_tile = [tile[j, i] for i=side_length:-1:1, j=1:side_length]
    elseif rotation == R180
        rotated_tile = [tile[i, j] for i=side_length:-1:1, j=side_length:-1:1]
    elseif rotation == R270
        rotated_tile = [tile[j, i] for i=1:side_length, j=side_length:-1:1]
    end

    if flip == FN
        transformed_tile = copy(rotated_tile)
    elseif flip == FH
        transformed_tile = [rotated_tile[i, j] for i=1:side_length, j=side_length:-1:1]
    elseif flip == FV
        transformed_tile = [rotated_tile[i, j] for i=side_length:-1:1, j=1:side_length]
    end
    return transformed_tile
end

"""
    puzzle_roughness(list)

Return the water roughness of the puzzle assembled from the `list` of tiles.
"""
function puzzle_roughness(list)
    tiles = get_tiles(list)
    num_tiles = length(tiles)
    isqrt_num_tiles = isqrt(num_tiles)
    side_length = size(first(tiles)[2])[1]
  
    monster_str = split(
"                  # 
#    ##    ##    ###
 #  #  #  #  #  #   ", '\n')
    monster_bitarray = map(x->x=='#', [monster_str[i][j] for i=1:3, j=1:20])

    solution = first(solve_jigsaw(list, 2, false)[1])
    jigsaw =
        vcat(
            [
                hcat(
                    [transform(tiles[solution[i,j][1]], solution[i,j][2], solution[i,j][3])[2:end-1,2:end-1]
                        for j=1:isqrt_num_tiles]...
                )
            for i=1:isqrt_num_tiles]...
        )
    
    isqrt_len_jigsaw = isqrt_num_tiles*(side_length-2)
    len_jigsaw = isqrt_len_jigsaw^2

    for r=1:4, f=1:2:3
        tj = transform(jigsaw, r, f)
        tj_stretched = reshape(tj, (len_jigsaw, 1))
        roughness = sum(tj)

        for j=1:isqrt_len_jigsaw-19, i=1:isqrt_len_jigsaw-2
            if tj[i:i+2, j:j+19].*monster_bitarray == monster_bitarray
                roughness -= sum((monster_bitarray) .* tj[i:i+2, j:j+19])
            end
        end
        if roughness < sum(tj)
            return roughness
        end
    end
    return nothing
end

@show puzzle_roughness(test_list) == 273
@show puzzle_roughness(list) == 1680

aoc_test_sol_mm = [ # = aoc_test_sol_FV_R90 position of the test puzzle found with the sea monster
    (1951,R90,FN) (2729,R270,FN) (2971,R270,FN);
    (2311,R270,FN) (1427,R270,FN) (1489,R270,FN);
    (3079,R90,FV) (2473,R0,FN) (1171,R270,FN);
]

function jigsaw_test(list, jigsaw_sol, inner = false)
    tiles = get_tiles(list)
    offset = inner ? 1 : 0
    isqrt_num_tiles = isqrt(length(tiles))
    return vcat(
            [
            hcat(
                [transform(tiles[jigsaw_sol[i,j][1]], jigsaw_sol[i,j][2], jigsaw_sol[i,j][3])[1+offset:end-offset,1+offset:end-offset]
                    for j=1:isqrt_num_tiles]...
            )
            for i=1:isqrt_num_tiles]...
        )
end

aoc_image_str = 
".#.#..#.##...#.##..#####
###....#.#....#..#......
##.##.###.#.#..######...
###.#####...#.#####.#..#
##.#....#.##.####...#.##
...########.#....#####.#
....#..#...##..#.#.###..
.####...#..#.....#......
#..#.##..#..###.#.##....
#.####..#.####.#.#.###..
###.#.#...#.######.#..##
#.####....##..########.#
##..##.#...#...#.#.#.#..
...#..#..#.#.##..###.###
.#.#....#.##.#...###.##.
###.#...#..#.##.######..
.#.#.###.##.##.#..#.##..
.####.###.#...###.#..#.#
..#.#..#..#.#.#.####.###
#..####...#.#.#.###.###.
#####..#####...###....##
#.##..#..#...#..####...#
.#.###..##..##..####.##.
...###...##...#...#..###"

aoc_image_sol = split(aoc_image_str, '\n')

jigsaw_sol = jigsaw_test(test_list, aoc_test_sol, true)
image_sol = [join(map(x-> x ? '#' : '.', jigsaw_sol[i,:])) for i=1:isqrt(length(jigsaw_sol))]

@show image_sol == aoc_image_sol

transformed_with_sea_monster = 
".####...#####..#...###..
#####..#..#.#.####..#.#.
.#.#...#.###...#.##.O#..
#.O.##.OO#.#.OO.##.OOO##
..#O.#O#.O##O..O.#O##.##
...#.#..##.##...#..#..##
#.##.#..#.#..#..##.#.#..
.###.##.....#...###.#...
#.####.#.#....##.#..#.#.
##...#..#....#..#...####
..#.##...###..#.#####..#
....#.##.#.#####....#...
..##.##.###.....#.##..#.
#...#...###..####....##.
.#.##...#.##.#.#.###...#
#.###.#..####...##..#...
#.###...#.##...#.##O###.
.O##.#OO.###OO##..OOO##.
..O#.O..O..O.#O##O##.###
#.#..##.########..#..##.
#.#####..#.#...##..#....
#....##..#.#########..##
#...#.....#..##...###.##
#..###....##.#...##.##.#"

# count(==('#'), transformed_with_sea_monster)

nothing
