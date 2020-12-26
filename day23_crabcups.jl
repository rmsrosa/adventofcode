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

function play_crabcup_noshift(labels)
    cups = parse.(Int, collect(labels))
    ind(i) = mod(i,1:9)
    for i = 1:100
        pickup = cups[ind.(i+1:i+3)]
        destination = cups[ind(i)] - 1
        while destination ∈ [0; pickup]
            destination = destination ≤ 1 ? 9 : destination - 1
        end
        insertion_loc = findfirst(==(destination), cups) + 1
        if ind(i+4) > insertion_loc-1
            source = cups[ind.(ind(i+4):insertion_loc+8)]
        else
            source = cups[ind(i+4):insertion_loc-1]
        end
        if ind(i+1) > insertion_loc-4
            cups[ind.(ind(i+1):insertion_loc+5)] = source
        else
            cups[ind.(ind(i+1):insertion_loc-4)] = source
        end
        cups[ind.(insertion_loc-3:insertion_loc-1)] = pickup
    end
    position_cup_one = findfirst(==(1), cups)
    result = prod(string.(circshift(cups, -position_cup_one)[1:end-1]))
    return result
end

@show play_crabcup(test_labels) == "67384529"
@show play_crabcup(labels) == "62934785"
@show play_crabcup_noshift(test_labels) == "67384529"
@show play_crabcup_noshift(labels) == "62934785"

#= 
```julia
julia> @btime play_crabcup(labels)
  278.732 μs (2984 allocations: 158.06 KiB)

julia> @btime play_crabcup_noshift(labels);
  287.510 μs (3203 allocations: 177.13 KiB)
```
 =#

function play_million_crabcup(labels, padto, rounds)
    cups = [parse.(Int, collect(labels)); collect(10:padto)]
    for i = 1:rounds
        pickup = cups[2:4]
        destination = cups[1] - 1
        while destination ∈ [0; pickup]
            destination = destination ≤ 1 ? padto : destination - 1
        end
        cups = circshift(cups, -4)
        insertion_loc = findfirst(==(destination), cups) + 1
        cups[insertion_loc+3:end] = cups[insertion_loc:end-3]
        cups[insertion_loc:insertion_loc+2] = pickup
        if mod(i,1000) == 0
            @info "i=$i"
        end
    end
    position_cup_one = findfirst(==(1), cups)
    result = prod(circshift(cups, -position_cup_one)[1:2])
    return result
end

function play_million_crabcup_noshift(labels, padto, rounds)
    cups = [parse.(Int, collect(labels)); collect(10:padto)]
    ind(i) = mod(i,1:padto)
    for i = 1:rounds
        pickup = cups[ind.(i+1:i+3)]
        destination = cups[ind(i)] - 1
        while destination ∈ [0; pickup]
            destination = destination ≤ 1 ? padto : destination - 1
        end
        insertion_loc = findfirst(==(destination), cups) + 1
        if ind(i+4) > insertion_loc-1
            source = cups[ind.(ind(i+4):insertion_loc-1+padto)]
        else
            source = cups[ind(i+4):insertion_loc-1]
        end
        if ind(i+1) > insertion_loc-4
            cups[ind.(ind(i+1):insertion_loc-4+padto)] = source
        else
            cups[ind.(ind(i+1):insertion_loc-4)] = source
        end
        cups[ind.(insertion_loc-3:insertion_loc-1)] = pickup
        if mod(i,1000) == 0
            @info "i=$i"
        end
    end
    position_cup_one = findfirst(==(1), cups)
    result = prod(cups[ind.(position_cup_one:position_cup_one+1)])
    return result
end

#@show play_million_crabcup(test_labels, 1000000, 10000000) == 149245887792
#@show play_million_crabcup(labels, 1000000, 10000000) == 693659135400 # It took about 32 hours to run!
#
# There is a pattern for the cups when they first leave the 1-9 cup group, and then again, and again,
# but I left the dumb `play_million_crabcup()` code runing and, before I implemented the pattern-tracking
# version, the dumb code eventually found the answer, after about 32 hours running, so I didn't bother
# with it anymore.
#

nothing
