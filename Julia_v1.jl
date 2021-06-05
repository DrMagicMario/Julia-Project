#!/usr/local/bin/julia
#src: https://www.youtube.com/watch?v=8h8rQyEpiZA&list=WL&index=3&t=2959s


#single-line comment

#=
Multi-line comment
=#

import Pkg
Pkg.activate(".")
#Pkg.add.(["BenchmarkTools", "Colors", "Plots", "Example","Libdl","Statistics","PyCall","Conda"])
#Pkg.update();Pkg.build(); precompile;
Pkg.instantiate()
using BenchmarkTools, Colors, Plots, Example, ImageView, Libdl, Statistics, PyCall #, Conda

#= need this for PyCall to work
Conda.add("nomkl")
Conda.add("scikit-learn")
Conda.rm("mkl")
=#

#how to print
println("Julia 1.0 introduction...", 69)

#How to assign variables - julia can figure out the types
ans = 42
println(ans, " is a ", typeof(ans))

mypi=3.14159
println(mypi," is a ",typeof(mypi))

#generic assignment
cat = "smiley cat!"
println(cat ," is a ",typeof(cat))
cat = 1
println(cat ," is a ",typeof(cat))
bunny = 0
dog = -1
println(cat+dog==bunny)

#Syntax for basic math
mysum = 3+7; difference = 10 - 3; product = 20*5; quotient = 100/10; power = 10^2; modulus= 100%2;
@show mysum; @show difference; @show product; @show quotient; @show power; @show modulus;

#=
Strings
   - get a string
   - interpolation
   - concatenation
=#
println("\n"^5)

s1 = "a string"
s2 = """another string""" #can include other strings in this format
s3 = """an example of a string with "inner" strings"""

c1 = 'c' #single quotations for a character

@show s1; @show s2; @show s3; @show c1;

println(c1, " is a ", typeof(c1))
println(s1, " is a ", typeof(s1))
println(s3, " is a ", typeof(s3))

#=
interpolation -  use the $ symbol to insert existing variables into a stringand evaluate expressions within  a string
=#

name = "Jane"
fingers=10
toes=10
println("Hello my name is $name")
println("I have $fingers fingers and $toes toes")
println("In total I have $(fingers + toes) digits")

#=
concatenation - use string() funciton which converts non-strings to strings
              - use *
=#

s3 = "how many cats"
s4 = " is too many cats?"
cat = 10
println(string(s3,s4))
println(string("idk, but ", cat, " is too few"))

println(s3*s4) #power function in math really just calls * under the hood
println("he "^10) #same as "h "*10

#=
Data Structures
=#

###################### Tuples(immutable and ordered) #######################
println("\n"^5)
#creating a tuple via enclosing elements in () -> (item1,item2,...)
fav_animals=("cat","dog","raccoon")

#indexing through tuple
println(fav_animals[1]) #julia indexes start at 1

#creating a named tuple -> (name1=item1,name2=item2,...)
myfav_animals= (bird="penguin", mammal="monkey", marsupials="raccoon")
println(myfav_animals[1]) #still ordered
println(myfav_animals.mammal) #can access the name of an item)
#cant change elements of tuple: myfav_animals[1] = "bat"

##################### Dictionaries(mutable and unordered) #######################
println("\n"^5)
#create a Dictionary using Dict() to initialize an empty dict -> Dict(key1=>value1,key2=>value2,...)
phonebook = Dict("jenny"=>"123-1234","Arod"=>"321-4321")

#recover items in dict using the key 
println(phonebook["jenny"])

#add entry to dict
phonebook["Felix"] = "613-2187"
@show phonebook

#pop function - deletes key entry and returns its value
value = pop!(phonebook,"Felix")
println("poppped $value")
@show phonebook
#cant index into dicts: phonebook[1]

##################### Arrays(mutable and ordered) #######################
println("\n"^5)
#create an array using [] -> [item1.item2,...]
myfriends = ["john","mat","sarah","becky"]
println("myfriends: ",typeof(myfriends)) # Vector{String}
fibonacci = [1,1,2,3,5,8,13]
println("fibonacci: ",typeof(fibonacci)) #Vector{Int64}
mix = ["jose","mike",3,4]
println("mix: ",typeof(mix)) #Vector{Any}

println(myfriends[3]) #ordered
myfriends[3] = "ollie" #mutable
println(myfriends[3])

#julia has pop!() and push!() functions for arrays
push!(fibonacci,21)
@show fibonacci
val = pop!(fibonacci) #dont need to specify key since ordered
@show fibonacci
println("value popped: $val")

#2D arrays - manual init and rand()
favs = [["chocolate","chips","cookie"],["lion","cheetah","elephant"]]
numbers = [[1,2,3],[4,5,6],[7,8,9]]
@show favs; println(typeof(favs)); #Vector{String}
@show numbers; println(typeof(numbers)) #Vector{Int64}

rnd1 = rand(1:10,4,3); rnd2 = rand(1:10,4,3,2)
@show rnd1; println(typeof(rnd1)); #Matrix{Float64} - 2D array
@show rnd2; println(typeof(rnd2)); #Array{Float64, 3} - 3 indicates the dimensionality

