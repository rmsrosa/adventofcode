#* # Advent of Code 2021 - Day 24 (solved on 16 jan 2022)

#* ## Introdution

#* This puzzle is one of those where a direct, naive implementation would take a long time to run. In principle, we need to check combinations of 14 digits from 1 to 9, i.e. 9^14 combinations. Even if each combination would take just 1 nanosecond (10^-9 seconds), this would amount, in the worst case, to about 22877 seconds, or 6 hours.

#* The fastest I could get for each check, by translating the set of 252 instructions to a pure julia function (actually a bit less due to some no-ops or redundancies), was about 20 nanoseconds on a new Mac M1, which would lead to a total of 120 hours.

#* The actual solution for part 1 has `9` as the first digit and `1` as the second, which means I would actually "just" need to check (going down each digit from `9` to `1`) 9^13 digits before finding the solution, but that still amounts to 14 hours. The second part would take much longer, because the natural path is to start from `1`, but the actual solution turned out to also have `9` as the first digit.

#* I could have just waited, but that would be no fun and it would require running the code on my machine for days, eating up resources, and without actually knowing it would work. So, we need some sort of dynamic programming to break this down. The problem is that things get messy quickly. Let us get to it.

#* ## The puzzle

#* We are given a set of instructions operating on four variables named `w`, `x`, `y`, `z`, and with 14 integer input data with unknown values in the range `1` to `9`.

#* The instructions are either the unary operation of input of new data to one of the variables, or one of the diadic operations `add`, `mul`, `div`, `mod`, `eql`, where the last one is to check for equality.

#* The diadic operations are always of the form `op a b`, which means `a = op(a, b)`, where `op` is one of the above diadic operations.

#* In my case, the input instructions are always of the form `inp w`, i.e.always reading to variable `w`. And the equality check appears in sequence, always `eql x w` followed by `eql x 0`. In effect, this is to check whether `x ≠ w` and store the result in `x` as `0` or `1`, i.e. the two equality boil down to a single `x = 1 * (x ≠ w)` instruction. Knowing that helps to simplify stuff.

#* Given a set of 14 input data, the sequence of operations leads to a final value for the variables `w`, `x`, `y`, and `z`. But the challenge is not to compute the result for a given input. The challenge, in part 1, is to find the largest valid input. A *valid* input is one which ends with `z = 0`.

#* ## The approach to solve it

#* The naive approach would be to start with the highest possible input `9999999999999`, down to the smallest one `11111111111111`, stopping at the first valid input. As explained in the Introdution, this would take a rather long time.

#* So we need somehow to keep the input as unknowns and track the conditions that lead to `w = 0` at the end.

#* The way I thought for solving this was to use symbolic computation. The right package for that seemed to be `Symbolics.jl`. But this is still in its early stages. It is not complete. It does accept `mod` and `rem`, but there is no `div`. And, worst, there is no simplification implemented for `mod` and `rem`. I decided to have a look at it and see how I could add them. It turned out `Symbolics.jl` uses `SymbolicUtils.jl` under the hood, and it is there where the simplification magic occurs. It is in `SymbolicUtils.jl` that this core stuff is/should be implemented.

#* I looked at the code of `SymbolicUtils.jl` and it seemed not too difficult to implement what I needed. After checking with the developers on Slack, I went ahead and started to make this happen. This became PR [JuliaSymbolics/SymbolicUtils.jl PR: adds div and simplifications for div, mod and rem #418](https://github.com/JuliaSymbolics/SymbolicUtils.jl/pull/418).

#* This PR adds `div` and adds a bunch of simplification rules for them, like `div(x, 1) = x`, `mod(x, 1) = 0`, `div(x, -1) = -x`, `mod(x, -1) = 0`, `div(n * x, m) = div(n, m) * x + div(x - div(n, m) * x, m)`, and so one.

#* This, however, is still not enough. The symbolic expressions stored in the variables still become gigantic and unmannable. We need more simplifications.

#* The last piece of symbolics, then, is to take advantage of the fact that the input is between `1` and `9` and that, at least in my case, the `div` and `mod` operations come either dividing by `1` (which the implemented rules above take care) or by `26`. Hence, something like `div(n + i, m)` is zero when `i` is an unkown input data between `1` and `9`, `0 ≤ rem(n, m) ≤ m - 9`, and `m = 26`. Similarly, `mod(i + n, m)` reduces to `mod(n, m) + i`.

#* We, therefore, implement these rules, but these are implemented here in this script, not in SymbolicUtils.jl, because this is specific to this problem, not general facts for arbitrary symbolic variables.

