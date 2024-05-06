# using Combinatorics

function POMDPs.stateindex(pomdp::DroneSurveillancePOMDP, s::DSState)
    if isterminal(pomdp, s) 
        return length(pomdp)
    end

    nx, ny = pomdp.size 

    #TODO: change 6 to function of total entities (before adding more targets)
    LinearIndices((nx, ny, 3^pomdp.num_entities, (pomdp.maxPhotos + 1), (pomdp.maxPhotos + 1)))[s.quad[1], s.quad[2], pomdp.idPerms[s.identities], s.photosTaken + 1, s.photoHits + 1]
end

#TODO How to modify this for bool in state?
function state_from_index(pomdp::DroneSurveillancePOMDP, si::Int64)
    if si == length(pomdp)
        return pomdp.terminal_state
    end
        
    nx, ny = pomdp.size 
    #TODO: change 6 to function of total entities (before adding more targets)
    s = CartesianIndices((nx, ny, 3^pomdp.num_entities, (pomdp.maxPhotos + 1), (pomdp.maxPhotos + 1)))[si] # 2 for photo being true/false
    return DSState([s[1], s[2]], pomdp.entities, [k for (k,v) in pomdp.idPerms if v == s[3]][1], s[4] - 1, s[5] - 1)
end

# the state space is the POMDP itself
# we define an iterator over it

POMDPs.states(pomdp::DroneSurveillancePOMDP) = pomdp
# states: (quad_x, quad_y, indentities_permutations, photosTaken_values, photoHits_values) + terminal_state
Base.length(pomdp::DroneSurveillancePOMDP) = (pomdp.size[1] * pomdp.size[2] * 3^pomdp.num_entities * (pomdp.maxPhotos + 1) * (pomdp.maxPhotos + 1)) + 1 #1 is for terminal state

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

    for key in keys(pomdp.idPerms)
        push!(states, DSState(quad, pomdp.entities, key, 0, 0))
    end
    return Uniform(states)
end