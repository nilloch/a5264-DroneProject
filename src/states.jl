function POMDPs.stateindex(pomdp::DroneSurveillancePOMDP, s::DSState)
    if isterminal(pomdp, s)
        return length(pomdp)
    end
    nx, ny = pomdp.size 
    LinearIndices((nx, ny))[s.quad[1], s.quad[2]]
end

function state_from_index(pomdp::DroneSurveillancePOMDP, si::Int64)
    if si == length(pomdp)
        return pomdp.terminal_state
    end
    nx, ny = pomdp.size 
    s = CartesianIndices((nx, ny, nx, ny))[si]
    return DSState([s[1], s[2]])
end

# the state space is the POMDP itself
# we define an iterator over it

POMDPs.states(pomdp::DroneSurveillancePOMDP) = pomdp
Base.length(pomdp::DroneSurveillancePOMDP) = (pomdp.size[1] * pomdp.size[2]) + 1

function Base.iterate(pomdp::DroneSurveillancePOMDP, i::Int64 = 1)
    if i > length(pomdp)
        return nothing
    end
    s = state_from_index(pomdp, i)
    return (s, i+1)
end

function POMDPs.initialstate(pomdp::DroneSurveillancePOMDP)
    quad = pomdp.region_A
    nx, ny = pomdp.size
    fov_x, fov_y = pomdp.fov
    states = DSState[]
    # if pomdp.agent_policy == :restricted 
    #     xspace = fov_x:nx
    #     yspace = fov_y:ny
    #     for x in fov_x:nx
    #         for y in 1:ny
    #             agent = DSPos(x, y)
    #             push!(states, DSState(quad))
    #         end
    #     end
    #     for y in fov_y:ny
    #         for x in 1:fov_x-1
    #             agent = DSPos(x, y)
    #             push!(states, DSState(quad))
    #         end
    #     end

    # else 
    #     for x in 1:nx 
    #         for y in 1:ny
    #             if (x,y) != (1,1)
    #                 agent = DSPos(x, y)
    #                 push!(states, DSState(quad))
    #             end
    #         end
    #     end
    # end

    # probs = ones{Float64, pomdp.size[1]*pomdp.size[1]}()

    return Deterministic(DSState([1,1]))

    # probs = normalize!(ones(length(states)), 1)
    # return SparseCat(states, probs)
end