#be careful when copying arrays 
somenum = fibonacci
somenum[1] = 404
@show fibonacci #fibonacci has been updated
fibonacci[1] = 1
somenum = copy(fibonacci) #correct way to copy arrays - Julia tries to use as little memory as possible so you need to specify if your copying it, otherwise all alias' are linkto the same memory address
somenum[1] = 404
@show fibonacci #fibonacci has been updated

#=
Loops - while
      - for
=#

############################ while ############################ 
println("\n"^5)

#= Function
  condition_var = init_value
  while condition
    loop body
  end
=#

function while_loop()
  n = 20
  while n > 10
    println(n)
    n-=1
  end
end

@time while_loop()

#= Global
  let condition_var = init_value
    while condition
      loop body
    end
  end
=#

@time begin
let n=0
  while n<10
    n+=1
    println(n)
  end
end
end

@time begin
myfriends = ["Ted","Robin","Chase","Lily"]
let i = 1
  while (i <= length(myfriends))
    println("Hi $(myfriends[i]), it's great to see you.")
    i+=1
  end
end
end

############################ for ############################ 
println("\n"^5)

#=
for var in loop_iterable
  loop body
end
=#

for n in 1:2:10 #steps of size 2 between 1-10
  println(n)
end

newfriends = ["Sonya","Derbatov", "Rooney", "Asimov"]
for friend in newfriends
  println("Hi $friend, it's great to see you")
end

#addition tables - entry is sum of its row and column indices
m,n= 5, 5
A = fill(0,(m,n))
@show A

for i in 1:n
  for j in 1:m
    A[i,j] = i+j
  end
end
@show A

#cool syntax
B = fill(0,(m,n))
for i in 1:n, j in 1:m
  B[i,j]=i+j
end
@show B

#cool-er syntax - list comprehensions
C = [i+j for i in 1:n, j in 1:m] #loop body to the left of loop declaration
@show C

println("A, B and C are the same?: $(A==B==C)")

#=
Conditionals - if 

syntax: 
if cond_1
  option 1
elseif cond_2
  option 2
else 
  option 3
end

=#
println("\n"^5)

#FizzBuzz test
N = rand(1:100000)
if(N%3==0) && (N%5==0) # '&&' = and
  println("FizzBuzz")
elseif N%3==0
  println("Fizz")
elseif N%5==0
  println("Buzz")
else
  println(N)
end

#= FizzBuzz test with ternary operators

syntax:
a ? b : c

equivalent to:
if a
  b
else 
  c
end

=#

x = rand(1:100)
y = rand(1:100)

@time begin
if x>y
  println(x)
else
  println(y)
end
end

@time begin
println(x>y ? x : y)
end

#short-circuit evaluation
#=
norm:
a & b

Short-circuit syntax:
a && b 
a || b

Motivation:
we shouldnt waste our time checking b if a is false
=#

@time false & (println("ampersand"); true) # evaluates b and prints 

@time false && (println("sc_ampersand"); true) # 0.0000 sec!
@time true && (println("sc_ampersand"); true) 

#if a is true julia will just evaluate and return b, even if its an error.
#x>0 && error("x cannot be greater than 0!")

# same thing with or
@time true || println("sc_or") # 0.0000 sec!
@time false || println("sc_or") 

#=
Functions - how to declare a function
          - Duck-typing
          - Mutating vs non-mutating functions
          - Higer order functions
=#

############################## declare a function #########################
println("\n"^5)

#option 1
function sayhi(name)
  println("Hi $name, nice to meet you")
end

function f(x)
  x^2
end

sayhi("looloo")
@show f(42)

#option2
sayhi2(name) = println("Hi $name. nice to meet you")
f2(x) = x^2
sayhi2("Ivac")
@show f2(42)

#option 3 - anonymous functions (lambda)
sayhi3 = name -> println("Hi $name, nice to meet you") #bind variable for later access 
f3 = x -> x^2
sayhi3("Kilo")
@show f3(42)

############################## duck typing ###################################
#=
Julia functions work on whatever inouts make sense
=#

sayhi(1337) #string interpolation defined for an int
A = rand(3,3)
f(A) # matrix operation ^ defined
f("hi") # ^ = string concat 
#f() will not work on a vector since ^ is not defined. 
v = rand(3)
#f(v)

############################## mutating vs non-mutating  ###################################
#=
Convention: functions followed by ! alter the contents of inputs
=#

v = [3,5,2]
@show sort(v)
@show v
@show sort!(v)
@show v


############################## Higher order functions  ###################################
#=
function that takes functions as arguments.

Map: applies a function to every element of the data structure passed to it
syntax:
  map(f, [1,2,3]) -> [f(1),f(2),f(3)]

Broadcast: generalization of map -> expands unary dimensions (dont need same size/type elements)
syntax:
  broadcast(f,[1,2,3])
  f.([1,2,3])
=#

@time begin
@show map(f,[1,2,3])

#using anon. functions
@show map(x->x^3, [1,2,3])
end

@time begin
@show broadcast(f,[1,2,3])
@show f.([1,2,3])
end

