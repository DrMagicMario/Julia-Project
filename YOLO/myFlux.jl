#=
Machine Learning: Computer program whose performance on a task improves with experience. Dominant approach to machine learning: Feed large amounts of data to algorithm

 - data driven approach
 - learning = strengthing pathways

Artificial Neuron: input -> weight -> sum -> activation function -> output

*** activation functions ***
  - Mish
  - Tanh
  - ReLu
  - Sigmoid 
  - Leaky ReLu
  - SoftPlus
  - Bent Identity
  - Swish

*** Terms ***
Fully-connected: Each neuron in layer i is connected to every neuron in layer i+1.
  
Convolutional Layer: Each neurons in layer i+1 is connected to a subset (local receptive field) of neurons in layer i
  
Pooling: combines outputs of a local receptive fields to reduce data dimensions
    - stride: dictates how the field is moved accross an image
  
Max-Pooling: uses the max for each field
  
Feed-forward: neuron connections oriented from input -> output
  
n-layer: number of layers in a Artificial Neural Network (ANN)
    - deep neural network means n>>1
  
Bias: shifts output of activation function horizontally (idk why)

*** How does the network "learn" ***

---Supervised Learning
Setup: 
  -Training set of example input/output pairs [(x_i,y_i),(X_i, Y_i)]
Goal: 
  -find a function h_not() s.t. h_not(x_i) is a predictor for the corresponding value y_i.
Result:
  -finds relationship between input and output
    Continous Output -> Regression
    Discrete Output -> Classification

---Unsupervised Learning
Setup:
  -Unlabelled data -> Training set of x_i
Goal:
  -Find structure within the data
    *Clustering
    *Social Network Analysis
    *Market Segmentation
    *PCA
    *cocktail party (signal seperation) -> need to look into this: can distinguish a singular voice in a noisy room using just two mics -> intersymbol inteference applications?
  
 - Methods -
Cross-Entropy: Distance between predicted and real distiution is evaluated through a loss function -> minimize the loss function

Gradient Descent: Iterative optimization to adjust weight and bias resulting in lower loss

Batch Gradient Descent: use all examples in each iteration (slow on large data sets)

Stochastic Gradient Descent: Use one example in each iteration (fast, no vectorization)

Mini-batch Gradient Descent: use subset of examples in each iteration (allows vectorized approach = parallel computing). variant:  ADAM optimizaiton

Result:
  - Excellent generalization capabilites
  
-Overfitting-

problem: 
noise from the data is extracted (nothing meaningful represented) which limits generalization

solution(s): 
*Regularization -> incur a penalty on the loss function. 
*Early stopping.
*Increase depth (layers)
*decrease breadth (neurons per layer) -> be careful of vanishing/exploding gradients
*neural networks adapted to the type of data: CNN(spatially structered data -> images), RNN(chain structered data -> text)

 *** Computer Vision ***
instead of hardcoding all the ways pixels can be organized into a picture, we feed image/label pairs to a neural network where the nodes (neurons) apply the algorithms to "learn"

*** ML libraries ***
PyTorch - Facebook
TensorFlow - Google

Flux.jl - ML stack
Knet.jl - deep learning framework
TensorFlow.jl - wrapper for TensorFlow
Turing.jl - for probalistic machine learning 
MLJ.jl - framework to make ML models
ScikitLearn.jl - julia implementation of the scikit-learn API
=#

#Classifying MNIST:
using Pkg
Pkg.activate(".")
Pkg.add("Flux")
Pkg.add("Plots")
Pkg.add("MLDatasets")
Pkg.add("Parameters")
Pkg.add("Statistics")
Pkg.add("BSON")
@time using Flux,Plots, MLDatasets, Parameters, Base, Statistics, Printf, BSON

#=
@time img = Flux.Data.MNIST.images()
@time labl = Flux.Data.MNIST.labels()

