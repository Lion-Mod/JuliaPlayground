using DifferentialEquations
using Plots

# DELAYED MODEL
# Modelling the delay between moving the cargo from the depot to central.
function delayed_depot_model(du, u, h, p, t)
    Kₐ, Kₑ, tau = p
    hist6 = h(p, t - tau)[1]
    du[1] = -Kₐ * u[1] # depot
    du[2] = (Kₐ * hist6) - (Kₑ * u[2]) # central
end

h(p, t) = zeros(2) # assume all time before t0 were 0



# CALLBACK
# Trigger callback if time t is equal to 24, 48, 72
event_times_to_add_to_depot = [24, 48, 72]

function condition(u, t, integrator)
    t ∈ event_times_to_add_to_depot
end

# Add 100 to u[1] which is the Depot when the condition hits
function affect!(integrator)
    integrator.u[1] += 100
end

# Declare the DiscreteCallback. It's made of two parameters...
# 1. Condition = what must happen for the affect to happen
# 2. Affect = what will happen when condition is met
# In this case add 100 to Depot
cb = DiscreteCallback(condition, affect!)



# DDEProblem inputs
u0 = [100.0, 0.0] # initial conditions
tau = 6.0 # lag
lags = [tau]
p = [2.268, 0.07398, tau] # parameters (Kₐ, Kₑ, τ)
tspan = (0.0, 90.0) # time span



# PROBLEM AND SOLVER
delayed_depot_prob = DDEProblem(delayed_depot_model, u0, h, tspan, p, constant_lags = lags)

delayed_depot_sol = solve(delayed_depot_prob, MethodOfSteps(Tsit5()), callback = cb, tstop = event_times_to_add_to_depot)

plot(delayed_depot_sol)