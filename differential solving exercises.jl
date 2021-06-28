using DifferentialEquations
using Plots
using BenchmarkTools

## 1. ODES (Ordinary differential equations)

# Deterministic model of oregenator model
function oregenator(du, u, p, t)
    s, w, q = p # parameters
    x, y, z = u
    du[1] = s * (y - x * y + x - q * (x^2)) # dx/dt
    du[2] = (-y - x * y + z) / s # dy/dt
    du[3] = w * (x - z) # dz/dt
end

# Initial values for x, y, z
initial_values = [1.0, 2.0, 3.0]

# Parameters
s = 77.27
w = 0.161
q = 8.375 * (10^-6)
p = [s, w, q]

# Create ODEProblem and solve for time span 0 - 360
prob = ODEProblem(oregenator, initial_values, (0.0, 360.0), p)

# IMPORTANT: This problem involves stiffness hence a ODE solver that can handle stiffness is preferred for performance

# Two separate solvers

# Solver that can handle stiffness (965.300 us)
@btime sol = solve(prob, Rodas5())

# Solver that can't handle stiffness (5.469s)
@btime sol = solve(prob, Tsit5())

# Plot solution
plot(sol)



## 2. SDES (Stochastic differential equations)
"""
Build upon orgenator from 1. but add a new function g_oregantor for noise.

So the equation becomes...

du = f(u, p, t)dt + g(u, p, t)dW
"""

# Define g
function g_oregantor(du, u, p, t)
    σ = 0.1 # σ₁, σ₂, σ₃ are all 0.1
    x, y, z = u
    du[1] = σ * x # σ₁xDW₁
    du[2] = σ * y # σ₂yDW₂
    du[3] = σ * z # σ₃xDW₃
end

W = WienerProcess(0.0, 0.0, 0.0) # DW terms are all Brownian Motion

# Solve and plot the SDE
prob_sde_orgenator = SDEProblem(oregenator, g_oregantor, initial_values, (0.0, 360.0), noise = W, p)
orgenator_sol = solve(prob_sde_orgenator, SOSRI())
plot(orgenator_sol)

# Run 100 trajectories on the SDE (like simulating 100 times with varying randomness)
orgenator_ensemble = EnsembleProblem(prob_sde_orgenator)
orgenator_sim = solve(ensemble, trajectories = 100, ImplicitRKMil(), EnsembleThreads(), saveat = 1.0)
plot(orgeneator_sim)

# Ensemble summary of the 100 trajectories
ensemble_summ = EnsembleSummary(sim, 0.0:1.0:360.0)
plot(ensemble_summ)



## BITCOIN EXAMPLE
"""
Scenario A (Ordinary differential equation)
Perfect world, 1 dollar for one BTC which gains 1% interest on it each year.


Scenario B (Stochastic differential equation)
Not so perfect world, 1 dollar for one BTC with gains/loss each year.
"""
function f(u, p, t)
    # 1% rate of change on the previous year's BTC value
    0.01u
end

function g(u, p, t)
    # Randomness
    0.01u
end

W = WienerProcess(0.0, 0.0, 0.0) # noise

u0 = 1.0 # initial value ($1 BTC)
tspan = (0.0, 10.0) # time span

# ODE/linear growth
ode_prob = ODEProblem(f, u0, tspan)
ode_sol = solve(prob, AutoVern7(Rodas5()), saveat = 1.0)
plot(ode_sol, m = :o)

# SDE/random growth + loss
# - Save each year's result
sde_prob = SDEProblem(f, g, u0, tspan, noise = W)
sde_sol = solve(prob, SOSRI(), saveat = 1.0)
plot(sde_sol)

# SDE with monte carlo like simulation
# - Run 100 trajectories i.e. see the potentialprice in each year with varying randomness
ensemble = EnsembleProblem(sde_prob)
sim = solve(ensemble, trajectories = 100, ImplicitRKMil(), EnsembleThreads(), saveat = 1.0)
plot(sim)

# Ensemble summary (take mean at each 1.0 time step)
ensemble_summ = EnsembleSummary(sim, 0.0:1.0:10.0)
plot(ensemble_summ)