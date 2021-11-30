test_str1 = "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0"

test_str2 = "mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1"

test_list1 = split(test_str1, '\n')

test_list2 = split(test_str2, '\n')

list = readlines("day14_input.txt")

function mask_value(list)
    lines = map(x -> split(x, " = "), list)
    memory = Dict()
    mask = "X"^36
    for i in 1:length(list)
        if lines[i][1] == "mask"
            mask = lines[i][2]
        else
            value = bitstring(parse(Int, lines[i][2]))[end-35:end]
            masked_value = ""
            for j=1:36
                if mask[j] == 'X'
                    masked_value *= value[j]
                elseif mask[j] == '0'
                    masked_value *= '0'
                else
                    masked_value *= '1'
                end
            end
            if lines[i][1] in keys(memory)
                memory[lines[i][1]] = parse(Int, masked_value, base=2)
            else
                push!(memory, lines[i][1] => parse(Int, masked_value, base=2))
            end
        end
    end
    return sum(values(memory))
end

@show mask_value(test_list1) == 165
@show mask_value(list) == 15919415426101

function mask_address(list)
    lines = map(x -> split(x, " = ") |> y -> y[1] == "mask" ? (y[1], y[2]) : 
        (parse(Int,(split(y[1], r"mem\[|\]")[2])), parse(Int, y[2])), list)
    memory = Dict()
    mask = "X"^36
    for i in 1:length(list)
        if lines[i][1] == "mask"
            mask = lines[i][2]
        else
            address = bitstring(lines[i][1])[end-35:end]
            value = lines[i][2]
            masked_address = map(x -> x[1] == '0' ? x[2] : x[1], zip(mask, address))
            num_x = count(==('X'), masked_address)
            pos_x = [i for (i,c) in enumerate(masked_address) if c=='X']
            num_comb = 2^num_x
            comb = [collect(bitstring(j)[end-num_x+1:end]) for j=1:num_comb]
            for j=1:num_comb
                x_address = deepcopy(masked_address)
                x_address[pos_x] = comb[j]
                if x_address in keys(memory)
                    memory[x_address] = value
                else
                    push!(memory, x_address => value)
                end
            end
        end
    end
    return sum(values(memory))
end

@show mask_address(test_list2) == 208
@show mask_address(list) == 3443997590975

nothing