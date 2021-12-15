using SparseArrays

list_test_str = split(
"6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5",
'\n'
)


list_str = let input = @__DIR__() * "/day13_input.txt"
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
    n = findfirst(==(""), list)
    dots = fill(0, n-1, 2)
    folds = fill(0, length(list)-n, 2)
    for (i, s) in enumerate(@view(list[1:n-1]))
        dots[i, :] .= parse.(Int, split(s, ','))
    end
    for (i, s) in enumerate(@view(list[n+1:end]))
        folds[i, 1] = s[12] == 'x' ? 1 : 2
        folds[i, 2] = parse(Int, s[14:end])
    end
    fd = folds[1, 1]
    fl = folds[1, 2]
    for dt in eachrow(dots)
        if dt[fd] > fl
            dt[fd] = 2 * fl - dt[fd]
        end
    end
    return length(unique(eachrow(dots)))
end

testit("Test Part 1", part1(list_test_str), ==(17))
testit("Challenge Part 1", part1(list_str), ==(712))

# Part 2

function part2(list)
    n = findfirst(==(""), list)
    dots = fill(0, n-1, 2)
    folds = fill(0, length(list)-n, 2)
    for (i, s) in enumerate(@view(list[1:n-1]))
        dots[i, :] .= parse.(Int, split(s, ','))
    end
    for (i, s) in enumerate(@view(list[n+1:end]))
        folds[i, 1] = s[12] == 'x' ? 1 : 2
        folds[i, 2] = parse(Int, s[14:end])
    end
    m = maximum(dots, dims=1)
    for i in 1:size(folds, 1)
        fd = folds[i, 1]
        fl = folds[i, 2]
        for dt in eachrow(dots)
            if dt[fd] > fl
                dt[fd] = 2 * fl - dt[fd]
            end
        end
        m[fd] = fl
    end
    nx, ny = m
    v = spzeros(Int, ny, nx)
    for (j, i) in eachrow(dots)
        v[i+1, j+1] = 1
    end
    return v
end

v_test = part2(list_test_str)
display(v_test) # output O
v = part2(list_str)
display(v) # output BLHFJPJF
