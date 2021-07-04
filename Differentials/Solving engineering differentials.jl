using DifferentialEquations
using Plots
using StaticArrays
using Sundials

# 1. Exponential growth and decay w/2 varying rates
function exponential_growth_and_decay(u, p, t)
    # Exponential growths
    dx = p[1] * u[1]
    dy = p[2] * u[2]

    # Exponential decays
    da = -p[1] * u[3]
    db = -p[2] * u[4]

    @SVector [dx, dy, da, db]
end

p = @SVector [0.1, 0.15]            # parameters
tspan = (0.0, 5.0)                  # time span
u0 = @SVector [1.0, 1.0, 1.0, 1.0]  # initial conditions

# Declare problem and solve it
exp_growth_and_decay_prob = ODEProblem(exponential_growth_and_decay, u0, tspan, p)
exp_growth_and_decay_sol = solve(exp_growth_and_decay_prob, alg_hint = :auto)

# Plot the solution i.e. show the decays/growths
plot(exp_growth_and_decay_sol)



