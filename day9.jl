test_str = "35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576"

test_list = split(test_str, '\n')

list = readlines("day9_input.txt")

function check(sublist)
    sublen = length(sublist)
    last = sublist[end]
    for j in 1:sublen-2
        for k in j+1:sublen-1
            if sublist[j] + sublist[k] == last
                return true
            end
        end
    end
    return false
end

function invalid(preamble, list)
    int_list = map(x-> parse(Int, x), list)
    for i in preamble+1:length(int_list)
        if !check(int_list[i-preamble:i])
            return i, int_list[i]
        end
    end
    return nothing, nothing
end

@show invalid(5, test_list)
@show invalid(25, list)

function contiguous(preamble, list)
    i_inv, num_inv = invalid(preamble, list)
    int_list = map(x-> parse(Int, x), list)
    len = length(list)
    for i in 1:len
        j = i
        sublistsum = int_list[i]
        while sublistsum <= num_inv
            if sublistsum == num_inv
                return minimum(int_list[i:j]) + maximum(int_list[i:j])
            end
            j += 1
            sublistsum += int_list[j]
        end
    end
end

@show contiguous(5, test_list)
@show contiguous(25, list)

nothing

# I restart counting with the second counter j every time I step up the
# first counter i, but that is indeed a waste. I could just subtract the
# first value in the sublist
