list_test_str = split(
    "00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010"
)

list_str = readlines("day3_input.txt")

function part1(list)
    mat = reshape([c=='1' for l in list for c in l], length(list[1]), :)
    bin = sum(mat, dims=2) .> div(size(mat, 2), 2)
    gamma = sum(bin[end-j]*2^j for j in 0:length(bin)-1)
    eps = 2^size(mat, 1) - 1 - gamma
    return gamma * eps
end

@info "Part 1"
@info "Test"
@show part1(list_test_str) == 198
@info "Challenge"
@show part1(list_str) == 1131506

# Part 2

function part2(list)
    mat = reshape([c=='1' for l in list for c in l], length(list[1]), :)

    j = 1
    cmat = copy(mat)
    while j ≤ size(mat,1) && size(cmat,2) > 1
        num_ones = sum(cmat[j,:])
        bit = sum(cmat[j,:]) ≥ size(cmat,2) - num_ones
        inds = [i for i in 1:size(cmat,2) if cmat[j,i] == bit]
        cmat = cmat[:,inds]
        j += 1
    end

    oxygen = sum([cmat[end+1-j]*2^(j-1) for j in eachindex(cmat)])

    j = 1
    cmat = mat[:,:]
    while j ≤ size(mat,1) && size(cmat,2) > 1
        num_ones = sum(cmat[j,:])
        bit = sum(cmat[j,:]) ≥ size(cmat,2) - num_ones
        inds = [i for i in 1:size(cmat,2) if cmat[j,i] != bit]
        cmat = cmat[:,inds]
        j += 1
    end

    scrubber = sum([cmat[end+1-j]*2^(j-1) for j in eachindex(cmat)])

    return oxygen * scrubber
end

@info "Part 2"
@info "Test"
@show part2(list_test_str) == 230
@info "Challenge"
@show part2(list_str) == 7863147

nothing