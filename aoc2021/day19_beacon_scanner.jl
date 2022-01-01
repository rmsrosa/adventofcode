list_test = split(
"--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14",
'\n'
)

list_challenge = let input = @__DIR__() * "/day19_input.txt"
    isfile(input) ? readlines(input) : list_test_1
end

# Test function

function testit(name, result, check::Function)
    if check(result)
        @info "$name successful, with result $result"
    else
        @warn "$name failed, with result $result"
    end
end

# Part 1

orientations = let
    rot90 = [
        [0 -1 0; 1 0 0; 0 0 1],
        [0 0 -1; 0 1 0; 1 0 0],
        [1 0 0; 0 0 -1; 0 1 0]
    ]
    Set(
        g1^n * g2^m for g1 in rot90 for g2 in rot90 for n in 0:3 for m in 0:3
    )
end

function get_scanners(list)
    breaks = [0; findall(==(""), list); length(list)+1]
    data = [list[breaks[i]+2:breaks[i+1]-1] for i in 1:length(breaks)-1]
    scanners = permutedims.(
        eval.(
            Meta.parse.(  
                '[' .* [join(replace.(d, "," => " "), "; ") for d in data] .* ']'
            )
        )
    )
    return scanners
end

function part1(list)
    scanners = get_scanners(list)
    positioned = fill(false, length(scanners))
    translations = fill(zeros(Int, 3), length(scanners))
    transforms = fill([1 0 0; 0 1 0; 0 0 1], length(scanners))
    positioned[1] = true
    printstyled("positioned scanner $(k2-1)\n", color=:green)
    while any(.!positioned)
        printstyled("round\n", color=:yellow)
        for k1 in 1:length(scanners), k2 in 1:length(scanners)
            if positioned[k1] && !positioned[k2]
                sck1 = transforms[k1] * scanners[k1] .+ translations[k1]
                for g in orientations
                    sck2 =  g * scanners[k2]
                    us = [rk1 - rk2 for rk1 in eachcol(sck1) for rk2 in eachcol(sck2)]
                    uc = Dict(u => count(map(==(u), us)) for u in unique(us)) # could use StatsBase.countmap, but I want to avoid non-Standard packages
                    if any(≥(12), values(uc))
                        u = first(k for (k,v) in uc if v ≥ 12)
                        printstyled("positioned scanner $(k2-1)", color=:green)
                        printstyled(" ($(count(.!positioned)) scanners left)\n", color=:red)
                        positioned[k2] = true
                        translations[k2] = u
                        transforms[k2] = g
                    end
                end
            end
        end
    end

    positioned_scanners = [
        transforms[k] * scanners[k] .+ translations[k] for k in 1:length(scanners)
    ]
    return positioned, translations, transforms, scanners, positioned_scanners, length(Set(eachcol(reduce(hcat, positioned_scanners))))
end

testit("Test Part 1", part1(list_test)[end], ==(79))

testit("Challenge Part 1", part1(list_challenge)[end], ==(442))

# Part 2

function part2(list)
    _, translations, _ = part1(list)
    return maximum(sum(abs, r1 - r2) for r1 in translations for r2 in translations)
end

testit("Test Part 2", part2(list_test), ==(3621))
testit("Challenge Part 2", part2(list_challenge), ==(11079))
