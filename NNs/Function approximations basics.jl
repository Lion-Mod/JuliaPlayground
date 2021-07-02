using Flux
using Statistics
using Plots

# UNDERSTANDING ODEs
# u'(x) is a system of ODEs
# u'(x) = f(u, x)
# We want to find f(u, x)

# APPLYING IT TO NN
# The same can apply to NN'(x)
# NN'(x) = f(NN(x), x)
# We want to find NN(x)

# LOSS FUNCTION
# for some x's, ∑ (dNN(xᵢ)/dx - f(NN(xᵢ), xᵢ)) ^ 2

# Why square, so all terms are positive so each time there is a > 0 loss we ADD to the loss
# (negative would decrease it which is what want to do but correctly)
# Aim is to minimise loss to 0 to get the exact or approximate solution to the differential equation i.e. f(u, x)


# IN CODING

# Define neural network
NNODE = Chain(x -> [x], # Take in a scalar and transform it into an array
              Dense(1, 32, tanh),
              Dense(32, 1),
              first) # Take first value, i.e. return a scalar

# Define the differential
g(x) = x * NNODE(x) + 1f0

# Define epsilon
ϵ = sqrt(eps(Float32))

# Define loss function which is
# - The differential (approximation of the function)...
# - ...minus the ODE (u'(x)) which in this case if cos(2πx)...
# - ...squared...
# - ...all averaged across the batch.
loss() = mean(abs2(( ( g(x + ϵ) - g(x) ) / ϵ ) - cos(2 * π * x)) for x in 0:1f-2:1f0)

# Define optimiser
opt = Flux.Descent(0.01)

# Define data as it doesn't exist
data = Iterators.repeated((), 5000)

# Define callback to observe training
# - Every 500th iteration display the loss
num_of_iterations = 0
cb = function ()
    global num_of_iterations += 1
    if num_of_iterations % 500 == 0
        display(loss())
    end
end

# Train the neural network
Flux.train!(loss, Flux.params(NNODE), data, opt; cb = cb)

# Check it
t = 0:0.001:1.0
plot(t, g.(t), label = "neural network")
plot!(t, 1.0 .+ sin.(2 * pi .* t) / (2 * pi), label = "true")