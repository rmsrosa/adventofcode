list_test_str = 
"3,4,3,1,2"

list_str = readline("day6_input.txt")

# Test function

function testit(name, result, answer)
    if result == answer
        @info "$name successful, with result $result"
    else
        @warn "$name failed, with result $result"
    end
end

# Part 1

function part1(list, n)
    school = parse.(Int, split(list, ','))
    while n > 0
        m = min(minimum(school), n - 1)
        num = count(school .== m)
        n -= m + 1
        @inbounds for j in eachindex(school)
            school[j] -= m + 1
            if school[j] < 0
                school[j] = 6
            end  
        end      
        append!(school, repeat([8], num))
    end
    length(school)
end

testit("Test Part 1", part1(list_test_str, 18), 26)
testit("Test Part 1", part1(list_test_str, 80), 5934)
testit("Challenge Part 1", part1(list_str, 80), 373378)

# Part 2

function part2(list, n)
    school = parse.(Int, split(list, ','))
    new = [count(school .== j) for j in 0:8]
    old = zeros(Int, 7)
    while n > 0
        offsprings = new[1] + old[1]
        new[1:end-1] .= @view new[2:end]
        old[1:end-1] .= @view old[2:end]
        new[end] = offsprings
        old[7] = offsprings
        n -= 1
    end
    return sum(new) + sum(old)
end

testit("Test Part 2", part2(list_test_str, 18), 26)
testit("Test Part 2", part2(list_test_str, 80), 5934)
testit("Test Part 2", part2(list_test_str, 256), 26984457539)
testit("Challenge Part 2", part2(list_str, 80), 373378)
testit("Challenge Part 2", part2(list_str, 256), 1682576647495)

function part2_alt1(list, n)
    school = parse.(Int, split(list, ','))
    bycount = [count(school .== j) for j in 0:8]
    @inbounds while n > 0
        offsprings = bycount[1]
        for j in 1:8
            bycount[j] = bycount[j+1]
        end
        bycount[7] += offsprings
        bycount[9] = offsprings
        n -= 1
    end
    return sum(bycount)
end

testit("Test Part 2 alt", part2_alt1(list_test_str, 18), 26)
testit("Test Part 2 alt", part2_alt1(list_test_str, 80), 5934)
testit("Test Part 2 alt", part2_alt1(list_test_str, 256), 26984457539)
testit("Challenge Part 2 alt", part2_alt1(list_str, 80), 373378)
testit("Challenge Part 2 alt", part2_alt1(list_str, 256), 1682576647495)

function part2_alt2(list, n)
    school = parse.(Int, split(list, ','))
    mat = zeros(Int, 9, n + 1)
    for j in 1:6
        mat[j+1, 1] = count(school .== j)
    end
    for k in 2:n+1
        mat[1:end-1, k] .= @view(mat[2:end, k-1])
        mat[7, k] += mat[1, k-1]
        mat[9, k] += mat[1, k-1]
    end
    return mat, sum(@view(mat[:, end]))
end

testit("Test Part 2 alt 2", part2_alt2(list_test_str, 18)[2], 26)
testit("Test Part 2 alt 2", part2_alt2(list_test_str, 80)[2], 5934)
testit("Test Part 2 alt 2", part2_alt2(list_test_str, 256)[2], 26984457539)
testit("Challenge Part 2 alt 2", part2_alt2(list_str, 80)[2], 373378)
testit("Challenge Part 2 alt 2", part2_alt2(list_str, 256)[2], 1682576647495)

nothing