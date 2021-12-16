list_test_str = split(
"1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581",
'\n'
)

list_str = let input = @__DIR__() * "/day15_input.txt"
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
    risk_map = parse.(Int, permutedims(reduce(hcat, collect.(list))))
    mem = Dict{NTuple{4, Int}, Tuple{Int, Matrix{Int}}}()
    h, w = size(risk_map)
    function risk!(mem, risk_map, n, i, m, j)
        (n, i, m, j) ∈ keys(mem) && return mem[(n, i, m, j)]
        if m == n + 1
            a = sum(risk_map[m, i:j])
            b = sum(risk_map[n, i+1:j]) + risk_map[m, j]
            risk_value = min(a, b)
            path = a ≤ b ? ( i < j ? [m i; m j] : [m j] ) : [n j; m j]
        else
            risks = Vector{Int}()
            paths = Vector{Matrix{Int}}()
            for k in i:j
                r1, p1 = risk!(mem, risk_map, n, i, m-1, k)
                r2, p2 = risk!(mem, risk_map, m-1, k, m, j)
                push!(risks, r1 + r2)
                push!(paths, [p1; p2])
            end
            k = argmin(risks)
            risk_value = risks[k]
            path = paths[k]
        end
        push!(mem, (n, i, m, j) => (risk_value, path))
        return risk_value, path
    end
    risk_value = risk!(mem, risk_map, 1, 1, h, w)
end

testit("Test Part 1", part1(list_test_str)[1], ==(40))
testit("Challenge Part 1", part1(list_str)[1], ==(447))

# Part 2

function part2(list, r)
    risk_map = parse.(Int, permutedims(reduce(hcat, collect.(list))))
    h, w = size(risk_map)
    risk_map = repeat(risk_map, r, r)
    for k in 2:r
        risk_map[1:h, (k-1)*w+1:k*w] .= mod1.(@view(risk_map[1:h, (k-2)*w+1:(k-1)*w]) .+ 1, 9)
    end
    for k in 2:r
        risk_map[(k-1)*h+1:k*h, :] .= mod1.(@view(risk_map[(k-2)*h+1:(k-1)*h, :]) .+ 1, 9)
    end
    h, w = size(risk_map)
    cum_risk = Matrix{Int}(undef, h, w)
    cum_risk[1, 1] = 0
    for j in 2:w
        cum_risk[1, j] = risk_map[1, j] + cum_risk[1, j-1]
    end
    for i in 2:h
        cum_risk[i, 1] = risk_map[i, 1] + cum_risk[i-1, 1]
    end
    for i in 2:h
        for j in 2:w
            cum_risk[i, j] = risk_map[i, j] + min(cum_risk[i-1, j], cum_risk[i, j-1])
        end
    end
    converged = false
    while !converged
        converged = true
        for j in 1:w
            for i in 1:h
                if j < w && cum_risk[i, j+1] < cum_risk[i, j] - risk_map[i, j]
                    converged = false
                    cum_risk[i, j] = cum_risk[i, j+1] + risk_map[i, j]
                end                
                if j > 1 && cum_risk[i, j-1] < cum_risk[i, j] - risk_map[i, j]
                    converged = false
                    cum_risk[i, j] = cum_risk[i, j-1] + risk_map[i, j]
                end
            end
        end
        for i in 1:h
            for j in 1:w
                if i < h && cum_risk[i+1, j] < cum_risk[i, j] - risk_map[i, j]
                    converged = false
                    cum_risk[i, j] = cum_risk[i+1, j] + risk_map[i, j]
                end
                if i > 1 && cum_risk[i-1, j] < cum_risk[i, j] - risk_map[i, j]
                    converged = false
                    cum_risk[i, j] = cum_risk[i-1, j] + risk_map[i, j]
                end                 
            end
        end
    end
    return cum_risk[end]
end

function part2_nowiggling_rm(list, r)
    risk_map = parse.(Int, permutedims(reduce(hcat, collect.(list))))
    h, w = size(risk_map)
    risk_map = repeat(risk_map, r, r)
    for k in 2:r
        risk_map[1:h, (k-1)*w+1:k*w] .= mod1.(@view(risk_map[1:h, (k-2)*w+1:(k-1)*w]) .+ 1, 9)
    end
    for k in 2:r
        risk_map[(k-1)*h+1:k*h, :] .= mod1.(@view(risk_map[(k-2)*h+1:(k-1)*h, :]) .+ 1, 9)
    end
    mem = Dict{NTuple{4, Int}, Int}()
    h, w = size(risk_map)
    function risk!(mem, risk_map, n, i, m, j)
        (n, i, m, j) ∈ keys(mem) && return mem[(n, i, m, j)]
        if m == n + 1
            a = sum(@view(risk_map[m, i:j]))
            b = sum(@view(risk_map[n, i+1:j])) + risk_map[m, j]
            risk_value = min(a, b)
        else
            risk_value = typemax(Int)
            for k in i:j
                r1 = risk!(mem, risk_map, n, i, m-1, k)
                r2 = risk!(mem, risk_map, m-1, k, m, j)
                risk_value = min(risk_value, r1 + r2)
            end
        end
        push!(mem, (n, i, m, j) => risk_value)
        return risk_value
    end
    return risk!(mem, risk_map, 1, 1, h, w)
end

function part2_nowiggling(list, r)
    risk_map = parse.(Int, permutedims(reduce(hcat, collect.(list))))
    h, w = size(risk_map)
    risk_map = repeat(risk_map, r, r)
    for k in 2:r
        risk_map[1:h, (k-1)*w+1:k*w] .= mod1.(@view(risk_map[1:h, (k-2)*w+1:(k-1)*w]) .+ 1, 9)
    end
    for k in 2:r
        risk_map[(k-1)*h+1:k*h, :] .= mod1.(@view(risk_map[(k-2)*h+1:(k-1)*h, :]) .+ 1, 9)
    end
    risk_map[1, 1] = 0
    h, w = size(risk_map)
    for j in 3:w
        risk_map[1, j] += risk_map[1, j-1]
    end
    for i in 3:h
        risk_map[i, 1] += risk_map[i-1, 1]
    end
    for i in 2:h
        for j in 2:w
            risk_map[i, j] += min(risk_map[i-1, j], risk_map[i, j-1])
        end
    end
    return risk_map[end]
end

testit("Test Part 1", part2_nowiggling_rm(list_test_str, 1), ==(40))
testit("Challenge Part 1", part2_nowiggling_rm(list_str, 1), ==(447))
testit("Test Part 2", part2_nowiggling_rm(list_test_str, 5), ==(315))

testit("Test Part 1", part2_nowiggling(list_test_str, 1), ==(40))
testit("Challenge Part 1", part2_nowiggling(list_str, 1), ==(447))
testit("Test Part 2", part2_nowiggling(list_test_str, 5), ==(315))

testit("Test Part 1", part2(list_test_str, 1), ==(40))
testit("Challenge Part 1", part2(list_str, 1), ==(447))
testit("Test Part 2", part2(list_test_str, 5), ==(315))
testit("Challenge Part 2", part2(list_str, 5), ==(2825))

# got 2835 with two implementations of the nowiggling version (just to make sure).
# Had to write a second version allowing up/down and left/right paths, to get it right.
