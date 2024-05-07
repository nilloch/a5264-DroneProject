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
using ParticleFilters

export
    DSPos,
    DSState,
    QuadCam,
    PerfectCam,
    DroneSurveillancePOMDP


const DSPos = SVector{2, Int64}

struct DSState
    quad::DSPos
    identities::Vector{typeof(:thing)}
    photoHits::Vector{Int} #0 if no photo taken, num_entities+1 if not a hit, ID of entity if hit
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

function perm(v,t)
    return vec(collect(Base.Iterators.product(Base.Iterators.repeated(v, t)...)))
end

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
@with_kw mutable struct DroneSurveillancePOMDP{M} <: POMDP{DSState, Int64, Int64}
    n = 5
    maxPhotos = 3;
    num_particles = 70_000
    size::Tuple{Int64, Int64} = (n,n)
    region_A::DSPos = DSPos([1, 1])
    fov::Tuple{Int64, Int64} = (3, 3)
    agent_policy::Symbol = :restricted
    camera::M = QuadCam() # PerfectCam
    discount_factor::Float64 = 0.95
    #our stuff
    ids = [:T,:B,:D]
    # entities = [DSPos([rand(1:size[1]),rand(1:size[2])]),DSPos([rand(1:size[1]),rand(1:size[2])]),DSPos([rand(1:size[1]),rand(1:size[2])])]
    entities = [DSPos([1,n]), DSPos([n,1]), DSPos([n,n])]
    num_entities = length(entities)
    idPerms = Dict([p[1],p[2],p[3]] => i for (i,p) in enumerate(perm(ids, num_entities))) # allow entities to be whatever
    
    terminal_state::DSState = DSState(DSPos([-1, -1]), [:T,:B,:D], repeat([-1],maxPhotos))
end

POMDPs.isterminal(pomdp::DroneSurveillancePOMDP, s::DSState) = s == pomdp.terminal_state
POMDPs.discount(pomdp::DroneSurveillancePOMDP) = pomdp.discount_factor

function POMDPs.reward(pomdp::DroneSurveillancePOMDP, s::DSState, a::Int64, sp::DSState)
    # if !isterminal(pomdp,s) 
    # if !isterminal(pomdp,s) && isterminal(pomdp,sp) 
    #     T_idxs = findall(x -> x==:T, s.identities)
    #     return sum([en in T_idxs ? 2 : 0 for en in unique(s.photoHits)])
    # end
    # T_idxs = findall(x -> x==:T, s.identities)
    # if a == 6 && s.quad in s.entities[findall(:T .== s.identities)]
    #     # return 2
    # end

    # T_idxs = findall(x -> x==:T, s.identities)
    # return sum([en in T_idxs ? 2 : 0 for en in unique(s.photoHits)])

    if s.photoHits[1]==0 && a==6 && s.quad in pomdp.entities
        return 20.0
    end



    
    idx = findfirst(:D .== s.identities)
    if !isnothing(idx) && s.quad == pomdp.entities[idx]
        return -1.0
    end
    
    return -0.0
end

include("states.jl")
include("actions.jl")
include("transition.jl")
include("observation.jl")
include("visualization.jl")

end
