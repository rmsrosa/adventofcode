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

function get_encoded_sides(tile)
    sides = fill(Int16(0),4,3,4) # 4 rotations, 3 flips, 4 sides
    for s=1:4, f=1:3, r=1:4 # s=side, f=flip, r=rotation
        side = get_side(tile, r, f, s)
        sides[r,f,s] = [2^(k-1) for k=1:length(side)]' * side
    end
    return sides
end

function collect_tiles(list)
    """
    Tiles are collected and translated into binary arrays.
    
    According to `"#" => true, "."` => false`.
    """
    tile_side_length = findfirst(==(""), list) - 2 # discount header and empty line
    num_tiles = div(length(list)+1, tile_side_length+2) # add one since last tile is not followed by empty line
    tiles = Dict()
    tile = fill(false, tile_side_length, tile_side_length)
    for i in 1:num_tiles
        for j=1:tile_side_length
            # 
            tile[j,:] = map(==('#'), collect(list[(tile_side_length+2)*(i-1)+1+j]))
        end
        push!(tiles, parse(Int, match(r"Tile (\d*):", list[(tile_side_length+2)*(i-1) + 1])[1]) => copy(tile))
    end
    # @info "$num_tiles tiles collected"
    return tiles
end

function collect_sides_tiles(list)
    """
    Collect the sides of all the tiles.

    The sides of each tile are collected into an array with dimensions 6 x 4, 
    representing all 6 orientations and all 4 positions.

    Each side is encoded into an integer, i.e. the decimal representation of
    the binary number obtained when translating `"#" => true, "."` => false`.
    """
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
    # @info "Sides of $num_tiles tiles collected"
    return sides_tiles
end

function solve_jigsaw_combinatorics(list)
    sides_tiles = collect_sides_tiles(list)
    num_tiles = length(sides_tiles)
    side_length = isqrt(num_tiles)

    # @info "There are $(binomial(num_tiles, side_length)) tile combinations for testing horizontal matches"
    horizontal_matches = Set()
    num_matches = 0
    for c in combinations(collect(keys(sides_tiles)), side_length)
        for p in permutations(c)
            for j in 0:4^side_length-1 # vary orientations for each tile
                r = digits(j, base=4, pad=side_length) .+ fill(1,side_length)
                for l in 0:2^side_length-1 # vary flips for each tile, skip FH=R180∘FV=FV∘R180
                    f = 2*digits(l, base=2, pad=side_length) .+ fill(1,side_length)
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
    # @info "Found $(length(horizontal_matches)) horizontal match(es)"

    # @info "There are $(binomial(length(horizontal_matches), side_length)) tile combinations to check for the solution"

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
        # @info "No solution found"
        return nothing, nothing
    else
        # @info "Found $(length(solutions)) solution(s)"
        corners_product =
            prod([first(solutions)[i][j][1] for i=[1;side_length], j=[1;side_length]])
        return solutions, corners_product
    end
end

function attach_tile(n, tableau, tile_key, sides_of_tiles, side_length)
    tile_sides = sides_of_tiles[tile_key]
    new_tableaux = Set()

    i, j = divrem(n-1,side_length) .+ (1,1)
    for r=1:4, f=1:2:3 # rotations and flips (skip FH since FH = R180∘FV = FV∘R180)
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

function solve_jigsaw(list)
    sides_of_tiles = collect_sides_tiles(list)
    num_tiles = length(sides_of_tiles)
    side_length = isqrt(num_tiles)

    tableaux = Set()
    for tk in keys(sides_of_tiles)
        r=1; f=1 # By symmetry, suffices to put the 1st tile in the original position
        tableau = fill((0,0,0), side_length, side_length)
        tableau[1, 1] = (tk, r, f)
        push!(tableaux, tableau)
    end
    # @info "Starting out with $(length(tableaux)) tableaux"
    for n in 2:num_tiles
        new_tableaux = Set()
        for tableau in tableaux
            for tk in keys(sides_of_tiles)
                if tk ∉ Set([k for (k,o) in tableau])
                    union!(new_tableaux, attach_tile(n, tableau, tk, sides_of_tiles, side_length))
                end
            end
        end       
        tableaux = copy(new_tableaux)
        # @info "$(length(tableaux)) matche(s) with $n tiles"
    end

    if length(tableaux) == 0
        # @info "No solution found"
        return nothing, nothing
    else
        # @info "Found $(length(tableaux)) solution(s)"
        corners_product =
            prod([first(tableaux)[i,j][1] for i=[1;side_length], j=[1;side_length]])
        return tableaux, corners_product
    end
end

#= 
aoc_test_sol = [
    [(1951,R0,FV), (2311,R0,FV), (3079,R0,FN)]
    [(2729,R0,FV), (1427,R0,FV), (2473,R90,FV)]
    [(2971,R0,FV), (1489,R0,FV), (1171,R0,FH)]
]
=#

function all_prod_tree(list)
    """
    Return a set with the product of the corners of all solutions.

    Aim to check whether all solutions yield the same corner's product.
    """
    tableaux, = solve_jigsaw(list)
    prods = Set()
    side_length = isqrt(length(first(tableaux)))
    for tb in tableaux
        corners_product =
            prod([tb[i,j][1] for i=[1;side_length], j=[1;side_length]])
        push!(prods, corners_product)
    end
    return prods
end

@show solve_jigsaw_combinatorics(test_list)[2] == 20899048083289
@show solve_jigsaw(test_list)[2] == 20899048083289
@show solve_jigsaw(list)[2] == 22878471088273

#= 
```julia
julia> @btime solve_jigsaw_combinatorics(test_list);
  181.198 ms (2170275 allocations: 138.39 MiB)

julia> @btime solve_jigsaw(test_list);
  626.993 μs (6072 allocations: 443.05 KiB)

julia> @btime solve_jigsaw(list);
  1.312 s (6099477 allocations: 1.05 GiB)
``` =#

nothing