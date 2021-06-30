using DifferentialEquations
using Plots
using Sundials

# Model
# NOTE: using out rather than du
# Also the last equation is for conservation not changes
function robertson_model(out, du, u, p, t)
    out[1] = -0.04 * u[1] + 10^4 * u[2] * u[3] - du[1]
    out[2] = 0.04 * u[1] - 10^4 * u[2] * u[3] - 3e7 * u[2] * u[2] - du[2]
    out[3] = u[1] + u[2] + u[3] - 1.
end

# Initial values and parameters
u0 = [1., 0, 0]
du0 = [-0.04, 0.04, 0.] # du0 declared unlike ODE
tspan = (0., 1e6)

# First two are 'true' as out[1] and out[2] are determined by their changes
# Last one is 'false' as out[3] is a conservation equation
differential_vars = [true, true, false]

# Solve
dae_prob = DAEProblem(robertson_model, du0, u0, tspan, differential_vars = differential_vars)
sol = solve(dae_prob, IDA())

# Plot
plot(sol, xscale = :log10, tspan = (1e-6, 1e6), layout = (3, 1))