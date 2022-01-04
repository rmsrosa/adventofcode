challenge_str = let input = @__DIR__() * "/day16_input.txt"
    isfile(input) ? readline(input) : test_str1
end

# Test function

function testit(name, result, check::Function)
    if check(result)
        @info "$name successful, with result $result"
    else
        @warn "$name failed, with result $result"
    end
end

# Parts 1 and 2

function read_packet(code, k)
    ver = parse(Int, code[k:k+2], base=2)
    id = parse(Int, code[k+3:k+5], base=2)
    k += 6
    if id == 4
        a = '1'
        b = ""
        while a == '1' 
            a = code[k]
            b *= code[k+1:k+4]
            k += 5
        end
        val = parse(Int, b, base=2)
    else
        bl = code[k] == '1' ? 11 : 15
        cl = parse(Int, code[k+1:k+bl], base=2)
        k += bl + 1
        vals = Int[]
        if bl == 11 # cl contains the number of subpackets
            for _ in 1:cl
                loc_ver, loc_val, k = read_packet(code, k) 
                ver += loc_ver
                push!(vals, loc_val)
            end
        else # cl contains the total length in bits of the subpackets
            k0 = k
            while k < k0 + cl
                loc_ver, loc_val, k = read_packet(code, k) 
                ver += loc_ver
                push!(vals, loc_val)
            end
        end
        if id == 0
            val = sum(vals)
        elseif id == 1
            val = prod(vals)
        elseif id == 2
            val = minimum(vals)
        elseif id == 3
            val = maximum(vals)
        elseif id == 5
            val = first(vals) > last(vals) ? 1 : 0
        elseif id == 6
            val = first(vals) < last(vals) ? 1 : 0
        elseif id == 7
            val = first(vals) == last(vals) ? 1 : 0
        else
            @warn "id type not implemented"
        end
    end
    return ver, val, k
end

function solve(str) # solves both parts
    code = prod(
        string.(
            digits(
                parse(
                    BigInt,
                    str,
                    base=16
                ),
                base=2,
                pad=4*length(str)
            )[end:-1:1]'
        )
    )
    k = 1
    ver, val, = read_packet(code, k)    
    return ver, val
end

testit("Test Part 1", solve("8A004A801A8002F478")[1], ==(16))
testit("Test Part 1", solve("620080001611562C8802118E34")[1], ==(12))
testit("Test Part 1", solve("C0015000016115A2E0802F182340")[1], ==(23))
testit("Test Part 1", solve("A0016C880162017C3686B18A3D4780")[1], ==(31))
testit("Challenge Part 1", solve(challenge_str)[1], ==(925))

testit("Test Part 2", solve("C200B40A82")[2], ==(3))
testit("Test Part 2", solve("04005AC33890")[2], ==(54))
testit("Test Part 2", solve("880086C3E88112")[2], ==(7))
testit("Test Part 2", solve("CE00C43D881120")[2], ==(9))
testit("Test Part 2", solve("D8005AC2A8F0")[2], ==(1))
testit("Test Part 2", solve("F600BC2D8F")[2], ==(0))
testit("Test Part 2", solve("9C005AC2F8F0")[2], ==(0))
testit("Test Part 2", solve("9C0141080250320F1802104A08")[2], ==(1))
testit("Challenge Part 2", solve(challenge_str)[2], ==(342997120375))
