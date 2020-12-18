using CSV

#list = CSV.File("day1_input.txt")
list = readlines("day1_input.txt")

function get_two(list)
    years = parse.(Int, list)
    for i in years
        for j in years
            if i+j == 2020
                return i*j
            end
        end
    end
    return "Not found"    
end

function get_two_ind(list)
    years = parse.(Int, list)
    for i in 1:length(years)
        for j in (i+1):length(years)
            if years[i]+years[j] == 2020
                return years[i]*years[j]
            end
        end
    end
    return "Not found"
end

function get_two_comprehension(list)
    years = parse.(Int, list)
    prod = [a*b for a in years for b in years if a+b==2020]
    if length(prod) > 1
        return prod[1]
    else
        return "Not found"
    end
end

function get_two_sorting(list)
    years = parse.(Int, list)
    list_inc = sort(years)
    list_dec = sort(years, rev = true)
    for a in list_inc
        for b in list_dec
            if a + b == 2020
                return a*b
            end
        end
    end
    return "Not found"
end

function findsol(list)
    years = parse.(Int, list)
    sorted=sort(years)
    sm,la=1,length(sorted)
    while sm<la
        cur=sorted[sm]+sorted[la]
        if cur<2020
            sm+=1
        elseif cur>2020
            la-=1
        else
            return sorted[sm]*sorted[la]
        end
    end
    error("dead end")
end


function get_three(list)
    years = parse.(Int, list)
    for i in years
        for j in years
            for k in years
                if i+j+k == 2020
                    return i*j*k
                end
            end
        end
    end
    return "Not found"    
end

@show get_two(list) == 355875
@show get_two_ind(list) == 355875
@show get_two_comprehension(list) == 355875
@show get_two_sorting(list) == 355875
@show findsol(list) == 355875
@show get_three(list) == 140379120

#= 
```julia
julia> @btime get_two(list)
  19.653 μs (2 allocations: 1.78 KiB)

julia> @btime get_two_ind(list);
  18.567 μs (2 allocations: 1.78 KiB)

julia> @btime get_two_comprehension(list);
  42.493 μs (5 allocations: 1.98 KiB)

julia> @btime get_two_sorting(list);
  14.270 μs (4 allocations: 5.31 KiB)

julia> @btime findsol(list);
  12.201 μs (3 allocations: 3.55 KiB)

julia> @btime get_three(list);
  437.935 μs (2 allocations: 1.78 KiB)
```
 =#
 
nothing
