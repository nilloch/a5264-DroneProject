
const ACTIONS_DICT = Dict(:north => 1, 
:east => 2,
:south => 3,
:west => 4,
:hover => 5,
:photo => 6)

const ACTION_DIRS = (DSPos(0,1),
DSPos(1,0),
DSPos(0,-1),
DSPos(-1,0),
DSPos(0,0),
DSPos(0,0))

const N_ACTIONS = 6

POMDPs.actions(pomdp::DroneSurveillancePOMDP) = 1:N_ACTIONS
POMDPs.actionindex(pomdp::DroneSurveillancePOMDP, a::Int64) = a

POMDPs.actions(pomdp::DroneSurveillancePOMDP, s::DSPos) = 1:N_ACTIONS