using BenchmarkTools

list_test_str = "199
200
208
210
200
207
240
269
260
263"

list_test_str_split = split(list_test_str, '\n')
list_test = parse.(Int, list_test_str_split)

list_str = readlines("day1_input.txt")
list = parse.(Int, list_str)

# Part 1

f(l) = count(l[n+1] > l[n] for n in 1:length(l)-1)

@info "Part 1"
@info "Test successful?: $(f(list_test)== 7)"
@info "Challenge successful?: $(f(list) == 1655)"
@btime f($list_test)

# Part 2

g(l) = count(sum(@view(l[n+1:n+3])) > sum(@view(l[n:n+2])) for n in 1:length(l)-3)

@info "Part 2"
@info "Test successful?: $(g(list_test) == 5)"
@info "Challenge successful?: $(g(list) == 1683)"

@btime g($list)

# Code golfing

res = parse.(Int, readlines("day1_input.txt")) |> l -> count(l[n+3] > l[n] for n in 1:length(l)-3)
@info "Code golfing success?: $(res == 1683)"

# Performance

function h(list)
    s = 0
    for j in 1:lastindex(list)-3
        @inbounds s += ifelse(list[j+3] > list[j], 1, 0)
    end
    return s
end

@info "Performance"
@btime h($list)
