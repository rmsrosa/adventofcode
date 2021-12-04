using BenchmarkTools

list_test_str = split(
"7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7",
'\n'
)

list_str = readlines("day4_input.txt")

# Part 1

list = copy(list_test_str)

function part1(list)
    numbers = parse.(Int, split(list[1], ','))
    num_boards = div(length(list) - 1, 6)
    boards = [Matrix{Int}(undef, 5, 5) for _ in 1:num_boards]
    masks = [BitMatrix(zeros(Bool, 5, 5)) for _ in 1:num_boards]

    for k in 1:num_boards
        for i in 1:5
            boards[k][i, :] .= parse.(Int, split(list[2 + 6 * (k - 1) + i]))
        end
    end

    round = 0
    winner = 0
    while winner == 0
        round += 1
        n = numbers[round]
        for k in 1:num_boards
            masks[k] .|= boards[k] .== n
            for i in 1:5
                if all(masks[k][i,:]) || all(masks[k][:,i])
                    winner = k
                end
            end
        end
    end

    return numbers[round] * sum((!).(masks[winner]) .* boards[winner])
end

#end

@info "Part 1"
@info "test:"
@show part1(list_test_str) == 4512
@info "challenge:" 
@show part1(list_str) == 10374

# Part 2

function part2(list)
    numbers = parse.(Int, split(list[1], ','))
    num_boards = div(length(list) - 1, 6)
    boards = [Matrix{Int}(undef, 5, 5) for _ in 1:num_boards]
    masks = [BitMatrix(zeros(Bool, 5, 5)) for _ in 1:num_boards]

    for k in 1:num_boards
        for i in 1:5
            boards[k][i, :] .= parse.(Int, split(list[2 + 6 * (k - 1) + i]))
        end
    end

    round = 0
    winners = Int[]
    while length(winners) < num_boards
        round += 1
        n = numbers[round]
        for k in 1:num_boards
            masks[k] .|= boards[k] .== n
            if k ∉ winners
                for i in 1:5
                    if all(masks[k][i,:]) || all(masks[k][:,i])
                        push!(winners, k)
                        break
                    end
                end
            end
        end
    end

    return numbers[round] * sum((!).(masks[winners[end]]) .* boards[winners[end]])
end

@info "Part 2"
@info "test:"
@show part2(list_test_str) == 1924
@info "challenge:" 
@show part2(list_str) !== nothing
