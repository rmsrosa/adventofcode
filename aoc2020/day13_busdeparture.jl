test_str = "939
7,13,x,x,59,x,31,19"

test_list = split(test_str, '\n')

list = readlines("day13_input.txt")

function departure_time(list)
    earliest = parse(Int, list[1])
    buses = map(x-> parse(Int, x), split(replace(list[2], ",x" => ""), ','))
    next_departures = Dict(map(x->(div(earliest, x) + 1 ) * x => x, buses))
    departure = minimum(keys(next_departures))
    return (departure - earliest) * next_departures[departure]
end

@show departure_time(test_list)
@show departure_time(list)
@show departure_time(test_list) == 295
@show departure_time(list) == 246

function time_stamp(line)
    buses = map(x-> parse(Int, x), split(replace(line, "x" => "-1"), ','))
    imax = argmax(buses .+ Array(0:-1:1-length(buses)))
    bmax = buses[imax]
    n = 1
    t = n*bmax + 1 - imax
    len = length(buses)
    while !all(≤(0), map(i->mod(t+i-1, buses[i]), 1:len))
        n += 1
        t = n*bmax + 1 - imax
    end
    return t
end

@show time_stamp(test_list[2])

@show time_stamp("17,x,13,19") == 3417
@show time_stamp("67,7,59,61") == 754018
@show time_stamp("67,x,7,59,61") == 779210
@show time_stamp("67,7,x,59,61") == 1261476
@show time_stamp("1789,37,47,1889") == 1202161486
#@show time_stamp(list[2]) # Too slow

# Implementing algorithm for solving linear Diophantine equations as
# explained in https://www.math.uwaterloo.ca/~wgilbert/Research/GilbertPathria.pdf
# but there is some bug. It works on all test examples, but not on the problem list.

