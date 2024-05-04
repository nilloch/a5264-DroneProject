# using Combinatorics

function POMDPs.stateindex(pomdp::DroneSurveillancePOMDP, s::DSState)
    if isterminal(pomdp, s) 
        return length(pomdp)
    end

    if s==pomdp.reward_state
        return length(pomdp)-1
    end

    nx, ny = pomdp.size 


    return LinearIndices((nx, ny, nx, ny, nx, ny, nx, ny, 6, 2))[s.quad[1], s.quad[2],
                                                                s.entities[1][1], s.entities[1][2],  
                                                                s.entities[2][1], s.entities[2][2], 
                                                                s.entities[3][1], s.entities[3][2], 
                                                                pomdp.idPerms[s.identities],
                                                                (s.photo ? 2 : 1)]
end

#TODO How to modify this for bool in state?
function state_from_index(pomdp::DroneSurveillancePOMDP, si::Int64)
    if si == length(pomdp)
        return pomdp.terminal_state
    elseif si == length(pomdp)-1
        return pomdp.reward_state
    end
        
    nx, ny = pomdp.size 
    s = CartesianIndices((nx, ny, nx, ny, nx, ny, nx, ny, 6, 2))[si] # 2 for photo being true/false
    if s[10] == 2
        photo=true
    else # == 1
        photo=false
    end
    
    return DSState([s[1], s[2]], [DSPos([s[3], s[4]]),DSPos([s[5], s[6]]),DSPos([s[7], s[8]])], [k for (k,v) in pomdp.idPerms if v == s[9]][1], photo)
end

# the state space is the POMDP itself
# we define an iterator over it

POMDPs.states(pomdp::DroneSurveillancePOMDP) = pomdp
Base.length(pomdp::DroneSurveillancePOMDP) = ((pomdp.size[1] * pomdp.size[2])^4 * 2 * 6) + 2 #2 is for two terminal states 

function Base.iterate(pomdp::DroneSurveillancePOMDP, i::Int64 = 1)
    if i > length(pomdp)
        return nothing
    end
    s = state_from_index(pomdp, i)
    return (s, i+1)
end

function POMDPs.initialstate(pomdp::DroneSurveillancePOMDP)
    quad = pomdp.region_A
    states = DSState[]
    @show "IN INITIAL STATE"

    # This would be if we had truely "randomized" locations for entities
    nx,ny = pomdp.size
    all_possible_locs = []
    for x in 1:nx
        for y in 1:ny
            push!(all_possible_locs,DSPos(x,y))
        end
    end
    for locs in perm(all_possible_locs,3)
        for ids in keys(pomdp.idPerms)
            push!(states, DSState(quad, [locs[1], locs[2], locs[3]], ids, false))
        end
    end
    return Uniform(states)
    
    # for key in keys(pomdp.idPerms)
    #     for loc in perm(all_possible_locs,3)
    #         push!(states, DSState(quad, [loc[1], loc[2], loc[3]], key, false))
    #     end
    # end
end

# struct our_updater{M<:DroneSurveillancePOMDP} <: POMDPs.Updater
#     m::M
# end

# function POMDPs.update(up::our_updater, b::DiscreteBelief, a, o)
#     @show "in updater!"
#     return BootstrapFilter(up.m, up.m.num_particles)
# end

function POMDPs.initialize_belief(up::our_updater, d)
    # quad = pomdp.region_A
    # states = DSState[]
    # nx,ny = pomdp.size

    # all_possible_locs = []
    # for x in 1:nx
    #     for y in 1:ny
    #         push!(all_possible_locs,DSPos(x,y))
    #     end
    # end


    # for key in keys(pomdp.idPerms)
    #     for loc in perm(all_possible_locs,3)
    #         push!(states, DSState(quad, [loc[1], loc[2], loc[3]], key, false))
    #     end
    # end
    
    @show "In the initialize_belief"
    return Uniform(1:64_000)
end
