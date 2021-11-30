test_str = "nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6"

function acc_till_loop(list)
    acc = 0
    i = 1
    while list[i] != "∞"
        inst, num = split(list[i], ' ')
        list[i] = "∞"
        if inst == "acc"
            acc += parse(Int, num)
            i += 1
        elseif inst == "jmp"
            i += parse(Int, num)
        elseif inst == "nop"
            i += 1
        else
            throw(ErrorException("Invalid instruction `$inst $num` at line $i"))
        end
    end
    return acc, i
end

function acc_till_loop_alt(list)
    function parse_line(line)
        inst, num_str = split(line, ' ')
        return [inst, parse(Int, num_str)]
    end
    parsed_list = parse_line.(list)
    acc = 0
    i = 1
    while parsed_list[i][1] != "∞"
        inst, num = parsed_list[i]
        parsed_list[i][1] = "∞"
        if inst == "acc"
            acc += num
            i += 1
        elseif inst == "jmp"
            i += num
        elseif inst == "nop"
            i += 1
        else
            throw(ErrorException("Invalid instruction $line at line $i"))
        end
    end
    return acc, i
end


test_list = split(test_str, '\n')
@show acc_till_loop(test_list)[1] == 5

list = readlines("day8_input.txt")
@show acc_till_loop(list)[1] == 1489

test_list = split(test_str, '\n')
@show acc_till_loop_alt(test_list)[1] == 5

list = readlines("day8_input.txt")
@show acc_till_loop_alt(list)[1] == 1489

#=
# @btime doesn't work if function modifies input, so we use `copy(list)`, but
# in this case is okay, because `@btime copy(list)` yields about 633 ns, which
# does not harm the estimate below of tens of microseconds.
```julia
julia> @btime acc_till_loop!(copy(list))
  84.806 μs (1012 allocations: 75.45 KiB)
(1489, 164)

julia> @btime acc_till_loop2(list)
  673.271 μs (5918 allocations: 346.25 KiB)
(1489, 164)
```
 =#

# Part 2

function fix_code(list)
    function parse_line(line)
        inst, num_str = split(line, ' ')
        return [inst, parse(Int, num_str)]
    end
    len = length(list)
    attempt = 0
    parsed_list = parse_line.(list)
    visited = fill(false, len)
    i = 1
    j = 1
    acc = 0
    while i ≤ len
        inst, num = parsed_list[i]
        if visited[i]          
            attempt += 1
            parsed_list = parse_line.(list)
            i = 1
            j = 1
            visited = fill(false, len)
            acc = 0
        else
            visited[i] = true
            if inst == "acc"
                acc += num
                i += 1
            elseif ((j == attempt && inst == "nop") || (j != attempt && inst == "jmp"))
                i += num
                j += 1
            else
                i += 1
                j += 1
            end
        end
    end
    return acc, i
end

test_list = split(test_str, '\n')
@show fix_code(test_list)[1] == 8

list = readlines("day8_input.txt")
@show fix_code(list)[1] == 1539

# As expected, part 2 is much slower than part 1.
# If we guess that they would make the "error" closer to the end, we could code backwards,
# but it would be much more work and memory intensive, to record where we have been and 
# how much backwards we should go each time.
#= 
```julia
julia> @btime fix_code(list)
  48.314 ms (383943 allocations: 22.19 MiB)
(1539, 602)
```
 =#

nothing