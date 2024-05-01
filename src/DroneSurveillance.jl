module DroneSurveillance

using Random
using LinearAlgebra
using POMDPs
using POMDPTools
using Parameters
using StaticArrays
using Compose
using Colors

export
    DSPos,
    DSState,
    QuadCam,
    PerfectCam,
    DroneSurveillancePOMDP


const DSPos = SVector{2, Int64}

struct DSState
    quad::DSPos
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
@with_kw mutable struct DroneSurveillancePOMDP{M} <: POMDP{DSState, Int64, Int64}
    n = 5
    size::Tuple{Int64, Int64} = (n,n)
    region_A::DSPos = DSPos([1, 1])
    fov::Tuple{Int64, Int64} = (3, 3)
    agent_policy::Symbol = :restricted
    camera::M = QuadCam() # PerfectCam
    reward_state = DSState(DSPos([-1, -1]), true)
    terminal_state::DSState = DSState(DSPos([-1, -1]), false)
    # discount_factor::Float64 = 0.95
    discount_factor::Float64 = .9999999

    #our stuff
    target::DSPos = [rand(1:n),rand(1:n)]
    benign::DSPos = [rand(1:n),rand(1:n)]
    detector::DSPos = [rand(1:n),rand(1:n)]
end

POMDPs.isterminal(pomdp::DroneSurveillancePOMDP, s::DSState) = s == pomdp.terminal_state
POMDPs.discount(pomdp::DroneSurveillancePOMDP) = pomdp.discount_factor

function POMDPs.reward(pomdp::DroneSurveillancePOMDP, s::DSState, a::Int64)
    if s.quad == pomdp.detector
        return -1.0
    end

    if s == pomdp.reward_state
        return 1.0
    end

    return 0.0
end

include("states.jl")
include("actions.jl")
include("transition.jl")
include("observation.jl")
include("visualization.jl")

end
