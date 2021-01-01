test_string = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in"


test_list = split(test_string, '\n')

list = readlines("day4_input.txt")

const PASSWDSET_NOCID = Set{String}(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"])

#= 
byr (Birth Year) - four digits; at least 1920 and at most 2002.
iyr (Issue Year) - four digits; at least 2010 and at most 2020.
eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
hgt (Height) - a number followed by either cm or in:
If cm, the number must be at least 150 and at most 193.
If in, the number must be at least 59 and at most 76.
hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
pid (Passport ID) - a nine-digit number, including leading zeroes.
 =#

# answer 1: 196
# answer 2: ??
validator = Dict(
    "byr" => x -> length(x) == 4 && prod(['0' <= c <= '9' for c in x]) && 1920 ≤ parse(Int, x) ≤ 2002,
    "iyr" => x -> length(x) == 4 && prod(['0' <= c <= '9' for c in x]) && 2010 ≤ parse(Int, x) ≤ 2020,
    "eyr" => x -> length(x) == 4 && prod(['0' <= c <= '9' for c in x]) && 2020 ≤ parse(Int, x) ≤ 2030,
    "hgt" => x -> length(x) > 2 && x[end-1:end] in Set(["cm", "in"]) && ((x[end-1:end]== "cm" && prod(['0' <= c <= '9' for c in x[1:end-2]]) && 150 ≤ parse(Int, x[1:end-2]) ≤ 193 || (x[end-1:end] == "in" && prod(['0' <= c <= '9' for c in x[1:end-2]]) && 59 ≤ parse(Int, x[1:end-2]) ≤ 76))),
    "hcl" => x -> length(x) == 7 && x[1] == '#' && prod(['0' <= c <= 'f' for c in x[2:end]]),
    "ecl" => x -> x in Set(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]),
    "pid" => x -> length(x) == 9 && prod(['0' <= c <= '9' for c in x])
)

function validate_passinfo(list; part = 1)
    pass_keys = Set{String}(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"])
    valid = 0
    nmax = length(list)
    info = ""
    for n in 1:nmax+1
        if n == nmax + 1 || list[n] == ""
            info_fields = split(info, [':', ' '])
            info_keys = Set(info_fields[1:2:end])
            if pass_keys ⊆ info_keys
                if part == 2
                    valid_keys = true
                    for j in 1:2:length(info_fields)
                        if info_fields[j] in pass_keys
                            result = validator[info_fields[j]](info_fields[j+1])
                            valid_keys *= validator[info_fields[j]](info_fields[j+1])
                        end
                    end
                    if valid_keys
                        valid += 1
                    end
                else
                    valid += 1
                end
            end
            info = ""
        else
            info *= list[n] * " "
        end
    end
    return valid
end

@show validate_passinfo(list, part=1)
@show validate_passinfo(list, part=2)

# A simpler validator after AaronRMatthis suggestions:

validator2 = Dict(
    "byr" => x -> length(x) == 4 
        && all(isdigit, x) && "1920" ≤ x ≤ "2002",
    "iyr" => x -> length(x) == 4 
        && all(isdigit, x) && "2010" ≤ x ≤ "2020",
    "eyr" => x -> length(x) == 4 
        && all(isdigit, x) && "2020" ≤ x ≤ "2030",
    "hgt" => x -> length(x) > 2 
        && ((x[end-1:end]== "cm" 
            && all(isdigit, x[1:end-2]) && 150 ≤ parse(Int, x[1:end-2]) ≤ 193
            || (x[end-1:end] == "in" && all(isdigit, x[1:end-2]) && 59 ≤ parse(Int, x[1:end-2]) ≤ 76))),
    "hcl" => x -> length(x) == 7
        && x[1] == '#' && all(c->'0'<=c<='f',x[2:end]),
    "ecl" => x -> x in Set(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]),
    "pid" => x -> length(x) == 9 && all(isdigit, x)
)

nothing

# AaronRMatthis
#= 
const dicts = map(split(read("day4_input.txt", String),"\n"=>" "), "  ") do single
    cols = split(single)
    d = Dict{String,String}()
    foreach(((key,val),)->(d[key] = val),split.(cols,':'))
    return d
end
 =#