using Flux

# NEURAL NETWORKS ARE FUNCTION APPROXIMATORS

# LAYER 1 TO LAYER 2
# 10 input neurons
# 5 output neurons
# tanh as activation
# 5 * 10 matrix of weights
# 5 biases

# LAYER 2 TO LAYER 3
# 5 input neurons
# 5 output neurons
# tanh as activation
# 5 * 5 matrix of weights
# 5 biases

# LAYER 3 TO LAYER 4
# 5 input neurons
# 3 output neurons
# 3 * 5 matrix of weights
# 3 biases
neural_net = Chain(Dense(10, 5, tanh),
                   Dense(5, 5, tanh),
                   Dense(5, 3))


# LOSS FUNCTION
# 1. Take the output of the neural net (vector with 3 elements)
# 2. Multiply all elements by -1 -> absolute value them all -> square them all -> add them up
# 3. Repeat 1. and 2. for 100 inputs times and add them all up (this is the loss for a batch size of 100)
loss() = sum(sum(abs2, neural_net(rand(10)) .- 1) for i in 1:100)

loss() # Check the loss (not good as very high at the start)

ps = params(neural_net) # Get weights and biases of each layer

ps[1] # Weights of layer 1 to layer 2
ps[2] # Biases of layer 1
ps[3] # Weights of layer 2 to layer 3
ps[4] # Biases of layer 2
ps[5] # ...
ps[6] # ...

# Train the network
# 1. Feed in 10 inputs
# 2. Evaluate loss function once output is obtained
# 3. Evaluate derivative to find out what direction to change the parameters (weights and biases) to lessen loss
# 4. Check the loss
# 5. Repeat for 1000 iterations until low loss hopefully
Flux.train!(loss, ps, Iterators.repeated((), 1000), ADAM(0.1))

loss() # Look at loss, 0.001, close to 0, neural network did a good job

neural_net(rand(10)) # Testing an input, output vector has all entries close to 1
