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

RUN_C_COMPARISON = false

# @show pomdp.size

# # POMDPs.observation(pomdp::DroneSurveillancePOMDP{QuadCam}, a::Int64, s::DSState)
# @show POMDPs.observation(pomdp,1,s)

# using NativeSARSOP
# using SARSOP
# solver = SARSOPSolver(precision=1e-0) # configure the solver


# using QMDP
# solver = QMDPSolver(max_iterations=20,
#                     belres=1e-10,
#                     verbose=true
#                    ) 

solver = POMCPSolver(tree_queries=10000,
    c=1,
    default_action=ordered_actions(pomdp)[1],
    estimate_value=FORollout(ValueIterationSolver())
    # estimate_value=FORollout(FunctionPolicy(s->rand(actions(pomdp))))
    )


function BasicPOMCP.updater(p::POMCPPlanner)
    P = typeof(p.problem)
    S = statetype(P)
    A = actiontype(P)
    O = obstype(P)
    return BootstrapFilter(p.problem, 1000)
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

policy = solve(solver, pomdp) # solve the problem
# @show "herh"
# makegif(pomdp, policy, filename="gifs/out.gif",max_steps=100)


# @show (m,sem) = runTests(pomdp,policy,10)
# p = makeplot([0,1,2,3],[1,4,8,32],uncert=[1,2,3,4],title="Test Plot",ylab="Y label",xlab="X label")
# display(p)

if RUN_C_COMPARISON
    cs = [0.1, 0.5 ,2.5 ,12.5, 50]
    averages = []
    stddevs = []
    times = []

    for c in cs
        solv = POMCPSolver(tree_queries=10,
            c=c,
            default_action=ordered_actions(pomdp)[1],
            estimate_value=FORollout(ValueIterationSolver())
        )
        pol = solve(solv, pomdp) 
        (a,s,t,_) = runTests(pomdp,pol,n_iter=2)

        push!(averages,a)
        push!(stddevs,s)
        push!(times,t)
    end

    p = makeplot(cs, averages, title="Reward vs Exploration Constant", line_lab="Mean", ylab="Reward", xlab="c")
    display(p) 
    p = makeplot(cs, times, title="Execution Time vs Exploration Constant", line_lab="Mean", ylab="Time", xlab="c")
    display(p)
end

# rs = RolloutSimulator(max_steps=10000)
# # mdp = GridWorld()
# # policy = RandomPolicy(mdp)

# @show r = simulate(rs, pomdp, policy)
# global r_sum = 0.0
# global bruh = 0

for (b, s, a, o, r) in stepthrough(pomdp, policy, "b,s,a,o,r"; max_steps=100)
    # bruh += 1
    # println("Step $step")
    @show s
    @show a
    @show o
    @show r
    # r_sum += r
    # @show r_sum
    println()
end

