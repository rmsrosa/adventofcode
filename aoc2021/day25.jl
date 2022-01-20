list_test_str = split(
"v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.>",
'\n'
)

list_str = let input = @__DIR__() * "/day25_input.txt"
    isfile(input) ? readlines(input) : list_test_str
end

# Test function

function testit(name, result, check::Function)
    if check(result)
        @info "$name successful, with result $result"
    else
        @warn "$name failed, with result $result"
    end
end

# Part 1

function part1(list)
    seafloor = map(x -> Dict('.' => 0, '>' => 1, 'v' => 2)[x], permutedims(reduce(hcat, collect.(list))))

    previousseafloor = zero(seafloor)

    n, m = size(seafloor)
    k = 0
    moving = true
    while moving
        k += 1
        previousseafloor .= seafloor
        for j in 1:m, i in 1:n
            if j < m && @view(previousseafloor[i, j:j+1]) == [1, 0] 
                seafloor[i, j:j+1] .= [0, 1]
            end
            if j == m && previousseafloor[i, 1] == 0 && previousseafloor[i, m] == 1
                seafloor[i, 1:m-1:m] .= [1, 0]
            end
        end
        moving = seafloor ≠ previousseafloor
        previousseafloor .= seafloor
        for j in 1:m, i in 1:n
            if i < n && @view(previousseafloor[i:i+1, j]) == [2, 0]
                seafloor[i:i+1, j] .= [0, 2]
            end
            if i == n && previousseafloor[1, j] == 0 && previousseafloor[n, j] == 2
                seafloor[1:n-1:n, j] .= [2, 0]
            end
        end
        moving = moving || seafloor ≠ previousseafloor
    end
    return k
end

println(join([join(map(x -> Dict(0 => '.', 1 => '>', 2 => 'v')[x], row)) for row in eachrow(seafloor)], '\n'))

testit("Test Part 1", part1(list_test_str), ==(58))
testit("Challenge Part 1", part1(list_str), ==(400))

# There is no part 2