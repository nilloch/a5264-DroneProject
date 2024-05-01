function POMDPs.stateindex(pomdp::DroneSurveillancePOMDP, s::DSState)
    if isterminal(pomdp, s) 
        return length(pomdp)
    end

    if s==pomdp.reward_state
        return length(pomdp)-1
    end

    nx, ny = pomdp.size 


    LinearIndices((nx, ny, nx, ny, nx, ny, nx, ny, 2))[s.quad[1], s.quad[2], s.target[1], s.target[2], s.benign[1], s.benign[2], s.detector[1], s.detector[2], (s.photo ? 2 : 1)]
end

#TODO How to modify this for bool in state?
function state_from_index(pomdp::DroneSurveillancePOMDP, si::Int64)
    if si == length(pomdp)
        return pomdp.terminal_state
    elseif si == length(pomdp)-1
        return pomdp.reward_state
    end
        
    nx, ny = pomdp.size 
    s = CartesianIndices((nx, ny, nx, ny, nx, ny, nx, ny, 2))[si] # 2 for photo being true/false
    if s[3] == 2
        photo = true
    else # == 1
        photo = false
    end

    return DSState([s[1], s[2]],[s[3], s[4]],[s[5], s[6]],[s[7], s[8]], photo)
end

# the state space is the POMDP itself
# we define an iterator over it

POMDPs.states(pomdp::DroneSurveillancePOMDP) = pomdp
Base.length(pomdp::DroneSurveillancePOMDP) = ((pomdp.size[1] * pomdp.size[2])^4 * 2) + 2 #2 is for two terminal states 

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
    # states = DSState[]
    n = pomdp.n
    target::DSPos = [rand(1:n),rand(1:n)]
    benign::DSPos = [rand(1:n),rand(1:n)]
    detector::DSPos = [rand(1:n),rand(1:n)]

    return Deterministic(DSState(quad, target, benign, detector, false))

end
