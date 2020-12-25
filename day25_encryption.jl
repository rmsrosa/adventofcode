# Advent of Code 2020 - Day 25

test_list= split("5764801
17807724", '\n')

list = split("11239946
10464955", '\n')

list2 = split("11239946
10464955", '\n')

function loop(subject, value = 1)
    return rem(value*subject, 20201227)
end

function get_size(public_key)
    loop_size = 0
    value = 1
    while value != public_key
        loop_size += 1
        value = loop(7, value)
    end
    return loop_size
end

function transform(public_key, loop_size)
    value = 1
    for n = 1:loop_size
        value = loop(public_key, value)
    end
    return value
end

function get_encryptionkey(list)
    card_public_key, door_public_key = parse.(Int, list)
    card_loop_size = get_size(card_public_key)
    door_loop_size = get_size(door_public_key)
    min_loop = argmin([card_loop_size, door_loop_size])
    other_public = min_loop == 1 ? door_public_key : card_public_key
    loop_size = min_loop == 1 ? card_loop_size : door_loop_size    
    key = transform(other_public, loop_size)
    return key
end

@show get_encryptionkey(test_list) == 14897079
@show get_encryptionkey(list) == 711945

nothing