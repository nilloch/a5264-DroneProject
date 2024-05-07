function snap(pomdp::DroneSurveillancePOMDP, s::DSState)
    #"snaps" a photo... hahaha
    id = findfirst([s.quad == en for en in pomdp.entities])
    if isnothing(id)
        return pomdp.num_entities+1
    else
        return id
    end
    
end

function POMDPs.transition(pomdp::DroneSurveillancePOMDP, s::DSState, a::Int64)
    # move quad
    new_quad  = s.quad + ACTION_DIRS[a]
    if !(0 < new_quad[1] <= pomdp.size[1]) || !(0 < new_quad[2] <= pomdp.size[2]) || isterminal(pomdp, s)
        return Deterministic(pomdp.terminal_state)
    end
    
    temp = copy(s.photoHits)
    if (a == 6) && s.photoHits[1] == 0 #takes photo (:photo => 6)
        # if s.photoHits == 5
        #     @show "STOOOOOPPPPP"
        # end
        id = snap(pomdp, s)
        popfirst!(temp)
        push!(temp, id)
    end
    
    return Deterministic(DSState(new_quad, s.identities, temp))
    
end
