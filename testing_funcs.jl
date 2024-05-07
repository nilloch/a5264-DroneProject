using Statistics
using POMDPTools
using Plots

function runTests(m,policy;n_iter=100, max_steps=1000)
    res = []
    times = []
    rs = RolloutSimulator(max_steps=max_steps)
    print("Run: ")
    for i = 1:n_iter
        start = time_ns()
        print(i); print(", ")

        r = simulate(rs, m, policy)
        push!(res,r)
        push!(times,time_ns()-start)
    end
    av = mean(res)
    stddev = std(res)
    sem = stddev/sqrt(n_iter)
    avg_time = Float64(mean(times))/1e6

    return av,stddev,avg_time,sem
end

function makeplot(x,y;title="", xlab="", ylab="", line_lab="", uncert=nothing, uncert_lab="2σ Bounds")
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
        plot!(p,x,y,linewidth=lw,c="blue",label=line_lab)
    else
        p = plot(x,y, 
                 linewidth=lw,
                 xguidefontsize=lfs,
                 yguidefontsize=lfs, 
                 ytickfontsize=tfs, 
                 xtickfontsize=tfs, 
                 legendfontsize=tfs,
                 label=line_lab)
    end
    title!(p,title)
    xlabel!(p,xlab)
    ylabel!(p,ylab)

    return p
end