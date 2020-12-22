# Advent of Code 2020 - Day 22

test_str = "Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10"

test_list = split(test_str, '\n')

list = readlines("day22_input.txt")

function play_combat(list)
    num_cards = div(length(list)+1, 2) - 2
    decks = fill(0, 2, 2*num_cards)
    decks[1, 1:num_cards] = parse.(Int, list[2:num_cards+1])
    decks[2, 1:num_cards] = parse.(Int, list[num_cards+4:end])
    N = num_cards
    while 0 < N < 2*num_cards
        cards = decks[:, 1]
        decks[:, 1:2*num_cards-1] = decks[:, 2:end]
        winner = argmax(cards)
        slot = winner == 1 ? N : 2*num_cards-N
        N += winner == 1 ? 1 : -1
        decks[winner, slot:slot+1] = [cards[winner] cards[3-winner]]
    end

    winner = N == 0 ? 2 : 1
    points = sum([decks[winner, j]*(2*num_cards-j+1) for j in 1:2*num_cards])

    return points
end

@show play_combat(test_list) == 306
@show play_combat(list) == 32495

function play_recursive_combat(list)
    num_cards = div(length(list)+1, 2) - 2
    decks = fill(0, 2, 2*num_cards)
    decks[1, 1:num_cards] = parse.(Int, list[2:num_cards+1])
    decks[2, 1:num_cards] = parse.(Int, list[num_cards+4:end])

    function playgame(decks)
        num_cards = div(size(decks)[2], 2)
        history1 = Set()
        history2 = Set()
        gamerepeated = false
        while minimum(sum(decks, dims=2)) > 0 && !gamerepeated
            if  decks[1,:] ∈ history1 || decks[2,:] ∈ history2
                gamerepeated = true
                winner = 1
            else
                push!(history1, decks[1,:])
                push!(history2, decks[2,:])
                cards = decks[:, 1]
                decks[:, 1:2*num_cards-1] = decks[:, 2:end]
                if sum(sum(decks.>0, dims=2) .≥ cards) == 2
                    new_decks = copy(decks)
                    new_decks[1,cards[1]+1:end] .= 0
                    new_decks[2,cards[2]+1:end] .= 0
                    winner = playgame(new_decks)
                else
                    winner = argmax(cards)
                end
                slot = findfirst(==(0), decks[winner,:])
                decks[winner, slot:slot+1] = [cards[winner] cards[3-winner]]
            end
        end
        return winner
    end
    
    winner = playgame(decks)

    points = sum([decks[winner, j]*(2*num_cards-j+1) for j in 1:2*num_cards])
    return points
end

@show play_recursive_combat(test_list) == 291
@show play_recursive_combat(list) == 32665

nothing

