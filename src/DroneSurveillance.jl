module DroneSurveillance

using Random
using LinearAlgebra
using POMDPs
using POMDPTools
using Parameters
using StaticArrays
using Compose
using Colors
using Combinatorics

export
    DSPos,
    DSState,
    QuadCam,
    PerfectCam,
    DroneSurveillancePOMDP


const DSPos = SVector{2, Int64}

struct DSState
    quad::DSPos
    entities::Vector{DSPos}
    identities::Vector{typeof(:thing)}
    photo::Bool 
end


"""
    QuadCam

When used as a camera model, the field of view of the UAV is divided in four region.
If the target is in a corner it is detected perfectly, if it is in the middle of two regions
it is assigned with equal probability to the neighboring regions. If the agent is below the UAV
it is detected with probability 1.
"""
struct QuadCam end

"""
    PerfectCam

When used as a camera model, the UAV can detect the ground agent with probability 1 when
it is in its field of view.
"""
struct PerfectCam end

"""
    DroneSurveillancePOMDP{M} <: POMDP{DSState, Int64, Int64}

# Fields
- `size::Tuple{Int64, Int64} = (5,5)` size of the grid world
- `region_A::DSPos = [1, 1]` first region to survey, initial state of the quad
- `target::DSPos = [size[1], size[2]]` second region to survey
- `fov::Tuple{Int64, Int64} = (3, 3)` size of the field of view of the drone
- `agent_policy::Symbol = :restricted` policy of the other agent
- `camera::M = QuadCam()` observation model, choose between perfect camera and quad camera
- `terminal_state::DSState = DSState([-1, -1], [-1, -1])` a sentinel state to encode terminal states
- `discount_factor::Float64 = 0.95` the discount factor
"""
Nbadcode = 7
entityVec = []
for j in 1:5
    push!(entityVec,DSPos([rand(1:Nbadcode),rand(1:Nbadcode)]))
end
@with_kw mutable struct DroneSurveillancePOMDP{M} <: POMDP{DSState, Int64, Int64}
    n = Nbadcode
    size::Tuple{Int64, Int64} = (n,n)
    region_A::DSPos = DSPos([1, 1])
    fov::Tuple{Int64, Int64} = (3, 3)
    agent_policy::Symbol = :restricted
    camera::M = QuadCam() # PerfectCam
    # reward_state = DSState(DSPos([-1, -1]),[DSPos([-1, -1]),DSPos([-1, -1]),DSPos([-1, -1])], [:T,:B,:D], true)
    # terminal_state::DSState = DSState(DSPos([-1, -1]),[DSPos([-1, -1]),DSPos([-1, -1]),DSPos([-1, -1])], [:T,:B,:D], false)
    discount_factor::Float64 = 0.99
    #our stuff
    ids = [:T,:B,:D]
    # idPerms = Dict(p => i for (i,p) in enumerate(multiset_permutations(ids,3)))
    entities = entityVec
    # entities = [DSPos([rand(1:size[1]),rand(1:size[2])]),DSPos([rand(1:size[1]),rand(1:size[2])]),DSPos([rand(1:size[1]),rand(1:size[2])])]
    # entities = [DSPos([1,5]),DSPos([5,1]),DSPos([5,5])]
    # entities = [DSPos([1,n]), DSPos([n,1]), DSPos([n,n]), DSPos([3,3])]
    num_entities = length(entities)
    idPerms = Dict([p[1],p[2],p[3],p[4],p[5]] => i for (i,p) in enumerate(perm(ids, num_entities))) # allow entities to be whatever
    
    reward_state::DSState = DSState(DSPos([-1, -1]), repeat([DSPos([-1, -1])],num_entities),repeat([:T],num_entities), true)
    terminal_state::DSState = DSState(DSPos([-1, -1]), repeat([DSPos([-1, -1])],num_entities),repeat([:T],num_entities), false)
    # [p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9]]
end

POMDPs.isterminal(pomdp::DroneSurveillancePOMDP, s::DSState) = s == pomdp.terminal_state
POMDPs.discount(pomdp::DroneSurveillancePOMDP) = pomdp.discount_factor

function POMDPs.reward(pomdp::DroneSurveillancePOMDP, s::DSState, a::Int64)
    if s == pomdp.reward_state
        return 2.0
    end
    
    detPos = s.entities[findall(:D .== s.identities)]
    if !isnothing(detPos)
        if s.quad in detPos
            return -1.0
        end
    end
    
    return -0.01
end

include("states.jl")
include("actions.jl")
include("transition.jl")
include("observation.jl")
include("visualization.jl")

end