###images###
println(eltype(img)) #element type: Matrix{ColorTypes.Gray{FixedPointNumbers.N0f8}}
println(typeof(img)) #object type: Vector{Matrix{ColorTypes.Gray{FixedPointNumbers.N0f8}}}
println(length(img)) # 1-D array of 60000 2-D array
println(img[1]) #each entry represents one training image: 28x28 greyscale values
println(img[1][1,1]) #top-left pixel
println(float(img[1][1,1]))

###labels###
println(eltype(labl)) #Int64
println(typeof(labl)) #Vector{Int64}
println(length(labl)) #1-D array of 60000 2-D array
println(labl[1]) #5
println(float(labl[1])) #5

#@async display(plot(plot(img[5]),plot(img[8]),plot(img[87]),plot(img[203])))
println(labl[5])
println(labl[8])
println(labl[87])
println(labl[203])

println(Flux.onehotbatch(labl[1:3],0:9)) #converts labels to one-hot encoded binary
println(Flux.onecold(Flux.onehotbatch(labl[1:3],0:9),0:9)) #converts one-hot encoded binary to labels
=#

#=
#some julia notes - splatting (common in Flux.jl)
println(+(2,3))
a = (2,3)
# +(a) wont work, +() requires a set of elements - a is a single element
println(+(a...)) #splatting - signifies zero or more elements after a 
println(a) #doesnt affect the contents of a


#ReLu activation function - rectifier activation function
x = -5:5
display(plot!(x,relu.(x),legend=false)) #relu from Flux.jl

#Softmax activiation function - normalizes a set of vectors between 0 and 1 which add up to 1 (probability distribution).
display(plot!(softmax(-5.0:0.5:5.0)))
=#

#Multi-layer perceptron Model Zoo
@with_kw mutable struct Args
  n::Float64 = 3e-4 #learning rate
  batchsize::Int = 1024 #batchsize
  epochs::Int = 10 #number of epochs
  device::Function = gpu #set as gpu if gpu availabe
end

function getdata(args)
  #loading dataset
  xtrain,ytrain = MLDatasets.MNIST.traindata(Float32)
  xtest,ytest = MLDatasets.MNIST.testdata(Float32)

  xtrain = Flux.flatten(xtrain)
  xtest = Flux.flatten(xtest)

  #One-hot encoding the labels
  ytrain,ytest = Flux.onehotbatch(ytrain,0:9), Flux.onehotbatch(ytest,0:9)

  #Batching
  train_data = Flux.Data.DataLoader((xtrain,ytrain),batchsize=args.batchsize,shuffle=true)
  test_data = Flux.Data.DataLoader((xtest,ytest),batchsize=args.batchsize)
  
  return train_data, test_data
end

function build_model(; imgsize=(28,28,1), nclasses=10)
  return Chain(
               Dense(prod(imgsize),32,relu),
               Dense(32,nclasses))
end

function loss_all(dataloader,model)
  l=0.0
  for(x,y) in dataloader
    l+=Flux.logitcrossentropy(model(x),y)
  end
  l/length(dataloader)
end

function accuracy(data_loader,model)
  acc=0
  for(x,y) in data_loader
    acc += sum(Flux.onecold(cpu(model(x))) .== Flux.onecold(cpu(y)))*1/size(x,2)
  end
  acc/length(data_loader)
end

function train(; kws...)
  #init model parameters
  args = Args(; kws...)
  #load data
  train_data,test_data = getdata(args)
  #construct model
  m=build_model()
  train_data = args.device.(train_data)
  test_data = args.device.(test_data)
  loss(x,y) = Flux.logitcrossentropy(m(x),y)

  #training
  evalcb = () -> @show(loss_all(train_data,m))
  opt = ADAM(args.n)

 Flux.@epochs args.epochs Flux.train!(loss, params(m), train_data, opt, cb = evalcb)

  @show accuracy(train_data, m)

end

@time train()


println("done")
while(true)
  sleep(1)
end

