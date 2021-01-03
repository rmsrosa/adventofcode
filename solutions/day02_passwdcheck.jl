using CSV

csvlist = CSV.File("day2_input.txt", header=false)

function check_passwd1(csvlist)
    valid = 0
    for l in csvlist
        min, max = Tuple([parse(Int, n) for n in split(l[1], '-')])
        char = l[2][1]
        passwd = l[3]
        len = length([c for c in passwd if c == char])
        if min <= len <= max
            valid += 1
        end
    end
    return valid
end

function check_passwd2(csvlist)
    valid = 0
    for l in csvlist
        pos1, pos2 = Tuple([parse(Int, n) for n in split(l[1], '-')])
        char = l[2][1]
        passwd = l[3]
        if (passwd[pos1] == char) ⊻ (passwd[pos2] == char)
            valid += 1
        end
    end
    return valid
end

println("Number of valid lines in problem 1 of day 2 = $(check_passwd1(csvlist)) from a total of $(length(csvlist))")
println("Number of valid lines in problem 2 of day 2 = $(check_passwd2(csvlist)) from a total of $(length(csvlist))")