function time_stamp_diophantine(line)
    buses = map(x-> parse(Int, x), split(replace(line, "x" => "0"), ','))
    running = [b for b=buses if b > 0]
    delays = [1-i for i=1:length(buses) if buses[i] > 0]
    offset = (mod.(running+delays,running))[2:end]
    len=length(running)
    T = fill(0, len, len)
    for i=1:len
        T[i,i] = 1
    end
    A = fill(0, len-1, len)
    for i=1:len-1
        A[i,1] = running[1]
        A[i,i+1] = - running[i+1]
    end
    R = deepcopy(A')
    for i=2:len
        while R[i,i-1] ≠ 0
            if abs(R[i-1,i-1]) > abs(R[i, i-1])
                a = div(R[i-1,i-1], R[i, i-1])
                if mod(R[i-1,i-1], R[i, i-1]) == 0
                    a -= 1                    
                end
                R[i-1,:] .-= a * R[i, :]
                T[i-1,:] .-= a * T[i,:]
            else
                a = div(R[i, i-1], R[i-1,i-1])
                R[i,:] .-= a * R[i-1,:]
                T[i,:] .-= a * T[i-1,:]
            end
        end
    end
    k = BigInt.((R[1:end-1,:]')\offset)
    k = [k; BigInt(floor(-sum([T[i,1]*k[i]/T[len,1] for i=1:len-1])))]
    n1 = sum([T[i,1]*k[i] for i=1:len])
#    while !all(>(0), [sum([T[i,j]*k[i] for i=1:len]) for j=1:len])
    while n1 < 0
        k[len] += sign(T[len,1])
        n1 = sum([T[i,1]*k[i] for i=1:len])
    end
        
    t = n1*running[1]
    return running, offset, len, A, T, R, k, n1, t
end

@show time_stamp_diophantine(test_list[2])[end] == 1068781
@show time_stamp_diophantine("7,13,x,x,59,x,31,19")[end] == 1068781
@show time_stamp_diophantine("17,x,13,19")[end] == 3417
@show time_stamp_diophantine("67,7,59,61")[end]  == 754018
@show time_stamp_diophantine("67,x,7,59,61")[end]  == 779210
@show time_stamp_diophantine("67,7,x,59,61")[end]  == 1261476
@show time_stamp_diophantine("1789,37,47,1889")[end]  == 1202161486
@show time_stamp_diophantine(list[2])[end] == 939490236001473

function test_result(line)
    running, offset, len, A, T, R, k, n1, t = time_stamp_diophantine(line)

    check = all(>(0), [sum([T[i,j]*k[i] for i=1:len]) for j=1:len])
    timings = (T'k) .* running
    check_offset = timings[2:end] - fill(timings[1], len-1)
    difference = all(==(0), check_offset + offset)
    return check, difference, T*A'==R
end

# Using the algorithm for the Chinese Remainder Theorem

function time_stamp_CRG(line)
    buses = map(x-> parse(Int, x), split(replace(line, "x" => "0"), ','))
    running = [b for b=buses if b > 0]
    offset = [mod(b+1-i,b) for (i,b) in enumerate(buses) if b>0]
    N = prod(running)
    d = div.(N,running)
    result = sum(offset .* d .* invmod.(d,running))
    return mod(result, N)
end

# There is an option to use Mods.jl package, which already has an implemention
# of the Chinese Remainder Theorem, as I learned from other Humans of Julia on 
# Discord, but it is more obscure and slower, I prefer the direct implementation
# above.

using Mods

function time_stamp_ModsCRT(line)
    buses = map(x-> parse(Int, x), split(replace(line, "x" => "0"), ','))
    running = [b for b=buses if b > 0]
    x_delays = [i-1 for i=1:length(buses) if buses[i] > 0]
    mod_prep = Mod[Mod(b,d) for (d,b) in zip(running, x_delays)]
    rem = Mods.CRT(mod_prep...)
    return modulus(rem) - rem.val
end

@show time_stamp_CRG(test_list[2]) == 1068781
@show time_stamp_CRG(list[2]) == 939490236001473
@show time_stamp_ModsCRT(test_list[2]) == 1068781
@show time_stamp_ModsCRT(list[2]) == 939490236001473

#= 
```julia
julia> @btime time_stamp_ModsCRT(list[2])
  23.110 μs (45 allocations: 5.47 KiB)
939490236001473

julia> @btime time_stamp_CRG(list[2])
  15.109 μs (24 allocations: 5.28 KiB)
939490236001473
```
 =#
 
nothing

#= 

If `x=buses` (with `x=-1` if bus = 'x'), time `t` is given by the condition
that `t+i-1` is an integer multiple of `x[i]`, i.e. `mod(t+i-1,x) == 0` or 
`mod(t, x) = 1-i` or `mod(t,x) = x-i+1`

In case `t` is not so big, we can just search for this condition
by stepping up `t` by multiples of `x[1]`. That was my first approach,
which works fast for the test set. But for the real list, that is not 
computationally feasible. So we do differently.

The conditions 

    `t + i - 1 = nᵢ xᵢ,   ∀ i=1:length(x) s.th. xᵢ > 0`

are equivalent to 
    `t = n₁x₁ = n₂x₂ - 1 = ⋯ = nᵢxᵢ - i + 1,     ∀ i, with xᵢ > 0`

And we know that `x₁ > 0`. Hence we just iterate over `i` to find

    `For i = 1:
        n₁¹ = 1
    For i = 2:
        n₂² such that n₂²x₂ - 1 = jn₁¹x₁
        n₁² = j₂²n₁¹
    For i = 3:
        n₃³ such that n₃³x₂ - 2 = jn₁²x₁
        n₁² = jn₁²
    `n₁ such that t = n₁ x₁`
    `n₂ such that n₂x₂ - 1 = `

```julia
n = 1
for i = 2:length(x)
    j = 1
    while mod(j*n*buses[i]-i+1, buses[1]) > 0
        j += 1
    end
    n *= j
end
```    

But this is slow in some cases. So we notice the problem can also be written as
    `t = 0 (mod x₁); t = x₂-1 (mod x₂); … t = xᵢ+1-i (mod xᵢ); …`

which is in the context of the Chinese Remainder Problem (see e.g. 
[Chinese Remainder Theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem))
and [Chinese Remainder Theorem with algorithm](https://shainer.github.io/crypto/math/2017/10/22/chinese-remainder-theorem.html))

An algorithm, in python, from the latter homepage, is the following

def ChineseRemainderGauss(x, a):
    """
    Return t such that mod(t,xᵢ) = aᵢ, ∀i=1,…,n, if 0 ≤ aᵢ< xᵢ 
    and the xᵢ are pairwise coprime.
    """
    from math import prod
    P = prod(x)
    result = 0

    for i in range(len(n)):
        ai = a[i]
        xi = x[i]
        bi = P // xi

        result += ai * bi * invmod(bi, xi)

    return result % P

See also https://shainer.github.io/crypto/math/2017/10/22/chinese-remainder-theorem.html

 =#