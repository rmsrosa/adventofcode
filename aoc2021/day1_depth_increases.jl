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
@info "Challenge succesful?: $(f(list) == 1655)"
@btime f($list_test)

# Part 2

g(l) = count(sum(@view(l[n+1:n+3])) > sum(@view(l[n:n+2])) for n in 1:length(l)-3)

@info "Part 2"
@info "Test succesful?: $(g(list_test) == 5)"
@info "Challenge successful?: $(g(list) == 1683)"

@btime g($list)
