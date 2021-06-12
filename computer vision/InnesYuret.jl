using Pkg
Pkg.activate(".")
Pkg.add("Knet")
Pkg.add("Images")
Pkg.add("ImageMagick")
Pkg.add("MLDatasets")
Pkg.add("CUDA")
Pkg.add("Statistics")
Pkg.add("IJulia")
Pkg.add("IterTools")
Pkg.add("Plots")

import Random
import CUDA

using Knet: Knet, AutoGrad, dir, Data, minibatch, Param, @diff, value, params, grad, progress, progress!, KnetArray, load143, save
using Images
using MLDatasets:MNIST
using CUDA
using Statistics
using IterTools
using Plots; default(fmt = :png)
using ImageMagick
using Base.Iterators: flatten
using IJulia

# Load MNIST data
xtrn,ytrn = MNIST.traindata(Float32); ytrn[ytrn.==0] .= 10
xtst,ytst = MNIST.testdata(Float32);  ytst[ytst.==0] .= 10
@show summary.((xtrn,ytrn,xtst,ytst))

# `minibatch` splits the data tensors to small chunks called minibatches.
# It returns an iterator of (x,y) pairs.
dtrn = minibatch(xtrn, ytrn, 100; xsize = (784,:), xtype = Array)
dtst = minibatch(xtst, ytst, 100; xsize = (784,:), xtype = Array)
@show summary.((dtrn,dtst))

# Each minibatch is an (x,y) pair where x is 100 (28x28) images and y are the corresponding 100 labels.
# Here is the first minibatch in the test set:
(x,y) = first(dtst)
@show summary.((x,y))

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
@show summary.((x,y)) 

println("correct predictions:")
@show Int.(y)'

println("model predictions:")
ypred = model(x)
@show ypred

