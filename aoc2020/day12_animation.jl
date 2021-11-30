
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

title!("Ferry trajectory", color="gray")

step = 10
anim = Animation()
for i = 1+step:step:length(course)
    plot!(x[i-step:i], y[i-step:i], color="deepskyblue", lw=2, axis=false)
    frame(anim)
end

gif(anim, "day12_nav_anim.gif", fps=15)

display(p)

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

gif(anim, "day12_nav_anim_trail.gif", fps=8)


nothing

