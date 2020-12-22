# Advent of Code 2020 - Day 21

test_str = "mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)"

test_list = split(test_str, '\n')

list = readlines("day21_input.txt")

function count_non_allergen_appearance(list)
    allergen_assesment = Dict{String,Set{String}}()
    ingredient_count = Dict{String,Int}()
    for i in 1:length(list)
        m = match(r"(^.*)(?: \(contains )(.*)\)$", list[i])
        ingredients = Set(String.(split(m[1], " ")))
        allergens = Set(String.(split(m[2], ", ")))
        for allergen in allergens
            if allergen in keys(allergen_assesment)
                intersect!(allergen_assesment[allergen], ingredients)
            else
                push!(allergen_assesment, allergen => copy(ingredients)) # if we don't use copy we end up referencing the same object for different keys and changing one affects the other.
            end
        end
        for ingredient in ingredients
            if ingredient in keys(ingredient_count)
                ingredient_count[ingredient] += 1
            else
                push!(ingredient_count, ingredient => 1)
            end
        end
    end

    while maximum(length.(values(allergen_assesment))) > 1
        for (k,v) in allergen_assesment
            if length(v) == 1
                for j in keys(allergen_assesment)
                    if j != k
                        setdiff!(allergen_assesment[j], v)
                    end
                end
            end
        end
    end

    total = sum([v for (k,v) in ingredient_count if k ∉ union(values(allergen_assesment)...)])

    dangerous_ingredients = ""
    for allergen in sort(collect(keys(allergen_assesment)))
        dangerous_ingredients *= unique(allergen_assesment[allergen])[1]*","
    end
    dangerous_ingredients_list = dangerous_ingredients[1:end-1]

    return total, dangerous_ingredients_list
end

@show count_non_allergen_appearance(test_list) == (5, "mxmxvkd,sqjhc,fvjkl")
@show count_non_allergen_appearance(list) == (2584, "fqhpsl,zxncg,clzpsl,zbbnj,jkgbvlxh,dzqc,ppj,glzb")