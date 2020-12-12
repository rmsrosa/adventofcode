test_str = "L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL"

test_list = split(test_str, '\n')

list = readlines("day11_input.txt")

#= function seating_old(list)
    n, m = length(list), length(list[1])
    extended_list = vcat("."^(m+2), ".".*list.*".", "."^(m+2))
    previous = map(line -> reshape(Array(collect(line)), (1,m+2)), fill("."^(m+2), m+2))
    next = map(line -> reshape(Array(collect(line)), (1,m+2)), extended_list)
    steps = 0
    while next != previous
        previous = deepcopy(next)
        for i in 2:n+1
            for j in 2:m+1
                if previous[i][j] == 'L' && sum(count.(==('#'), [c[j-1:j+1] for c in previous[i-1:i+1]])) == 0
                    next[i][j] = '#'
                elseif previous[i][j] == '#' && sum(count.(==('#'), [c[j-1:j+1] for c in previous[i-1:i+1]])) ≥ 5
                    next[i][j] = 'L'
                end
            end
        end
        steps += 1
    end
    return sum(count.(==('#'), next))
end =#

function seating(list)
    n, m = length(list), length(list[1])
    extended_list = vcat("."^(m+2), ".".*list.*".", "."^(m+2))
    previous = fill('.', n+2, m+2)
    next = reshape(collect(extended_list[1]), 1, m+2)
    for line in extended_list[2:end]
        next = vcat(next, reshape(collect(line), 1, m+2))
    end
    steps = 0
    while next != previous
        previous = deepcopy(next)
        for i in 2:n+1
            for j in 2:m+1
                if previous[i,j] == 'L' && count(==('#'), previous[i-1:i+1, j-1:j+1]) == 0
                    next[i,j] = '#'
                elseif previous[i,j] == '#' && count(==('#'), previous[i-1:i+1, j-1:j+1]) ≥ 5
                    next[i,j] = 'L'
                end
            end
        end
        steps += 1
    end
    return count(==('#'), next)
end

@show seating(test_list)

@show seating(list)

#= function seating_longrange_old(list)
    regex = r"^\.*#"
    n, m = length(list), length(list[1])
    extended_list = vcat("."^(m+2), ".".*list.*".", "."^(m+2))
    previous = map(line -> reshape(Array(collect(line)), (1,m+2)), fill("."^(m+2), m+2))
    next = map(line -> reshape(Array(collect(line)), (1,m+2)), extended_list)
    num_step = 0
    while next != previous
        num_step += 1
        previous = deepcopy(next)
        for i in 2:n+1
            for j in 2:m+1
                occupied =
                    occursin(regex, join([previous[i+k][j+k] for k in 1:min(n+1-i, m+2-j)])) +
                    occursin(regex, join([previous[i-k][j+k] for k in 1:min(i-1, m+2-j)])) +
                    occursin(regex, join([previous[i+k][j-k] for k in 1:min(n+2-i, j-1)])) +
                    occursin(regex, join([previous[i-k][j-k] for k in 1:min(i-1, j-1)])) +
                    occursin(regex, join([previous[k][j] for k in i+1:n+1])) + 
                    occursin(regex, join([previous[k][j] for k in i-1:-1:1])) +
                    occursin(regex, join(previous[i][j+1:m+2])) +
                    occursin(regex, join(previous[i][j-1:-1:1]))
                if previous[i][j] == 'L' && occupied == 0
                    next[i][j] = '#'
                elseif previous[i][j] == '#' && occupied ≥ 5
                    next[i][j] = 'L'
                end
            end
        end
    end
    return num_step, sum(count.(==('#'), next))
end =#

function seating_longrange(list)
    regex = r"^\.*#"
    n, m = length(list), length(list[1])
    extended_list = vcat("."^(m+2), ".".*list.*".", "."^(m+2))
    previous = fill('.', n+2, m+2)
    next = reshape(collect(extended_list[1]), 1, m+2)
    for line in extended_list[2:end]
        next = vcat(next, reshape(collect(line), 1, m+2))
    end
    num_step = 0
    while next != previous
        num_step += 1
        previous = deepcopy(next)
        for i in 2:n+1
            for j in 2:m+1
                occupied =
                    occursin(regex, join([previous[i+k,j+k] for k in 1:min(n+1-i, m+2-j)])) +
                    occursin(regex, join([previous[i-k,j+k] for k in 1:min(i-1, m+2-j)])) +
                    occursin(regex, join([previous[i+k,j-k] for k in 1:min(n+2-i, j-1)])) +
                    occursin(regex, join([previous[i-k,j-k] for k in 1:min(i-1, j-1)])) +
                    occursin(regex, join([previous[k,j] for k in i+1:n+1])) + 
                    occursin(regex, join([previous[k,j] for k in i-1:-1:1])) +
                    occursin(regex, join(previous[i,j+1:m+2])) +
                    occursin(regex, join(previous[i,j-1:-1:1]))
                if previous[i,j] == 'L' && occupied == 0
                    next[i,j] = '#'
                elseif previous[i,j] == '#' && occupied ≥ 5
                    next[i,j] = 'L'
                end
            end
        end
    end
    return num_step, sum(count.(==('#'), next))
end


@show seating_longrange(test_list)
@show seating_longrange(list)

@show seating(test_list) == 37
@show seating_longrange(test_list) == 26
@show seating(list) == 2296
@show seating_longrange(list) == 2089

nothing
