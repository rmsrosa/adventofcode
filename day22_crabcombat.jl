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
        winner = argmax(cards)
        slot = winner == 1 ? N : 2*num_cards-N
        N += winner == 1 ? 1 : -1
        decks[:, 1:2*num_cards-1] = decks[:, 2:end]
        decks[winner, slot:slot+1] = sort(cards, rev=true)
    end

    winner = N == 0 ? 2 : 1
    points = sum([decks[winner, j]*(2*num_cards-j+1) for j in 1:2*num_cards])

    return points
end

@show play_combat(test_list) == 306
@show play_combat(list) == 32495