#* Finally, equalities like `i1 == m`, `n + i1 == m`, and `n + i1 == i2` would certainly vanish if, respectively, `m ≥ 10`, `m - n ≥ 10`, `n ≥ 10`. We implement these rules here, as well.

#* With that at hand, for each given operation, we apply the simplifications to reduce the expressions, and go on.

#* The dynamic programming part comes when one of the equality operations yield two possible outcomes (1 or 0, i.e. true or false), depending on the data. When this happen, we branch the code, one for each possibility, keeping track of the condition taken.

#* At the end, we check whether `w = 0` or not. If not, we return `nothing` and the branch is discarded. If `w = 0`, the set of conditions for that corresponding branch is returned.

#* It could happen that more than one set of conditions are valid, but it turns out there is only one valid combination. This comes out as a set of linear equations involving the 14 input data. We this set of conditions at hand, we look for the highest (for part 1) or lowest (for part 2) combination satisfying the conditions. These are the solutions.

#* ## The implementation

#* ### Adding SymbolicUtils
#*
#* As mentioned above, we need `SymbolicUtils.jl`, but we need the version in the PR, which, at the moment, has not been merged yet. So, if you want to attempt this, be sure you add the PR version to your environment, or rather the branch `divmodrem` from my fork of `SymbolicUtils.jl`.

#* You can do that with
#* ```julia
#* julia> using Pkg
#*
#* julia> Pkg.add(url="https://github.com/rmsrosa/SymbolicUtils.jl", rev="divmodrem")
#* ```

#* ### Importing SymbolicUtils
#*
#* With the package added, we load it and import some non-exported functions which will be needed to add the rules that take advantage of the `1-9` range of the input data.

using SymbolicUtils
import SymbolicUtils: Chain, Sym, is_literal_number, _isnonzerointeger, ifelse

#* ### Reading the commands
#*
#* The puzzle input is different for each user. You can download it once you log in to the AoC site. My input has been downloaded to a local file. We can load it as follows

list = readlines(@__DIR__() * "/day24_input.txt") 

#* ### The commands in julia
#*
#* The diadic commands are `add`, `mul`, `div`, `mod`, and `eql`.
#*
#* They correspond to `+`, `*`, `div`, `mod`, and `==` in julia, so we just
#* write a dictionary associating their (string) name to their corresponding (julia) operator. (It would be better to make them constant, for performance issues, but this is not a critical thing here, so we don't bother).

OP = Dict(
    "add" => +,
    "mul" => *,
    "div" => div,
    "mod" => mod,
    "eql" => ==
)

#* As mentioned above, since the input is between 1 and 9, we add extra rules to simplify `div(i + n, m)` and `mod(i + n, m)` when `i` is an input and `n` and `m` are integers with `n + 9 < m`. And also to evaluate `i1 + n == i2` to false, when `n ≥ 9`, and the like. This is done as follows. (Check out [JuliaSymbolics/SymbolicUtils.jl](https://symbolicutils.juliasymbolics.org) in case you are interested in learning how these work.)

r0 = Chain([
    @rule div(~i::Sym, ~m::_isnonzerointeger) => ifelse(~m > 9, 0, nothing)

    @rule div(~n::is_literal_number + ~i, ~m::_isnonzerointeger) => ifelse(0 ≤ mod(~n, ~m) < ~m - 9, div(~n, ~m), nothing)

    @rule div(~n::is_literal_number + ~k::is_literal_number * ~i, ~m::_isnonzerointeger) => ifelse(0 ≤ mod(~n, ~m) < ~m - 9, div(~n, ~m) + div(mod(~n, ~m) + ~k * ~i, ~m), nothing)

    @rule div(~n::is_literal_number + ~e::Sym + ~m::_isnonzerointeger * ~i, ~m) => ~i2 + div(~n + ~e, ~m)

    @rule mod(~i::Sym, ~m::_isnonzerointeger) => ifelse(~m > 9, ~i, nothing)

    @rule mod(~n::is_literal_number + ~i, ~m::_isnonzerointeger) => ifelse(0 ≤ mod(~n, ~m) < ~m - 9, mod(~n, ~m) + ~i, nothing)

    @acrule ~i::Sym == ~n::is_literal_number => ifelse(~n > 9 || ~n < 1, 0, nothing)

    @acrule ~i::Sym == ~n::is_literal_number + ~j::Sym => ifelse(~n ≥ 9 || ~n ≤ -9, 0, nothing)
])

