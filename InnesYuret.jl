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

println("Done")


