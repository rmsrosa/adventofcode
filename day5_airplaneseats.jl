test_string = "BFFFBBFRRR
FFFBBBFRRR
BBFFBBFRLL"

test_list = split(test_string,'\n')

list = readlines("day5_input.txt")

function seat_to_id(seat)
    seat_binary = seat
    for (k,v) in zip(('F', 'B', 'L', 'R'),('0', '1', '0', '1'))
        seat_binary = replace(seat_binary, k => v)
    end
    id = parse(Int, seat_binary, base=2)
    return id
end

function id_to_seat(id)
    seat_binary = bitstring(id)[end-9:end]
    seat_row = replace(replace(seat_binary[1:end-3], '1' => 'B'), '0' => 'F')
    seat_column = replace(replace(seat_binary[end-2:end], '1' => 'R'), '0' => 'L')
    seat = "B"^(7-length(seat_row)) * seat_row * 'L'^(3-length(seat_column)) * seat_column
    return seat
end

highest_id(list) = maximum(seat_to_id.(list))

highest_seat(list) = id_to_seat(highest_id(list))

println("Highest id of the test list: $(highest_id(test_list))")

println("Highest id of the problem list: $(highest_id(list))")

function myseat(list)
    sorted_list = sort(seat_to_id.(list))
    min_id = sorted_list[1]
    diff_list = sorted_list[2:end] - sorted_list[1:end-1]
    max, id_skip = findmax(diff_list)
    return min_id + id_skip
end

println("Your seat is $(myseat(list))")

# Answers:
# P1: 926
# P2: 657

function seat_to_id2(seat)
    f(x) = (x =='F' || x == 'L') ? 0 : 1
    return parse(Int, join(map(f, collect(seat))), base=2)
end

highest_id2(list) = maximum(seat_to_id2.(list))

println("Highest id of the problem list v2: $(highest_id(list))")

# method 1 is still better
#= 
```julia
julia> @btime highest_id(list)
  1.158 ms (13538 allocations: 747.02 KiB)
926

julia> @btime highest_id2(list)
  1.359 ms (22844 allocations: 1.21 MiB)
926
```
 =#

seatnumber(line) = mapfoldl(c->c in "BR", (x, y)->2x+y, line, init=0)

# wow, look at the differences
#= 
```julia
julia> @btime seat_to_id(line)
  1.276 μs (16 allocations: 896 bytes)
181

julia> @btime seat_to_id2(line)
  1.579 μs (27 allocations: 1.45 KiB)
181

julia> @btime seatnumber(line)
  281.837 ns (0 allocations: 0 bytes)
181
```
 =#

 # Here is a one-liner, which is actually a two-liner due to `;`, 
 # that was started by [braden](bradeneliason#2230), using
 # the one-liner `seatnumber` function, and improved upon
 # after discussions with AaronRMatthis and Tom:

function seats(list)
    S=sort(mapfoldl.(∈("BR"),(x,y)->2x+y,list))
    return S[end],S[argmax(diff(S))]+1
end

nothing

# Much faster than mine:
#= 
```julia
julia> @btime seats(list_day5)
  309.319 μs (14 allocations: 20.52 KiB)
(926, 657)
```
 =#
