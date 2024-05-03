                           #TBD 
# const OBS_DICT = Dict(1 => (:T,:T,:T), #<- measurement that all target
#                       2 => :TTB, # 
#                       3 => :TTD,
#                       4 => :BTT,
#                       5 => :BTB, # right under the quad
#                       6 => :BTD,
#                       7 => :DTT,
#                       8 => :DTB,
#                       9 => :DTD,
#                       10 => :OUT) # out of the FOV
ind_obs = [:T,:B,:D,:N]

function perm(v,t)
    return vec(collect(Base.Iterators.product(Base.Iterators.repeated(v, t)...)))
end

# given the entity, what is the probability it is observed as any entity
function Z(entity)
    if entity == :T 
        return [0.5, 0.25, 0.25, 0.0]
        # return [0.0, 0.0, 1.0, 0.0]
    elseif entity == :B
        return [0.25, 0.5, 0.25, 0.0]
        # return [1.0, 0.0, 0.0, 0.0]
    elseif entity == :D
        return [0.25, 0.25, 0.5, 0.0]
        # return [0.25, 0.25, 0.25, 0.25]
    end
end
@show obs = perm(ind_obs,3)
obs2idx_dict = Dict((obs[i]) => i for i in 1:length(obs))
idx2obs_dict = Dict((i) => obs[i] for i in 1:length(obs))
# @show probs = (Z(:T) * Z(:B)') .* reshape(Z(:D), 1, 1, :)
# @show probs = vec(probs)

const OBS_QUAD = [:SW, :NW, :NE, :SE, :DET, :OUT]
const N_OBS_PERFECT = 10
const N_OBS_QUAD = 6

POMDPs.observations(pomdp::DroneSurveillancePOMDP{QuadCam}) = 1:length(obs)
POMDPs.observations(pomdp::DroneSurveillancePOMDP{PerfectCam}) = 1:N_OBS_PERFECT
POMDPs.obsindex(pomdp::DroneSurveillancePOMDP, o::Int64) = o

function POMDPs.observation(pomdp::DroneSurveillancePOMDP{QuadCam}, a::Int64, s::DSState)
    probs = (Z(s.identities[1]) * Z(s.identities[2])') .* reshape(Z(s.identities[3]), 1, 1, :)
    probs = vec(probs)
    return SparseCat(1:length(obs), probs)
end

# function POMDPs.observation(pomdp::DroneSurveillancePOMDP{PerfectCam}, a::Int64, s::DSState)
#     obs = SVector{N_OBS_PERFECT}(1:N_OBS_PERFECT)
#     probs = zeros(MVector{N_OBS_PERFECT})
#     obs_dir = pomdp.target-s.quad 
#     obs_ind = findfirst(isequal(obs_dir), OBS_DIRS)
#     if obs_ind == nothing 
#         probs[10] = 1.0
#         return SparseCat(obs, probs)
#     else
#         probs[obs_ind] = 1.0
#         return SparseCat(obs, probs)
#     end
# end
