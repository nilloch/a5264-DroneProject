using Statistics
using POMDPTools
using Plots

function runTests(m,policy,n_iter=100, max_steps=1000)
    res = []
    rs = RolloutSimulator(max_steps=max_steps)
    for i = 1:n_iter
        r = simulate(rs, m, policy)
        push!(res,r)
    end
    av = mean(res)
    sem = std(res)/sqrt(n_iter)

    return av,sem
end

function makeplot(x,y;title="", xlab="", ylab="", uncert=nothing, uncert_lab="Uncertainty")
    tfs = 12 # tick font sizes 
    lfs = 16 #label font size
    lw = 3 # line width
    
    p = []
    if !isnothing(uncert)
        p = plot(x,y,ribbon=uncert, 
                 fillalpha=0.35,
                 label=uncert_lab,
                 c="red", 
                 xguidefontsize=lfs,
                 yguidefontsize=lfs,
                 ytickfontsize=tfs, 
                 xtickfontsize=tfs, 
                 legendfontsize=tfs)
        plot!(p,x,y,linewidth=lw,c="blue")
    else
        p = plot(x,y, 
                 linewidth=lw,
                 xguidefontsize=lfs,
                 yguidefontsize=lfs, 
                 ytickfontsize=tfs, 
                 xtickfontsize=tfs, 
                 legendfontsize=tfs)
    end
    title!(p,title)
    xlabel!(p,xlab)
    ylabel!(p,ylab)

    return p
end