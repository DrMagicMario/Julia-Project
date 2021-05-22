#conceptual model of covid-19
#plug in known models of the pandemic:
#SEIR (epidemic modeling): susceptible pop, exposed pop, infected pop, recoverd pop
#also includes: total pop, total exposed pop, total hospitalized (very infected)
#
#here we encode these model into the nerual network and learn any missing pieces of the model. Essentially giving the model a framework to complete.
#
#Steps to make a ML-augemted scientific model:
# 1. identify known parts of the model -> universal ODE
# 2. train neural network (or approximator) to find missing link
# 3. sparse identify the missing terms to mechanistic terms
# 4. Verify the mechanisms sre scientifically plausible (how are all the terms related)
# 5. Extrapolate, Asymtotic Analysis, predict bifurcations  
# 6. collect more data to verify those new terms
#
#
#Juias Scientific Machine Learning ecosystem is designed to be efficient, robust and accurate training of Universal Diffenrential Equations to approximate these missing terms.
#
#DifferentialEquations.jl: high performance differential equation solvers
#DiffEqFlux.jl: universal differential equation training optimizers, sensitivity analysis, and layer functions
#ModelingToolKit.jl: symbolic-numeric optimization and automated parallelism. 
#NeuralPde.jl: nueral network solvers for PDE, including automated physics-informed neural networks and deep BSDE methods for high dimensional PDEs
#Catalyst.jl: high performance differentiable modeling of chemical reactions network#NBodySimulator.jl: high-performance differentiable molecular dynamics
#DataDrivenDiffEq.jl: Koopman Dynamic mode decomposition (DMD) moethods and sparse identification
#+50 more
#
#
using Pkg;
Pkg.activate(".")
Pkg.add("DifferentialEquations")
Pkg.add("Plots")

using DifferentialEquations, Plots

function latka_volterra!(du,u,p,t) 
  rabbit,wolf = u
  a,b,y,z = p
  du[1] = a*rabbit - b*wolf*rabbit #rabbit pop.
  du[2] = y*rabbit*wolf - z*wolf #wolf pop.
end

function multiplicative_noise!(du,u,p,t)
  rabbit , wolf = u
  du[1] = 0.3*rabbit
  du[2] = 0.3*wolf
end

tau = 1.0
function latka_volterra!(du,u,h,p,t) 
  rabbit,wolf = u
  rabbit_delay = h(p,t-tau;idxs=1)
  a,b,y,z = p
  du[1] = a*rabbit_delay - b*wolf*rabbit #rabbit pop.
  du[2] = y*rabbit*wolf - z*wolf #wolf pop.
end

u_not = [1.0,1.0]
tspan = (0.0,10.0)
p = [1.5,1.0,3.0,1.0]


prob = SDEProblem(latka_volterra!,multiplicative_noise!,u_not,tspan,p)
#@time sol = solve(prob) #automatically chooses best method to solve

#model inference 
#original model
prob = ODEProblem(latka_volterra!,u_not,tspan,p)
@time sol = solve(prob,saveat=0.1)
dataset = Array(sol)
display(scatter!(sol.t, dataset')) 


#new model
tmp_prob = remake(prob,p=[1.2,0.8,2.5,0.8]) #solve porblems using modified the inputs
@time tmp_sol = solve(tmp_prob,saveat=0.1) #set timestep 
tmp_dataset = Array(tmp_sol)
display(scatter!(tmp_sol.t,tmp_dataset')) 
#how do we get original model parameters? Compare two datasets and compute differences at each point


#display(plot(sol))
#display(plot(sol, vars=[1,2]))

ensembleprob = EnsembleProblem(prob) #solve an SDE over multiple trajectories and summarizes the findings
#@time sol = solve(ensembleprob, SOSRI(), EnsembleThreads(), trajectories=1000) #specifies which method to use (SOSRI = stiff awareness); use all available threads (EnsembleThreads(); # of trajectories) 

#display(plot(sol))
#@time sumn = EnsembleSummary(sol)
#display(plot(sumn))

h(p,t)=[1.0,1.0]
h(p,t;idxs=1)=1.0

prob = DDEProblem(latka_volterra!,u_not,h,tspan,p,constant_lag = [tau]) #Delay Differential Equation. 
#@time sol = solve(prob, Tsit5(), dense=false)

#display(plot(sol))

rabbit_condition(u,t,integrator) = u[2]-4
rabbit_affect!(integrator) = integrator.u[2] -= 1
rabbit_cb = ContinuousCallback(rabbit_condition, rabbit_affect!)
#@time sol = solve(prob, callback = rabbit_cb)

#display(plot(sol))
#u_prime = f(u)
#u(0) = u_not

print("hello")

while(true)
  sleep(1)
end 
