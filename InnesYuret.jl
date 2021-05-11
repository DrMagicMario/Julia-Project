using Pkg
Pkg.activate(".")
Pkg.add("Knet")
Pkg.add("Images")
Pkg.add("MLDatasets")
Pkg.add("CUDA")
Pkg.add("Statistics")
Pkg.add("IterTools")

import Random
import CUDA

using Knet
using Images
using MLDatasets:MNIST
using CUDA
using Statistics
using IterTools

# Load MNIST data
xtrn,ytrn = MNIST.traindata(Float32); ytrn[ytrn.==0] .= 10
xtst,ytst = MNIST.testdata(Float32);  ytst[ytst.==0] .= 10
println.(summary.((xtrn,ytrn,xtst,ytst)));

# `minibatch` splits the data tensors to small chunks called minibatches.
# It returns an iterator of (x,y) pairs.
dtrn = minibatch(xtrn, ytrn, 100; xsize = (784,:), xtype = Array)
dtst = minibatch(xtst, ytst, 100; xsize = (784,:), xtype = Array)
println.(summary.((dtrn,dtst)));

# Each minibatch is an (x,y) pair where x is 100 (28x28) images and y are the corresponding 100 labels.
# Here is the first minibatch in the test set:
(x,y) = first(dtst)
println.(summary.((x,y)));

# Iterators can be used in for loops, e.g. `for (x,y) in dtrn`
# dtrn generates 600 minibatches of 100 images (total 60000)
# dtst generates 100 minibatches of 100 images (total 10000)
n = 0
for (x,y) in dtrn
    global n += 1
end
@show n

#model definition
struct Linear; w; b; end
model = Linear(0.01*randn(10,784),zeros(10)) #default constructor
Linear(i::Int,o::Int,scale=0.01) = Linear(scale*randn(o,i),zeros(o)) #define other constructors using concrete argument types
model = Linear(784,10)

(m::Linear)(x)= m.w*x.+m.b #turn linear instances into callable objects
x,y= first(dtst) #first minibatch from test
println(summary.((x,y))) 

println("correct predictions:")
println(Int.(y)')

println("model predictions:")
ypred = model(x)
println(ypred)

# We can calculate the accuracy of our model for the first minibatch
accuracy(model,x,y) = mean(y' .== map(i->i[1], findmax(Array(model(x)),dims=1)[2]))
println("Accuracy of model on minibatch:")
println(accuracy(model,x,y))

# We can calculate the accuracy of our model for the whole test set
accuracy(model,data) = mean(accuracy(model,x,y) for (x,y) in data)
println("Accuracy of model on whole test set:")
println(accuracy(model,dtst))

# ZeroOne loss (or error) is defined as 1 - accuracy
zeroone(x...) = 1 - accuracy(x...)
println("ZeroOne loss")
println(zeroone(model,dtst))

#for classification: negative log likelyhood (aka softmax): this is the average -log probability assigned to correct answers by the model

function nll(scores ,y)
	expscores = exp.(scores)
	probabilities = exp./sum(expscores,dims=1)
	answerprobs = (probabilities[y[i],i] for i in 1:length(y))
	mean(-log.(answerprobs))
end	

(m::Linear)(x,y) = nll(x,y)
model(x,y)

#Knet also has its own implementation
#(m::Linear)(x,y) = Knet.nll(m(x),y)
#model(x,y)


println("Done")