r = Chain([
    @rule ~x => r0(~x)
    @rule +(~~xs) => sum(r0.(~~xs))
])

srs = r ∘ simplify

#* Perusing the data, we see, by the fourth of fifth input, that there will be a branch depending on the data. More precisely, the value of `x` will be either `0` or `i`, depending on the difference between two previous input and a given integer in the instructions. This will have further branches later on. Hence, we will need some form of dynamic programming structure to keep track of that. We will keep a simple nested vector of vectors structure for that, so we can simply push! new branches to it.

#* We define a vector of Symbolic integers. In the challenge, there will be 14 integer inputs, but it makes no effect writing i[1:14].

#* All four variables start with 0.

#* and the input starts with 1, but we initialize it to zero and add 1 when a new input is needed

#* Now the idea is to loop through the whole `list` of instructions and execute the commands, branching when needed. For that, we keep track of the line number we are in the `list` of commands, starting at `0` and increasing it by one before each command is read from the `list`.

function state(conditions, u, list, i, j, k)
    while j < length(list)
        j += 1
        mc = match(r"([a-z]{3}) ([w-z])(?: ([w-z]|-?\d*))?", list[j]).captures
        # Int('w') is 119, so by subtracting 118 we get
        # w => 1, x => 2, y => 3, z => 4
        idx = Int(only(mc[2])) .- 118 
        if mc[1] == "inp"
            k += 1
            u[idx] = i[k]
        else
            aux = mc[3] ∈ ("w", "x", "y", "z") ? u[Int(only(mc[3])) - 118] : parse(Int, mc[3])
            operator = OP[mc[1]]
            u[idx] = srs(1*operator(u[idx], aux))
        end
        # In my case, at least, conditionals always appear as the
        # two consecutive commands `eql x w`, `eql x 0`.
        # This can be thought of a unique `x = x ≠ w` instruction.
        # When `x` and `w` are numeric, or when it is impossible for 
        # them to be equal, since the input is restricted to the range 
        # `1-9`, the direct calculation or the symbolic reductions will
        # resolve the value of `x` to either `0` or `1`. Otherwise, `x`
        # will be a symbolic condition depending on the data.
        # We check when this is the case and bifurcate the code
        # depending on whether the condition is met or not.
        # When doing so, we record, in the `conditions` vector, the
        # corresponding condition chosen for each branch.
        # We check that by checking when the command is `eql x w` and when `x == w` is not a literal number. This dynamic programming returns
        # the set of conditions needed to have (or possibly have) `w == 0`
        # at the end. When `w ≠ 0` at the end, the branching returns 
        # `nothing` and the set of conditions on that route is discarded.
        
        if list[j] == "eql x w" && !is_literal_number(u[idx])
            utrue = copy(u)
            utrue[idx] = 1
            ufalse = copy(u)
            ufalse[idx] = 0
            res_true = state([conditions; u[idx]], utrue, list, i, j, k)
            res_false = state([conditions; replace("$(u[idx])", "==" => "≠")], ufalse, list, i, j, k)
            if res_true === res_false === nothing
                return nothing
            elseif res_true === nothing
                return res_false
            elseif res_false === nothing
                return res_true
            else
                return [res_true; res_false]
            end
        end
    end
    # Well, we could have ended with `w` as a combination of inputs
    # that could vanish depending on the choice of the input, but this
    # actually doesn't happen (they are all - except one - a linear 
    # combination of the input data with positive coefficients) and
    # it suffices to check whether `w == 0`.
    return is_literal_number(u[end]) && u[end] == 0 ? conditions : nothing
end

function solve(list)
    i = @syms i1::Integer i2::Integer i3::Integer i4::Integer i5::Integer i6::Integer i7::Integer i8::Integer i9::Integer i10::Integer i11::Integer i12::Integer i13::Integer i14::Integer

    u = Vector{Any}([0, 0, 0, 0]) # slots w, x, y, z respectively
    j = 0
    k = 0
    conditions = state([], u, list, i, j, k)
    return conditions
end

#* Finally, we call the main loop
conditions = solve(list)

#= 
Result:
 "(i3 - 7) == i4"
 "(1 + i5) == i6"
 "(5 + i8) == i9"
 "i10 == i11"
 "(8 + i7) == i12"
 "(7 + i2) == i13"
 "(i1 - 8) == i14"

The largest possible solution of this system gives us the answer to part 1:
92928914999991

The smallest possible solution of this system gives us the answer to part 2:
91811211611981

=# 

