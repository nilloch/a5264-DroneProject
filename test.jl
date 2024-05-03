include("src/DroneSurveillance.jl")

using .DroneSurveillance

# using DroneSurveillance
using QMDP

# import a solver from POMDPs.jl e.g. SARSOP
using BasicPOMCP
using DiscreteValueIteration
using POMDPTools: ordered_actions
using POMDPs
using POMDPTools
using ParticleFilters

# for visualization
using POMDPGifs
import Cairo
pomdp = DroneSurveillance.DroneSurveillancePOMDP() # initialize the problem 
# @show POMDPs.initialstate(pomdp)
# @show POMDPs.initialstate(pomdp)
# @show POMDPs.initialstate(pomdp)
# @show s = DroneSurveillance.DSState((1,1),false)
# @show s_idx = DroneSurveillance.stateindex(pomdp, s)
# @show DroneSurveillance.state_from_index(pomdp,s_idx)

# @show pomdp.size

# # POMDPs.observation(pomdp::DroneSurveillancePOMDP{QuadCam}, a::Int64, s::DSState)
# @show POMDPs.observation(pomdp,1,s)

# using SARSOP
# solver = SARSOPSolver(precision=1e-0) # configure the solver

solver = POMCPSolver(tree_queries=200,
    c=1,
    default_action=ordered_actions(pomdp)[1],
    #  estimate_value=FORollout(ValueIterationSolver))
    estimate_value=FORollout(ValueIterationSolver()))

# BasicPOMCP.updater = my_updater

function BasicPOMCP.updater(p::POMCPPlanner)
    P = typeof(p.problem)
    S = statetype(P)
    A = actiontype(P)
    O = obstype(P)
    return BootstrapFilter(p.problem, 10_000)
end

policy = solve(solver, pomdp) # solve the problem
@show "herh"
makegif(pomdp, policy, filename="gifs/out.gif")

# rs = RolloutSimulator(max_steps=10000)
# # mdp = GridWorld()
# # policy = RandomPolicy(mdp)

# @show r = simulate(rs, pomdp, policy)
# global r_sum = 0.0
# global bruh = 0
# for (b, s, a, o, r) in stepthrough(pomdp, policy, "b,s,a,o,r"; max_steps=10000)
#     # bruh += 1
#     # println("Step $step")
#     @show s
#     @show a
#     @show o
#     @show r
#     # r_sum += r
#     # @show r_sum
#     println()
# end

