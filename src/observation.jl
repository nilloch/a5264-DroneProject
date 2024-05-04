loc_obs = [:N,:NE,:E,:SE,:S,:SW,:W,:NW,:CEN,:OUT]
const OBS_DIRS = SVector(DSPos(0,1),
                        DSPos(1,1),
                        DSPos(1,0),
                        DSPos(1,-1),
                        DSPos(0,-1),
                        DSPos(-1,-1),
                        DSPos(-1,0),
                        DSPos(-1,1),
                        DSPos(0,0))
loc_dict = Dict((OBS_DIRS[i]) => loc_obs[i] for i in 1:(length(loc_obs)-1)) #<- don't want last element (:OUT) in loc_obs in this dict


id_obs = [:T,:B,:D,:N]

function perm(v,t)
    return vec(collect(Base.Iterators.product(Base.Iterators.repeated(v, t)...)))
end



# Return probability of observing entity's positions given current state and action
function posObs(entity,s,a)
    rel_pos = s.quad - s.entities[findfirst(entity .== s.identities)]
    
    if haskey(loc_dict,rel_pos)
        direction = loc_dict[rel_pos]
    else
        return [0,0,0,0,0,0,0,0,0,1.0]
        # return [.1,.1,.1,.1,.1,.1,.1,.1,.1,.1]
    end


    prob_dict = Dict(:N => [1.0,.0,.0,.0,.0,.0,.0,.0,.0,.0],
                    :NE => [.0,1.0,.0,.0,.0,.0,.0,.0,.0,.0],
                    :E  => [0,0,1.0,.0,.0,.0,.0,.0,.0,.0],
                    :SE => [0,0,0,1.0,0,0,0,0,0,0],
                    :S  => [0,0,0,0,1.0,0,0,0,0,0],
                    :SW => [0,0,0,0,0,1.0,0,0,0,0],
                    :W  => [0,0,0,0,0,0,1.0,0,0,0],
                    :NW => [0,0,0,0,0,0,0,1.0,0,0],
                    :CEN=> [0,0,0,0,0,0,0,0,1.0,0])

    # # THESE ARE BAD
    # prob_dict = Dict(:N => [.2,.1,.1,.1,.1,.1,.1,.1,.1,0],
    #                 :NE => [.1,.2,.1,.1,.1,.1,.1,.1,.1,0],
    #                 :E =>  [.1,.1,.2,.1,.1,.1,.1,.1,.1,0],
    #                 :SE => [.1,.1,.1,.2,.1,.1,.1,.1,.1,0],
    #                 :S =>  [.1,.1,.1,.1,.2,.1,.1,.1,.1,0],
    #                 :SW => [.1,.1,.1,.1,.1,.2,.1,.1,.1,0],
    #                 :W =>  [.1,.1,.1,.1,.1,.1,.2,.1,.1,0],
    #                 :NW => [.1,.1,.1,.1,.1,.1,.1,.2,.1,0],
    #                 :CEN =>[.1,.1,.1,.1,.1,.1,.1,.1,.2,0])


    return prob_dict[direction]

end

# given the entity, what is the probability it is observed as any entity
function idObs(entity,s)
    if norm(s.quad - s.entities[findfirst(entity .== s.identities)]) >= 1.5
        return [0.0, 0.0, 0.0, 1.0]
    elseif entity == :T 
        # return [0.5, 0.25, 0.25, 0.0]
        # return [.7, 0.1, 0.1, 0.1]
        return [1.0, 0.0, 0.0, 0.0]
        # return [0.9, 0.05, 0.05, 0.0]
    elseif entity == :B
        # return [0.25, 0.5, 0.25, 0.0]
        # return [.1, 0.7, 0.1, 0.1]
        return [0.0, 1.0, 0.0, 0.0]
        # return [0.05, 0.9, 0.05, 0.0]
    elseif entity == :D
        # return [0.25, 0.25, 0.5, 0.0]
        # return [.1, 0.1, 0.7, 0.1]
        return [0.0, 0.0, 1.0, 0.0]
        # return [0.05, 0.05, 0.9, 0.0]
    end
end

obs = vec([vcat.(v...) for v in Iterators.product(perm(id_obs,3), perm(loc_obs,3))])# perm(perm(id_obs,3),perm(loc_obs,3))
obs2idx_dict = Dict((obs[i]) => i for i in 1:length(obs))
idx2obs_dict = Dict((i) => obs[i] for i in 1:length(obs))

const OBS_QUAD = [:SW, :NW, :NE, :SE, :DET, :OUT]
const N_OBS_PERFECT = 10
const N_OBS_QUAD = 6

POMDPs.observations(pomdp::DroneSurveillancePOMDP{QuadCam}) = 1:length(obs)
POMDPs.observations(pomdp::DroneSurveillancePOMDP{PerfectCam}) = 1:N_OBS_PERFECT
POMDPs.obsindex(pomdp::DroneSurveillancePOMDP, o::Int64) = o

function POMDPs.observation(pomdp::DroneSurveillancePOMDP{QuadCam}, a::Int64, s::DSState)
    id_probs = (idObs(s.identities[1],s) * idObs(s.identities[2],s)') .* reshape(idObs(s.identities[3],s), 1, 1, :)
    id_probs = vec(id_probs)

    loc_probs = (posObs(s.identities[1],s,a) * posObs(s.identities[2],s,a)') .* reshape(posObs(s.identities[3],s,a), 1, 1, :)
    loc_probs = vec(loc_probs)

    tot_probs = vec(id_probs*loc_probs')

    return SparseCat(1:length(obs), tot_probs)
end
