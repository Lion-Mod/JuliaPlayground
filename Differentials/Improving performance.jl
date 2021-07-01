using DifferentialEquations
using Plots
using BenchmarkTools

u0 = [1.0;0.0;0.0]
tspan = (0.0, 100.0)

# Two issues
# 1. no cache array
# 2. not inplace (note no !)
function high_allocations_lorenz(u, p, t)
    dx = 10.0 * (u[2] - u[1])
    dy = u[1] * (28.0 - u[3]) - u[2]
    dz = u[1] * u[2] - (8 / 3) * u[3]
    [dx, dy, dz]
end

prob = ODEProblem(high_allocations_lorenz, u0, tspan)
@benchmark solve(prob, Tsit5())

"""
BenchmarkTools.Trial:
  memory estimate:  10.81 MiB
  allocs estimate:  100152
  --------------
  minimum time:     5.462 ms (0.00% GC)
  median time:      8.864 ms (0.00% GC)
  mean time:        10.939 ms (12.90% GC)
  maximum time:     38.827 ms (53.71% GC)
  --------------
  samples:          455
  evals/sample:     1
"""


# Two improvements
# 1. use inplace function via !
# 2. use du as a cache array rather than creating an array [dx, dy, dz] each time
function low_allocations_lorenz!(du, u, p, t)
    du[1] = 10.0 * (u[2] - u[1])
    du[2] = u[1] * (28.0 - u[3]) - u[2]
    du[3] = u[1] * u[2] - (8 / 3) * u[3]
end

prob = ODEProblem(low_allocations_lorenz!, u0, tspan)
@benchmark solve(prob, Tsit5())

"""
BenchmarkTools.Trial:
  memory estimate:  1.35 MiB                 # nearly x10 less memory estimated
  allocs estimate:  11554                    # nearly x10 less allocations estimated
  --------------
  minimum time:     965.000 μs (0.00% GC)    # better estimated times
  median time:      1.347 ms (0.00% GC)
  mean time:        1.819 ms (8.99% GC)
  maximum time:     30.760 ms (89.40% GC)
  --------------
  samples:          2713
  evals/sample:     1
"""