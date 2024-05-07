include("src/DroneSurveillance.jl")

using .DroneSurveillance

# using DroneSurveillance
using QMDP

# import a solver from POMDPs.jl e.g. SARSOP
using BasicPOMCP
using POMDPModels, ARDESPOT
using DiscreteValueIteration
using POMDPTools
using POMDPs
using POMDPTools
using ParticleFilters
using POMDPSimulators
include("testing_funcs.jl")

# for visualization
using POMDPGifs
import Cairo
pomdp = DroneSurveillance.DroneSurveillancePOMDP() # initialize the problem 

RUN_C_COMPARISON = true

# @show pomdp.size

# # POMDPs.observation(pomdp::DroneSurveillancePOMDP{QuadCam}, a::Int64, s::DSState)
# @show POMDPs.observation(pomdp,1,s)

# using SARSOP
# solver = SARSOPSolver(precision=1e-0) # configure the solver

solver = POMCPSolver(tree_queries=50,
    c=1,
    default_action=ordered_actions(pomdp)[1],
    estimate_value=FORollout(ValueIterationSolver())
    )


function BasicPOMCP.updater(p::POMCPPlanner)
    P = typeof(p.problem)
    S = statetype(P)
    A = actiontype(P)
    O = obstype(P)
    return BootstrapFilter(p.problem, 10_000)
end

# solver = DESPOTSolver(K = 2000,
#                       D = 2000,
#                       lambda=0.5,
#                       bounds=IndependentBounds(-1, 1, check_terminal=true))

# function ARDESPOT.updater(p::POMCPPlanner)
#     P = typeof(p.problem)
#     S = statetype(P)
#     A = actiontype(P)
#     O = obstype(P)
#     return BootstrapFilter(p.problem, 10_000)
# end

# policy = solve(solver, pomdp) # solve the problem
# @show "herh"
# makegif(pomdp, policy, filename="gifs/out.gif")


# @show (m,sem) = runTests(pomdp,policy,10)
# p = makeplot([0,1,2,3],[1,4,8,32],uncert=[1,2,3,4],title="Test Plot",ylab="Y label",xlab="X label")
# display(p)

tree_qs = [10, 100 ,1000 ,10_000]
averages = []
stddevs = []
times = []
if RUN_C_COMPARISON

    for t in tree_qs
        println("Going to run t="*string(t))
        solv = POMCPSolver(tree_queries=t,
            c=1,
            default_action=ordered_actions(pomdp)[1],
            estimate_value=FORollout(ValueIterationSolver())
        )
        function BasicPOMCP.updater(p::POMCPPlanner)
            P = typeof(p.problem)
            S = statetype(P)
            A = actiontype(P)
            O = obstype(P)
            return BootstrapFilter(p.problem, 1_000)
        end

        pol = solve(solv, pomdp) 
        @show (a,s,t,_) = runTests(pomdp,pol,n_iter=25)

        push!(averages,a)
        push!(stddevs,s)
        push!(times,t)
    end

    p = makeplot(tree_qs, averages, title="Reward vs Tree Queries", line_lab="Mean", ylab="Reward", xlab="c")
    
    display(p) 
    p = makeplot(tree_qs, times, title="Execution Time vs Tree Queries", line_lab="Mean", ylab="Time", xlab="c")
    display(p)
end

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

