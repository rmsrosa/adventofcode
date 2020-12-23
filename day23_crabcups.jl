# Advent of Code 2020 - Day 23

test_labels = "389125467"
labels = "198753462"

function play_crabcup(labels)
    cups = parse.(Int, collect(labels))
    for i = 1:100
        pickup = cups[2:4]
        destination = cups[1] - 1
        while destination ∈ [0; pickup]
            destination = destination ≤ 1 ? 9 : destination - 1
        end
        cups = circshift(cups, -4)
        insertion_loc = findfirst(==(destination), cups) + 1
        cups[insertion_loc+3:end] = cups[insertion_loc:end-3]
        cups[insertion_loc:insertion_loc+2] = pickup
    end
    position_cup_one = findfirst(==(1), cups)
    result = prod(string.(circshift(cups, -position_cup_one)[1:end-1]))
    return result
end

@show play_crabcup(test_labels) == "67384529"
@show play_crabcup(labels) == "62934785"

nothing
