function POMDPTools.render(pomdp::DroneSurveillancePOMDP, step;
                                viz_rock_state=true)
    nx, ny = pomdp.size
    cells = []
    @show step[:s]
    @show step[:r]
    for x in 1:nx, y in 1:ny
        ctx = cell_ctx((x,y), (nx,ny))
        clr = "white"
        if get(step, :s, nothing) != nothing
            if in_fov(pomdp, step[:s].quad, DSPos(x,y))
                clr = ARGB(0.0, 0., 1.0, 0.9)
            end
        end
        if DSPos(x, y) == pomdp.region_A 
            clr = "black"
        end

        if DSPos(x, y) == step[:s].entities[findfirst(:T .== step[:s].identities)]
            clr = "green"
        end

        if DSPos(x, y) == step[:s].entities[findfirst(:B .== step[:s].identities)]
            clr = "yellow"
        end

        if DSPos(x, y) == step[:s].entities[findfirst(:D .== step[:s].identities)]
            clr = "red"
        end

        # if DSPos(x, y) == pomdp.detector
        #     clr = "red"
        # end

        cell = compose(ctx, rectangle(), fill(clr))
        push!(cells, cell)
    end
    grid = compose(context(), linewidth(0.5mm), stroke("gray"), cells...)
    outline = compose(context(), linewidth(1mm), rectangle())

    if get(step, :s, nothing) != nothing
        quad_ctx = cell_ctx(step[:s].quad, (nx,ny))
        quad = render_quad(quad_ctx)
        # agent_ctx = cell_ctx(step[:s].agent, (nx, ny))
        # agent = render_agent(agent_ctx)
    else
        quad = nothing
        agent = nothing
        action = nothing
    end

    sz = min(w,h)
    return compose(context((w-sz)/2, (h-sz)/2, sz, sz), quad, grid, outline)
end


function cell_ctx(xy, size)
    nx, ny = size
    x, y = xy
    return context((x - 1)/nx, (ny-y)/ny, 1/nx, 1/ny)
end


function render_quad(ctx)
    center = compose(context(), ellipse(0.5, 0.5, 0.20, 0.3), fill("orange"), stroke("black"))
    ld_rot = compose(context(), circle(0.2,0.8,0.17), fill("gray"), stroke("black"))
    rd_rot = compose(context(), circle(0.8,0.8,0.17), fill("gray"), stroke("black"))
    lu_rot = compose(context(), circle(0.2,0.2,0.17), fill("gray"), stroke("black"))
    ru_rot = compose(context(), circle(0.8,0.2,0.17), fill("gray"), stroke("black"))
    return compose(ctx, ld_rot, rd_rot, lu_rot, ru_rot, center)
end

function render_agent(ctx)
    body = compose(context(), ellipse(0.5, 0.5, 0.3, 0.2), fill("red"), stroke("black"))
    head = compose(context(), circle(0.5, 0.5, 0.15), fill("black"), stroke("black"))
    return compose(ctx, head, body)
end

function in_fov(pomdp::DroneSurveillancePOMDP, quad::DSPos, s::DSPos)
    return abs(s[1] - quad[1]) < pomdp.fov[1] - 1 && abs(s[2] - quad[2]) < pomdp.fov[2] - 1
end
