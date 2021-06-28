using DifferentialEquations
using Plots

# ODE equations
function f(du, u, p, t)
    du[1] = -p[1] * u[1]
    du[2] = (p[1] * u[1]) - (p[2] * u[2])
end

# Setup functions for DiscreteCallback

# Trigger callback if time is equal to 24, 48, 72
event_times_to_add_to_depot = [24, 48, 72]

function condition(u, t, integrator)
    t ∈ event_times_to_add_to_depot
end

# Add 100 to u[1] which is the Depot when condition hits
function affect!(integrator)
    integrator.u[1] += 100
end

# Declare the DiscreteCallback. It's made of two parameters...
# 1. Condition = what must happen for the affect to happen
# 2. Affect = what will happen when condition is met
# In this case add 100 to Depot
cb = DiscreteCallback(condition, affect!)

u0 = [100.0, 0.0] # initial conditions
p = [2.268, 0.07398] # parameters
tspan = (0.0, 90.0) # time span

# Declare the ODE and solve with the callback
depot_prob = ODEProblem(f, u0, tspan, p)
depot_sol = solve(depot_prob, Tsit5(), callback = cb, tstops = event_times_to_add_to_depot)

# Plot it
plot(depot_sol)
