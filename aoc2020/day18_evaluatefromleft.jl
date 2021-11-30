# Advent of Code 2020 - day 18

list = readlines("day18_input.txt")

function reduce_left_first(line)
    while occursin("(", line)
        part = match(r".*(\([^\)]*\)).*", line)[1]
        line = replace(line, part => reduce_left_first(part[2:end-1]))
    end
    while occursin("+", line) || occursin("*", line)
        parts = match(r"(\d+\s[\+|\*]\s\d+)(.*)", line)
        line = string(eval(Meta.parse(parts[1]))) * parts[2]
    end
    return parse(Int, line)
end

function reduce_plus_first(line)
    while occursin("(", line)
        part = match(r".*(\([^\)]*\)).*", line)[1]
        line = replace(line, part => reduce_plus_first(part[2:end-1]))
    end
    while occursin("+", line)
        parts = match(r"([^\+]*\s|)(\d+\s\+\s\d+)(.*)", line)
        line = parts[1] * string(eval(Meta.parse(parts[2]))) * parts[3]
    end
    return eval(Meta.parse(line))
end

function evaluate_list_left_first(list)
    total = 0
    for i in 1:length(list)
        total += reduce_left_first(list[i])
    end
    return total
end

function evaluate_list_plus_first(list)
    total = 0
    for i in 1:length(list)
        total += reduce_plus_first(list[i])
    end
    return total
end

@show reduce_left_first("1 + 2 * 3 + 4 * 5 + 6") == 71
@show reduce_left_first("1 + (2 * 3) + (4 * (5 + 6))") == 51
@show reduce_left_first("2 * 3 + (4 * 5)") == 26
@show reduce_left_first("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 437
@show reduce_left_first("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 12240
@show reduce_left_first("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 13632

@show evaluate_list_left_first(list) == 1402255785165

@show reduce_plus_first("1 + 2 * 3 + 4 * 5 + 6") == 231
@show reduce_plus_first("1 + (2 * 3) + (4 * (5 + 6))") == 51
@show reduce_plus_first("2 * 3 + (4 * 5)") == 46
@show reduce_plus_first("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 1445
@show reduce_plus_first("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 669060
@show reduce_plus_first("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 23340

@show evaluate_list_plus_first(list) == 119224703255966

nothing