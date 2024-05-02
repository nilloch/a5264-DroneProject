function POMDPs.stateindex(pomdp::DroneSurveillancePOMDP, s::DSState)
    if isterminal(pomdp, s) 
        return length(pomdp)
    end

    if s==pomdp.reward_state
        return length(pomdp)-1
    end

    nx, ny = pomdp.size 


    LinearIndices((nx, ny, 6, 2))[s.quad[1], s.quad[2], pomdp.idPerms[s.identities], (s.photo ? 2 : 1)]
end

#TODO How to modify this for bool in state?
function state_from_index(pomdp::DroneSurveillancePOMDP, si::Int64)
    if si == length(pomdp)
        return pomdp.terminal_state
    elseif si == length(pomdp)-1
        return pomdp.reward_state
    end
        
    nx, ny = pomdp.size 
    s = CartesianIndices((nx, ny, 2))[si] # 2 for photo being true/false
    if s[3] == 2
        photo=true
    else # == 1
        photo=false
    end
    getkey
    return DSState([s[1], s[2]], pomdp.entities, (k for (k,v) in pomdp.idPerms if v == si)[1], photo)
end

# the state space is the POMDP itself
# we define an iterator over it

POMDPs.states(pomdp::DroneSurveillancePOMDP) = pomdp
Base.length(pomdp::DroneSurveillancePOMDP) = (pomdp.size[1] * pomdp.size[2] * 2 * 6) + 2 #2 is for two terminal states 

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
    # fov_x, fov_y = pomdp.fov
    # states = DSState[]
    pomdp.entities = [DSPos([rand(1:nx),rand(1:ny)]),DSPos([rand(1:nx),rand(1:ny)]),DSPos([rand(1:nx),rand(1:ny)])]
    return Deterministic(DSState(quad, pomdp.entities ,rand([p for p in multiset_permutations(pomdp.ids,3)]), false))

    # probs = normalize!(ones(length(states)), 1)
    # return SparseCat(states, probs)
end
