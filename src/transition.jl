function POMDPs.transition(pomdp::DroneSurveillancePOMDP, s::DSState, a::Int64)
    # move quad
    new_quad  = s.quad + ACTION_DIRS[a]
    if !(0 < new_quad[1] <= pomdp.size[1]) || !(0 < new_quad[2] <= pomdp.size[2]) 
        # if isterminal(pomdp, s) || s==pomdp.reward_state
        #     return Deterministic(pomdp.terminal_state) # the function is not type stable, returns either Deterministic or SparseCat
        # end
        if s.photo && !isterminal(pomdp, s) && s!=pomdp.reward_state
            return Deterministic(pomdp.reward_state)
        else 
            return Deterministic(pomdp.terminal_state)
        end

    elseif (new_quad==pomdp.target) #takes photo
        return Deterministic(DSState(new_quad,s.entities,s.identities,true)) # the function is not type stable, returns either Deterministic or SparseCat
    else
        return Deterministic(DSState(new_quad,s.entities,s.identities,false))
    end
end

"""
    agent_inbounds(pomdp::DroneSurveillancePOMDP, s::DSPos)
returns true if s in an authorized position for the ground agent
s must be on the grid and outside of the surveyed regions
"""
function agent_inbounds(pomdp::DroneSurveillancePOMDP, s::DSPos)
    if !(0 < s[1] <= pomdp.size[1]) || !(0 < s[2] <= pomdp.size[2])
        return false
    end
    if pomdp.agent_policy == :restricted 
        if s == pomdp.region_A || s == pomdp.target
            return false 
        end
    end
    return true
end