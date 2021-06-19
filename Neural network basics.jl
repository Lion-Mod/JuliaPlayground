using Flux

# DENSE LAYER
# Level 1 - duplicating code a lot
weights1 = rand(3, 5)
biases1 = rand(3)
layer1(x) = weights1 * x .+ biases1

weights2 = rand(2, 3)
biases2 = rand(2)
layer2(x) = weights2 * x .+ biases2

model(x) = layer2(σ.(layer1(x)))


# Level 2 - making linear_layer/Dense layer to save copy pasting
function linear_layer(number_of_inputs, number_of_outputs)
    W = rand(number_of_inputs, number_of_outputs)
    b = rand(number_of_inputs)
    x -> W * x .+ b
end

layer1 = linear_layer(5, 3)
layer2 = linear_layer(3, 2)

model(x) = layer1(σ.(layer2(x)))


# Level 3 - using built in Dense function and Chain
model2 = Chain(Dense(5, 3, σ),
               Dense(3, 2),
               softmax)