println()
R = [i+3*j for j in 0:2, i in 1:3]
@show f(R) #R*R
@show f.(R) #element wise ^2

#dot operator for broadcasting
println()
dot_op = R .+ 2 .* f.(R) ./ R
@show dot_op
brdcst = broadcast(x -> x+2*f(x)/x,R)
@show brdcst
println("dot_op = brdcst?: $(brdcst == dot_op)")

#=
Packages 
=#
println("\n"^5)

#Example.jl
hello("it's me mario")

palette = distinguishable_colors(100) #Colors.jl
@show palette; println()  #Plot.jl

#randomly checkered matrix 
@show rand(palette, 3, 3)

#=
Plotting - calling PyPlot
         - Plots.jl -> lets you specify which backend to use
=#
println("\n"^5)

glob_temps = [14.4, 14.5, 14.8, 15.2, 15.5, 15.8]
numpirates = [45000, 20000, 15000, 5000, 400, 17]

@show glob_temps
@show numpirates

gr()
function plot1()  
  display(plot(numpirates, glob_temps, label="line"))
  #the '!' indicates a mutating functione
  display(scatter!(numpirates, glob_temps, label="points")) #points will be added to existing plot
  display(xlabel!("Number of Pirates (Approximate)"))
  display(ylabel!("Global Temperature(C)"))
  display(title!("Influence of pirate population on global warming"))
  display(xflip!())
end

#@time plot1()

#=
using a different backend for plotting
  - unicodeplots()
  - pyplot(): broken ->  'INTEL MKL ERROR: Cannot load libmkl_intel_thread.1.dylib.'

pyplot()
display(plot(numpirates, glob_temps, label="line"))
#the '!' indicates a mutating functione
display(scatter!(numpirates, glob_temps, label="points")) #points will be added to existing plot
display(xlabel!("Number of Pirates (Approximate)"))
display(ylabel!("Global Temperature(C)"))
display(title!("Influence of pirate population on global warming"))
=#

function plot2()
  x = -10:10
  p1 = plot(x,x)
  p2 = plot(x,x.^2)
  p3 = plot(x,x.^3)
  p4 = plot(x,x.^4)
  display(plot(p1,p2,p3,p4,layout=(2,2),legend=false))
end

#@time plot2()

#=
  Julia is Fast!
=#
println("\n"^5)

bignum = rand(10^7) #1D vector of 10^7 random numbers, bwtween [0,1]

################################# Julia #########################################
j_bench = @benchmark sum($bignum)
@show j_bench
@show sum(bignum)
################################### C ##########################################

C_code = """
#include <stddef.h>
double c_sum(size_t n, double *x){
  double s = 0.0;
  for (size_t i = 0; i<n; ++i){
    s += x[i];
  }
  return s;
}
""";

const Clib = tempname() * "." * Libdl.dlext #make temporary file

#compile to a shared library by pipelining C_code to gcc -> need gcc installed
#using -ffast-math -> vectorized FLOPS (SIMD instructions)
open(`gcc -fPIC -O3 -msse3 -xc -shared -ffast-math -o $(Clib) -`, "w") do cmd 
  print(cmd,C_code)
end

#define julia function to call C function
c_sum(x::Array{Float64}) = ccall(("c_sum",Clib), Float64, (Csize_t, Ptr{Float64}), length(x), x)

c_bench = @benchmark c_sum($bignum)
@show c_bench
@show c_sum(bignum)

################################ Python ####################################

#built in sum function
py_sum = pybuiltin("sum")

py_bench = @benchmark py_sum($bignum)
@show py_bench
@show py_sum(bignum)


################################ Summary ##################################

d = Dict()
d["C_sum"] = minimum(c_bench.times)/ 1e6 #milliseconds 
d["J_sum"] = minimum(j_bench.times)/1e6
d["Py_sum"] = minimum(py_bench.times)/1e6
@show d

gr()
t = c_bench.times / 1e6 #milliseconds
m,sigma = minimum(t), std(t)

t2 = j_bench.times / 1e6 #milliseconds
m2,sigma2 = minimum(t2), std(t2)

t3 = py_bench.times / 1e6 #milliseconds
m3,sigma3 = minimum(t3), std(t3)

h = histogram(t, bins=500, xlim=(m-0.01,m+sigma), xlabel="milliseconds", ylabel="count",label="",title = "C_bench")
h2 = histogram(t2, bins=500, xlim=(m2-0.01,m2+sigma2), xlabel="milliseconds", ylabel="count",label="", title = "J_bench")
h3 = histogram(t3, bins=500, xlim=(m3-0.01,m3+sigma3), xlabel="milliseconds", ylabel="count",label="",title = "Py_bench")

display(plot(h,h2,h3,layout=(3,1),legend=false))

println("are all the sums the same?: $(c_sum(bignum) == sum(bignum) == pysum(bignum))")
println("difference between c_sum and j_sum: $(c_sum(bignum) - sum(bignum))")
println("difference between c_sum and py_sum: $(c_sum(bignum) - py_sum(bignum))")
println("difference between j_sums and py_sum: $(sum(bignum) - py_sum(bignum))")
println("done")
while true
  #exit()
  sleep(1)
end


