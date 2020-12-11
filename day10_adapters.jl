test_str = "16
10
15
5
1
11
7
19
6
12
4"

test_str2 = "28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3"

test_list = split(test_str, '\n')
test_list2 = split(test_str2, '\n')

list = readlines("day10_input.txt")

function full_connection(list)
    sorted = sort(map(x -> parse(Int, x), list))
    diff = sorted[2:end] - sorted[1:end-1]
    diff1 = count(==(1), diff)
    diff1 += sorted[1] == 1 ? 1 : 0
    diff3 = length(list) - diff1 + 1
    return diff1, diff3, diff1 * diff3
end

function num_connections(list)
    sorted = sort(map(x -> parse(Int, x), list))
    diff = vcat(1, sorted[2:end] - sorted[1:end-1], 3)
    comb = 1
    local_comb_map = [1, 1, 2, 4, 7]
    i = 1
    while i ≤ length(diff) - 1
        j = findnext(x -> x==3, diff, i)
        n = j - i
        if n in 0:4
            local_comb = local_comb_map[n+1]
        else
            local_comb =  sum([binomial(n-1,k) for k in 0:n-1]) - (n-3)(n-2)/2
        end
        i = j + 1
        comb *= local_comb
    end
    return comb
end

@show full_connection(test_list)

@show full_connection(test_list2)

@show full_connection(list)

@show num_connections(test_list)

@show num_connections(test_list2)

@show num_connections(list)

test_conn = (full_connection(test_list)[3] == 35) * 
    (full_connection(test_list2)[3] == 220) *
    (full_connection(list)[3] == 2400)

test_num = (num_connections(test_list) == 8) * 
    (num_connections(test_list2) == 19208) *
    (num_connections(list) == 338510590509056)

@show test_conn

@show test_num

nothing

#= 
```julia
julia> @btime full_connection(list);
  7.722 μs (6 allocations: 4.95 KiB)

julia> @btime num_connections(list);
  11.199 μs (28 allocations: 6.81 KiB)
```
 =#

#= 
# The number of combinations for varying n:

When there are n consecutive 1's, we can't remove the last adapter, otherwise
the step will be larger than three. But we can remove each of the first n-1
adapters. We can also change any two of the first n-1 adapters. Finally, 
if n is greater than 4, we can also change any three to n-1 adapters provided
there aren't more than two consecutive removals. So, that is what we can do
    1 option of not removing anything (i.e. n-1 choose 0 options)
    n-1 choose 1 options of removing exactly one of the first n-1 adapters
    n-1 choose 2 options of removing exactly two of the first n-1 adapters
    n-1 choose 3 options of removing exactly three of the first n-1 adapters,
        discounting all the consecutive choices. The number of consecutive
        choices can be found by counting where they start. They can start at 
        the first position, then at the second, up to the n-3 position, since
        we can change the last one. Hence, we can change n-3 adapters
    n-1 choose k options of removing exactly k of the first n-1 adapters,
        discounting all the n-k consecutive choices of k adapters.
        1+2+⋯+n-3, which is
        an arithmetic progression that sum up to (n-3)(1+n-3)/2 = (n-2)(n-3)/2
    ...
    n-1 choose n-1 options of removing exactly n-1 of the first n-1 adapters,
        discounting 1 consecutive choice of n-1 options, which is thus
        n = 0, 1, 2 and 3, if n-1 ≥ 3, and is zero if n ≥ 4.

Hence, the general form is

    local_comb = sum([binomial(n-1,k) for k in 0:n-1]) - sum([n-k for k in 3:n-1])
        = sum([binomial(n-1,k) for k in 0:n-1]) - (1 + 2 + 3 + ⋯ + n - 3)
        = sum([binomial(n-1,k) for k in 0:n-1]) - (n-3)(n-2)/2
        where the last term is present only if n ≥ 4

Besides, since lower values of n should be more frequent, it is faster if we
just calculate some of them before hand, e.g. for n = 0, 1, 2, 3, 4:

    n = 0 or 1 => local_comb = 1
    n = 2 => local_comb = 2
    n = 3 => local_comb = 4
    n = 4 => local_comb = 7
    n ≥ 5 => local_comb = sum([binomial(n-1,k) for k in 0:n-1]) - (n-3)(n-2)/2

That gives me

```julia
julia> @btime num_connections(list)
  15.115 μs (45 allocations: 8.52 KiB)
```
 =#