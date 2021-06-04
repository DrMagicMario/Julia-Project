#=
MLJWorkshop: https://www.youtube.com/watch?v=qSWbCn170HU&t=861s

-Universal interface for fitting, evaluating and tuning ML models
-Pre-processing tasks: data cleaning and type coercion
-model composition -> pipelining
=#

import Pkg 
Pkg.activate(".") 
#Pkg.add("MLJ")
#Pkg.add("MLJLinearModels")
Pkg.instantiate() # ~4-5 sec
using MLJ, MLJLinearModels

#Part1 - Data representation
folds(data, nfolds) = partition(1:nrows(data), (1/nfolds for i in 1:(nfolds-1))...)

mode11 = @load LinearRegressor pkg=MLJLinearModels
mode12 = @load LinearRegressor pkg=MLJLinearModels
judge = @load LinearRegressor pkg=MLJLinearModels


X=source()
y=source()

folds(X::AbstractNode, nfolds) = node(XX->folds(XX,nfolds),X)
MLJ.restrict(X::AbstractNode, f::AbstractNode, i) = node((XX,ff)->restrict(XX,ff,i),X,f)
MLJ.corestrict(X::AbstractNode, f::AbstractNode, i) = node((XX,ff)->corestrict(XX,ff,i),X,f)

f = folds(X,3)

m11 = machine(mode11, corestrict(X,f,1), corestrict(y,f,1))
m12 = machine(mode11, corestrict(X,f,2), corestrict(y,f,2))
m13 = machine(mode11, corestrict(X,f,3), corestrict(y,f,3))

y11=predict(ml1, restrict(X,f,1))
y12=predict(ml2, restrict(X,f,2))
y13=predict(ml3, restrict(X,f,3))

m21=machine(mode12, corestrict(X,f,1), corestrict(y,f,1))
m22=machine(mode12, corestrict(X,f,2), corestrict(y,f,2))
m23=machine(mode12, corestrict(X,f,3), corestrict(y,f,3))

y1_oos=vcat(y11,y12,y13)
y2_oos=vcat(y21,y22,y23)

x_oos = MLJ.table(hcat(y1_oos,y2_oos))

m_judge = machine(judge,x_oos,y)

m1 = machine(model11,X,y)
m2 = machine(model12,X,y)

y1 = predict(m1,X)
y2 = predict(m2,X)

X_judge = MLJ.table(hcat(y1,y2))
yhat = predict(m_judge, X_judge)

@from_network machine(Deterministic(), X, y; predict=yhat) begin
  mutable struct MyStack
    regressor1=mode11
    regressor2=mode12
    judge=judge
  end
end

my_stack=MyStack()

print("done")
=#
#Part2 - selecting, training and Evaluating models

#Part3 - Transformers and pipelines 

#Part4 - Tuning hyperparameters

#aPart5 - Advanced model composition
