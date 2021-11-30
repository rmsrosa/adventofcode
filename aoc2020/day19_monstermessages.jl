test_str1 = "0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: \"a\"
5: \"b\"

ababbb
bababa
abbbab
aaabbb
aaaabbb"

test_str2 = "42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: \"a\"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: \"b\"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1

abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaaaabbaaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
babaaabbbaaabaababbaabababaaab
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba"

test_list1 = split(test_str1, '\n')

test_list2 = split(test_str2, '\n')

list = readlines("day19_input.txt")

function check_msg(list)
    emptyline = findfirst(==(""), list)
    rule_list = fill("", emptyline-2)
    messages = list[emptyline+1:end]
    for i in 1:emptyline-1
        num, rule = split(list[i], ": ")
        if num == "0"
            rule_str = "(" * rule * ")"
        else
            rule_list[parse(Int, num)] = "(" * rule * ")"
        end
    end

    while match(r"\d", rule_str) !== nothing
        m = match(r"[\(|\s](\d+)[\)|\s]", rule_str)
        rule_str = replace(rule_str, m[1] => rule_list[parse(Int,m[1])], count=1)
    end
    rule_str = replace(rule_str, " " => "")
    rule_str = replace(rule_str, "\"" => "")
    rule_str = "^" * rule_str * "\$"
    regex = Regex(rule_str)

    total = 0
    for j in 1:length(messages)
        if match(regex, messages[j]) !== nothing
            total += 1
        end
    end
    return total
end

@show check_msg(test_list1) == 2
@show check_msg(list) == 118

#= 
```julia
julia> @btime check_msg(list);
  86.697 ms (28385 allocations: 10.94 MiB)

```
 =#

function check_msg_dict_loop(list, copies)
    emptyline = findfirst(==(""), list)
    rule_dict = Dict()
    messages = list[emptyline+1:end]
    for i in 1:emptyline-1
        num, rule = split(list[i], ": ")
        if num == "8"
            push!(rule_dict, num => "((42)+)")    
            #push!(rule_dict, num => "(42 | 42 8)" # too long for regex to compile
        elseif num == "11"
            aux = "("*"(42)"^copies*"(31)"^copies*")"
            push!(rule_dict, num => aux)
            #push!(rule_dict, num => "(((42)(31))+)" # don't know why it doesn't work
            #push!(rule_dict, num => "(42 31 | 42 11 31)" # too long for regex to compile
        else
            push!(rule_dict, num => "(" * rule * ")")
        end
    end
    rule_str = rule_dict["0"]

    while match(r"[\(|\s](\d+)[\)|\s]", rule_str) !== nothing
        m = match(r"[\(|\s](\d+)[\)|\s]", rule_str)
        rule_str = replace(rule_str, m[1] => rule_dict[m[1]], count=1)
    end
    rule_str = replace(rule_str, " " => "")
    rule_str = replace(rule_str, "\"" => "")
    m = match(r"(\([ab]+\))", rule_str)
    while m !== nothing
        rule_str = replace(rule_str, m[1] => m[1][2:end-1])
        m = match(r"(\([ab]+\))", rule_str)
    end
    rule_str = replace(rule_str, "(" => "(?:")
    rule_str = "^" * rule_str * "\$"
    regex = Regex(rule_str)

    total = 0
    for j in 1:length(messages)
        if match(regex, messages[j]) !== nothing
            total += 1
        end
    end
    return total
end

@show sum([check_msg_dict_loop(test_list2, i) for i=1:4]) == 12 # 4 is how low we can get
@show sum([check_msg_dict_loop(list, i) for i=1:4]) == 246 # 4 is how low we can get

nothing