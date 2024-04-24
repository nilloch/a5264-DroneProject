Things we've tried
1. Using the DroneSurveilance.jl POMCP package to test solvers
  * Sarsop
    * ValueIteration rollout
    * VERY slow - conditional plans makes the optimal policy of alpha vectors very long
  * POMCP
    * Default belief updater is an unweighted particle filter that has issues with particle depletion
