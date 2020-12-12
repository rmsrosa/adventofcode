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

function h(list)
    n, m = length(list), length(list[1])
    next = fill('.', n+2,m+2)
    for i in 2:n+1 # looping over all strings
        for (j, c) in enumerate(list[i-1]) # looping over all chars in a string
            next[i, j+1] = c
        end
    end
    return next
end

function f(list)
    n, m = length(list), length(list[1])
    extended_list = vcat("."^(m+2), ".".*list.*".", "."^(m+2))
    next = reshape(collect(extended_list[1]), 1, m+2)
    for line in extended_list[2:end]
        next = vcat(next, reshape(collect(line), 1, m+2))
    end
    return next
end

function seating(list)
    n, m = length(list), length(list[1])
    extended_list = vcat("."^(m+2), ".".*list.*".", "."^(m+2))
    previous = fill('.', n+2, m+2)
    next = fill('.', n+2,m+2)
    for i in 2:n+1
        for (j, c) in enumerate(list[i-1])
            next[i, j+1] = c
        end
    end    
    steps = 0
    while next != previous
        previous = deepcopy(next)
        for j in 2:m+1
            for i in 2:n+1
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

function seating_longrange(list)
    regex = r"^\.*#"
    n, m = length(list), length(list[1])
    extended_list = vcat("."^(m+2), ".".*list.*".", "."^(m+2))
    previous = fill('.', n+2, m+2)
    next = fill('.', n+2,m+2)
    for i in 2:n+1
        for (j, c) in enumerate(list[i-1])
            next[i, j+1] = c
        end
    end    
    num_step = 0
    while next != previous
        num_step += 1
        previous = deepcopy(next)
        for j in 2:m+1
            for i in 2:n+1
                if previous[i,j] != '.'
                    occupied =
                        occursin(regex, join([previous[i+k,j+k] for k in 1:min(n+1-i, m+2-j)])) +
                        occursin(regex, join([previous[i-k,j+k] for k in 1:min(i-1, m+2-j)])) +
                        occursin(regex, join([previous[i+k,j-k] for k in 1:min(n+2-i, j-1)])) +
                        occursin(regex, join([previous[i-k,j-k] for k in 1:min(i-1, j-1)])) +
                        occursin(regex, join(previous[i+1:n+1,j])) + 
                        occursin(regex, join(previous[i-1:-1:1,j])) +
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
    end
    return sum(count.(==('#'), next))
end

@show seating_longrange(test_list)
#@show seating_longrange(list)

@show seating(test_list) == 37
@show seating_longrange(test_list) == 26
@show seating(list) == 2296
#@show seating_longrange(list) == 2089

nothing