# We can calculate the accuracy of our model for the first minibatch
accuracy(model,x,y) = mean(y' .== map(i->i[1], findmax(Array(model(x)),dims=1)[2]))
println("Accuracy of model on minibatch:")
@show accuracy(model,x,y)

# We can calculate the accuracy of our model for the whole test set
accuracy(model,data) = mean(accuracy(model,x,y) for (x,y) in data)
println("Accuracy of model on whole test set:")
@show accuracy(model,dtst)

# ZeroOne loss (or error) is defined as 1 - accuracy
zeroone(x...) = 1 - accuracy(x...)
println("ZeroOne loss")
@show zeroone(model,dtst)

#Knet has its own negative log likelyhood implementation
(m::Linear)(x,y) = Knet.nll(m(x),y)
@show model(x,y)

#if input is a dataset: compute average loss
(m::Linear)(data::Data) = mean(m(x,y) for (x,y) in data)
@show model(dtst)

#AutoGrad
println("\nAutoGrad:")
# Redefine the constructor to use Param's so we can compute gradients
Linear(i::Int,o::Int,scale=0.01) = Linear(Param(scale * randn(o,i)), Param(zeros(o))) 
# Set random seed for replicability
Random.seed!(226);

# Use a larger scale to get a large initial loss
model = Linear(784,10,1.0)

# We can still do predictions and calculate loss:
@show model(x,y)

# And we can do the same loss calculation also computing gradients:
J = @diff model(x,y)
@show J

param = params(J) |> collect
@show param

# To get the gradient of a parameter from J:
∇w = grad(J,model.w)
@show ∇w

# Note that each gradient has the same size and shape as the corresponding parameter:
@show ∇b = grad(J,model.b);

#training with stochastic gradient descent (SGD)
# Here is a single SGD update:
function sgdupdate!(func, args; lr=0.1)
    fval = @diff func(args...)
    for param in params(fval)
        ∇param = grad(fval, param)
        param .-= lr * ∇param
    end
    return value(fval)
end

# We define SGD for a dataset as an iterator so that:
# 1. We can monitor and report the training loss
# 2. We can take snapshots of the model during training
# 3. We can pause/terminate training when necessary
sgd(func, data; lr=0.1) =
    (sgdupdate!(func, args; lr=lr) for args in data)

# Let's train a model for 10 epochs to compare training speed on cpu vs gpu.
# progress!(itr) displays a progress bar when wrapped around an iterator like this:
# 2.94e-01  100.00%┣████████████████████┫ 6000/6000 [00:10/00:10, 592.96/s] 2.31->0.28
model = Linear(784,10)
@show model(dtst)
progress!(sgd(model, ncycle(dtrn,10)))
@show model(dtst);

# The training would go a lot faster on a GPU:
# 2.94e-01  100.00%┣███████████████████┫ 6000/6000 [00:02/00:02, 2653.45/s]  2.31->0.28
# To work on a GPU, all we have to do is convert Arrays to KnetArrays:
if CUDA.functional()  # returns true if there is a GPU
    atype = KnetArray{Float32}  # CuArrays are stored and operated in the GPU
    dtrn = minibatch(xtrn, ytrn, 100; xsize = (784,:), xtype=atype)
    dtst = minibatch(xtst, ytst, 100; xsize = (784,:), xtype=atype)
    Linear(i::Int,o::Int,scale=0.01) =
        Linear(Param(atype(scale * randn(o,i))),
               Param(atype(zeros(o))))

    model = Linear(784,10)
    @show model(dtst)
    progress!(sgd(model,ncycle(dtrn,10)))
    @show model(dtst)
end;

function trainresults(file, model)
    if (print("Train from scratch? (~77s) "); readline()[1]=='y')
        # We will train 100 epochs (the following returns an iterator, does not start training)
        training = sgd(model, ncycle(dtrn,100))
        # We will snapshot model and train/test loss and errors
        snapshot() = (deepcopy(model),model(dtrn),model(dtst),zeroone(model,dtrn),zeroone(model,dtst))
        # Snapshot results once every epoch (still an iterator)
        snapshots = (snapshot() for x in takenth(progress(training),length(dtrn)))
        # Run the snapshot/training iterator, reshape and save results as a 5x100 array
        lin = reshape(collect(flatten(snapshots)),(5,:))
        # Knet.save and Knet.load can be used to store models in files
        Knet.save(file,"results",lin)
    else
        isfile(file) || download("http://people.csail.mit.edu/deniz/models/tutorial/$file", file)
        lin = Knet.load143(file,"results")    
    end
    return lin
end

# 2.43e-01  100.00%┣████████████████▉┫ 60000/60000 [00:44/00:44, 1349.13/s]
@show lin = trainresults("lin113.jld2",Linear(784,10));

# Demonstrates underfitting: training loss not close to 0
# Also slight overfitting: test loss higher than train
trnloss,tstloss = Array{Float32}(lin[2,:]), Array{Float32}(lin[3,:])
display(plot([trnloss,tstloss],ylim=(.0,.4),labels=["trnloss" "tstloss"],xlabel="Epochs",ylabel="Loss"))

# this is the error plot, we get to about 7.5% test error, i.e. 92.5% accuracy
trnerr,tsterr = Array{Float32}(lin[4,:]), Array{Float32}(lin[5,:])
display(plot([trnerr,tsterr],ylim=(.0,.12),labels=["trnerr" "tsterr"],xlabel="Epochs",ylabel="Error"))

# Let us visualize the evolution of the weight matrix as images below
# Each row is turned into a 28x28 image with positive weights light and negative weights dark gray
for t in 10 .^ range(0,stop=log10(size(lin,2)),length=20) #logspace(0,2,20)
    i = ceil(Int,t)
    f = lin[1,i]
    w1 = reshape(Array(value(f.w))', (28,28,10))
    w2 = clamp.(w1.+0.5,0,1)
    #IJulia.clear_output(true)
    display([MNIST.convert2image(w2[:,:,i]) for i=1:10])
    display("Epoch $(i-1)")
    sleep(1) # (0.96^i)
end

println("Done")
