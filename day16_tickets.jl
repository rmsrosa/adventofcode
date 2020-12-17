example_ticket_str = ".--------------------------------------------------------.
| ????: 101    ?????: 102   ??????????: 103     ???: 104 |
|                                                        |
| ??: 301  ??: 302             ???????: 303      ??????? |
| ??: 401  ??: 402           ???? ????: 403    ????????? |
'--------------------------------------------------------'"

test_str = "class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12"

test_str2 = "class: 0-1 or 4-19
row: 0-5 or 8-19
seat: 0-13 or 16-19

your ticket:
11,12,13

nearby tickets:
3,9,18
15,1,5
5,14,9"

test_list = split(test_str, '\n')

test_list2 = split(test_str2, '\n')

list = readlines("day16_input.txt")

function count_invalid(list)
    rules_end = findfirst(==(""), list) - 1
    rules = map(l -> split(l, r": |-| or ") |> e -> (e[1], parse(Int, e[2]), parse(Int, e[3]), parse(Int, e[4]), parse(Int, e[5])), list[1:rules_end])
    total = 0
    for i in rules_end+6:length(list)
        nums = parse.(Int, split(list[i], ','))
        for n in nums
            if !any(x -> x[2] ≤ n ≤ x[3] || x[4] ≤ n ≤ x[5], rules)
                total += n
            end
        end
    end
    return total
end

@show count_invalid(test_list) == 71
@show count_invalid(list) == 27802

function count_ticket(list)
    num_rules = findfirst(==(""), list) - 1
    rules = map(l -> split(l, r": |-| or ") |> e -> Tuple([e[1], [parse(Int, e[j]) for j in 2:5]]), list[1:num_rules])
    rule_decoder = Dict(map(x -> 2^(x[1]-1) => x[2][1], enumerate(rules)))

    # get valid tickets
    other_tickets = fill(0, length(list) - num_rules - 5, num_rules)
    num_others = 0
    for i in num_rules+6:length(list)
        m = parse.(Int, split(list[i], ','))
        ok = true
        j = 1
        while ok == true && j ≤ num_rules
            if !any(x -> x[2][1] ≤ m[j] ≤ x[2][2] || x[2][3] ≤ m[j] ≤ x[2][4], rules)
                ok = false
            end
            j += 1
        end
        if ok
            num_others += 1
            other_tickets[num_others,:] = m
        end
    end
    other_tickets = other_tickets[1:num_others, :]

    # build array with possible rules (row) for each position (column)
    ruling_off = fill(true, num_rules, num_rules)
    for k in 1:num_rules
        for j in 1:num_rules
            x = rules[j][2]
            for i in 1:num_others
                n = other_tickets[i,k]
                if !(x[1] ≤ n ≤ x[2] || x[3] ≤ n ≤ x[4])
                    ruling_off[j,k] = false
                end
            end
        end
    end

    # find order from array of possible rules
    order = fill(0, num_rules)
    for k in 1:num_rules
        sums = sum(ruling_off, dims=1)
        argmin_sum = argmax(sum(ruling_off, dims=1))[2]
        for j in 1:num_rules
            if 0 < sums[j] ≤ sums[argmin_sum]
                argmin_sum = j
            end
        end
        aux = argmax(ruling_off[:,argmin_sum])
        order[argmin_sum] = 2^(aux-1)
        ruling_off[aux,:] = fill(0, num_rules)
    end

    # get product of values with rules containing "departure"
    product = 1
    ordered_rules = Tuple(rule_decoder[k] for k in order)
    myticket = parse.(Int, split(list[num_rules+3], ','))
    for j in 1:num_rules
        if occursin("departure", ordered_rules[j])
            product *= myticket[j]
        end
    end

    return product, ordered_rules
end

@show count_ticket(test_list2)[2] == ("row", "class", "seat")
@show count_ticket(list)[1] == 279139880759

nothing

#= 
```julia
julia> @btime count_invalid(list);
  907.626 μs (1491 allocations: 440.66 KiB)

julia> @btime count_ticket(list);
  15.494 ms (214734 allocations: 3.86 MiB)
```
 =#