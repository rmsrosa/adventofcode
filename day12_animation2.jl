
using Plots

list = readlines("day12_input.txt")

function navigate_waypoint(list)
    instructions = map(x -> (x[1], parse(Int, x[2:end])), list)
    direction_table = Dict('N' => (0,1), 'S' => (0,-1), 'E' => (1,0), 'W' => (-1,0))   
    waypoint = (10,1)
    pos = (0,0) # (W-E, S-N) with negative values being W or S and positive, E and N
    course = [pos]
    waypoints = [waypoint]
    for (i,v) in instructions
        if i in "NESW"
            waypoint = waypoint .+ (v .* direction_table[i])
        elseif i == 'F'
            pos = pos .+ (v .* waypoint)
        elseif i == 'R'
            for j in 1:div(v, 90)
                waypoint = (waypoint[2], -waypoint[1])
            end
        elseif i == 'L'
            for j in 1:div(v, 90)
                waypoint = (-waypoint[2], waypoint[1])
            end
        end
        push!(waypoints, waypoint)
        push!(course, pos)
    end
    return course, waypoints, sum(abs.(pos))
end

course, waypoints, distance = navigate_waypoint(list)
@show distance == 138669

x = [c[1] for c=course]
y = [c[2] for c=course]
u = [w[1] for w=waypoints]
v = [w[2] for w=waypoints]
xmin = min(minimum(x), minimum(u))
xmax = max(maximum(x), maximum(u))
ymin = min(minimum(y), minimum(v))
ymax = max(maximum(y), maximum(v))

p = plot(leg = false, xlims = (xmin, xmax), ylims = (ymin, ymax), background="black", axis=[])

step = 10
trail = 100
widths = range(1, 8, length=trail)
alphas = range(0.25, 1, length=trail)
anim = Animation()
for i = 1+step:step:length(course)
    len = min(trail, i) - 1
    plot(x[1:i-len], y[1:i-len], color="deepskyblue", lw=1, alpha=0.25, leg = false,
        xlims = (xmin, xmax), ylims = (ymin, ymax), background="black",
        xticks=false, yticks=false, axis=false)
    title!("Ferry trajectory", color="gray")
    plot!(x[i-len:i], y[i-len:i], color="deepskyblue", lw=widths[end-len:end],
        alpha=alphas[end-len:end])
    plot!([x[i], x[i] + 120 * u[i]], [y[i], y[i] + 120 * v[i]], arrow=true,
        lw=2, alpha=0.4, color="yellow")
    scatter!([x[i]], [y[i]], markersize=10, color="red")
    plot!([10000, 10000 + 120 * u[i]], [60000, 60000 + 120 * v[i]], arrow=true,
        lw=2, alpha=0.4, color="yellow")
    frame(anim)
end

gif(anim, "day12_nav_anim2.gif", fps=8)

display(p)

#= @userplot LinePlot
@recipe function f(cp::LinePlot)
    origin, destiny = cp.args
    displacement = destiny .- origin
    n = 10 * sum(abs.(displacement))
    x = [origin[1] + j * displacement[1] / n for j in 1:n]
    y = [origin[2] + j * displacement[2] / n for j in 1:n]
    linewidth --> range(0, 10, length = n)
    seriesalpha --> range(0, 1, length = n)
    aspect_ratio --> 1
    label --> false
    x, y
end =#
#= 
p = plot(leg = false, xlims = (-100, 100), ylims = (-100, 100))

title!("ship trajectory and waypoints")

anim = Animation()
for i = 2:length(course)
    push!(p, Float64[course[i][1]], Float64[course[i][2]])
#for x = range(0, stop = 2π, length = 20)
#    push!(p, x, Float64[sin(x), cos(x)])
    frame(anim)
end

gif(anim, "anim_fps15.gif", fps=15)
 =#
#= 

anim = @animate for i = 2:length(course)
    if course[i] == course[i-1]

    else
        displacement = course[i] - course[i-1]
        for j = 1:sum(abs.(pos))
    lineplot((0,0), (10,5))
end =#

nothing

