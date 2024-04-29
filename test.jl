# include("C:\\Users\\luker\\Documents\\repos\\asen5264\\hw6\\q1.jl")

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

using SARSOP
solver = SARSOPSolver(precision=1e-1) # configure the solver

# function BasicPOMCP.updater(p::POMCPPlanner)
#     P = typeof(p.problem)
#     S = statetype(P)
#     A = actiontype(P)
#     O = obstype(P)
#     return BootstrapFilter(p.problem, p.solver.tree_queries, rng=p.rng)
#     # XXX It would be better to automatically use an SIRParticleFilter if possible
#     # if !@implemented ParticleFilters.obs_weight(::P, ::S, ::A, ::S, ::O)
#     #     return UnweightedParticleFilter(p.problem, p.solver.tree_queries, rng=p.rng)
#     # end
#     # return SIRParticleFilter(p.problem, p.solver.tree_queries, rng=p.rng)
# end

# solver = POMCPSolver(tree_queries=200,
#     c=1,
#     default_action=ordered_actions(pomdp)[1],
#     #  estimate_value=FORollout(ValueIterationSolver))
#     estimate_value=FORollout(ValueIterationSolver()))

# # struct HW6Updater{M<:BasicPOMCP} <: Updater
# #     m::M
# # end
    
# BasicPOMCP.updater = my_updater

policy = solve(solver, pomdp) # solve the problem
@show "herh"
# makegif(pomdp, policy, filename="out.gif")

rs = RolloutSimulator()
# mdp = GridWorld()
# policy = RandomPolicy(mdp)

@show r = simulate(rs, pomdp, policy)