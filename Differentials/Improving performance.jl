using DifferentialEquations
using Plots
using BenchmarkTools
using StaticArrays

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
  memory estimate:  1.35 MiB                 # nearly x10 less memory estimated than above
  allocs estimate:  11554                    # nearly x10 less allocations estimated than above
  --------------
  minimum time:     965.000 μs (0.00% GC)    # better estimated times
  median time:      1.347 ms (0.00% GC)
  mean time:        1.819 ms (8.99% GC)
  maximum time:     30.760 ms (89.40% GC)
  --------------
  samples:          2713
  evals/sample:     1
"""


# Why use static arrays?
# They are stack allocated (faster allocations) not heap allocated (slower allocations), up to 100 variable sized systems
# Other optimizations e.g. fast matrix multiplication
function lorenz_static(u, p, t)
    dx = 10.0 * (u[2] - u[1])
    dy = u[1] * (28.0 - u[3]) - u[2]
    dz = u[1] * u[2] - (8 / 3) * u[3]
    @SVector [dx,dy,dz] # static array
end

u0 = @SVector [1.0, 0.0, 0.0]
tspan = (0.0, 100.0)
prob = ODEProblem(lorenz_static, u0, tspan)
@benchmark solve(prob, Tsit5())

"""
BenchmarkTools.Trial: (even better than inplace)
  memory estimate:  446.75 KiB
  allocs estimate:  1314
  --------------
  minimum time:     440.700 μs (0.00% GC)
  median time:      534.200 μs (0.00% GC)
  mean time:        640.009 μs (5.76% GC)
  maximum time:     10.440 ms (94.71% GC)
  --------------
  samples:          7693
  evals/sample:     1
"""