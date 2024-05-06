function hit(pomdp::DroneSurveillancePOMDP, s::DSState)
    id = findfirst(x -> x == s.quad, pomdp.entities)
    if isnothing(id)
        return false
    else
        return s.identities[id] == :T
    end
    
end

function POMDPs.transition(pomdp::DroneSurveillancePOMDP, s::DSState, a::Int64)
    # move quad
    new_quad  = s.quad + ACTION_DIRS[a]
    if !(0 < new_quad[1] <= pomdp.size[1]) || !(0 < new_quad[2] <= pomdp.size[2]) || isterminal(pomdp, s)
        return Deterministic(pomdp.terminal_state)
    elseif (a == 6) && (s.photosTaken < pomdp.maxPhotos) && (s.photoHits <= s.photosTaken) #takes photo (:photo => 6)
        # if s.photoHits == 5
        #     @show "STOOOOOPPPPP"
        # end
        if hit(pomdp, s)
            return Deterministic(DSState(new_quad,s.entities,s.identities,s.photosTaken + 1, s.photoHits + 1))
        else
            return Deterministic(DSState(new_quad,s.entities,s.identities,s.photosTaken + 1, s.photoHits))
        end
    else
        return Deterministic(DSState(new_quad,s.entities,s.identities,s.photosTaken, s.photoHits))
    end
end
