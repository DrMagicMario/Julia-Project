
println("hello world")

#ARRAYS: are fully generic(parameterized). Types of elements are known at all times.
x =[1,2,3,4]
println(x)

#By default a function is generic: pass anything you want as an argument
function say_hello(name)
	println("hello ", name)
end

say_hello("chuck norris")
say_hello(x)

#Every value has a type
println(typeof(1.0)) #Float64
println(typeof(1)) #Int64
println(typeof(pi)) #Irrational
println(typeof(x)) #{Array64,1} 
println(typeof(1+im)) #Complex Int64

#Create own types to organize data:
struct Person
	name::String
end
alice = Person("Alice")
bob = Person("Bob")

#Julia types are lightweight: User built types inccur little overhead
println(sizeof(Person)==sizeof(Ptr{String})) #objects are referred to by pointers

#A main feature of Julia is Multiple Dispatch. As a result, Julia does not have Classes like Java, Python or C++.
greet(x,y) = println("$x greets $y")

greet(alice, bob)
greet(x,"hello world")

#Use abstract data types to organize the behaviour of related types
abstract type Animal end

#Concrete type can realize abtract types (Cat is a typeof Animal)
struct Cat <: Animal
	name::String
end 

#We can define new methods to previous functions for a more specific set of inputs 
greet(x::Person, y::Animal) = println("$x pats $y")
greet(x::Cat , y) = println("$x meows at $y")

fluffy = Cat("fluffy")
greet(alice, fluffy)
greet(fluffy, Cat)


struct Dog <: Animal
	name::String
end

greet(x::Dog, y) = println("$x barks at $y")
greet(x::Dog, y::Person) = println("$x licks $y's face")
greet(x::Dog, y::Dog) = println("$x sniffs $y's butt")

fido = Dog("fido")
rex = Dog("rex")

greet(alice, fido)
greet(rex, bob)
greet(rex, fido)

#always selects most specific match. If ambiguity exists an error will be thrown
abstract type DangerousAnimal <: Animal end
struct Tiger <: DangerousAnimal end
greet(alice, Tiger()) #no definition for greeting DangerousAnimal, uses Animal greet.

#Modules are used to organixze code into namespaces
module MyModule export hello, goodbye
	hello() = println("Hello World")
	goodbye() = println("Goodbye World")
end

MyModule.hello()
using .MyModule
goodbye()

#Julia has a built in package manager similar to pip from python. Furthermore, it manages your package environments (differing code bases using different versions of a pakage wont conflict). A package environment represents a single set of installed packages 

using Pkg
Pkg.activate(".") #creates environment for packages (only dowloads first time or if updates available))
using Pkg
Pkg.add("Colors") #package name Colors
run(`cat Project.toml`) #external command objetcs created using `` quotaions in the run() function
run(`cat Manifest.toml`) 

using Colors: RGB #only brings RGB into scope
println(RGB(1,0,0))

c = [RGB(i,j,0) for i in 0:0.1:1, j in 0:0.1:10]
println(typeof(c)) #Fully Generic arrays: Array{RGB{Float64},2}

println(c[8,2])
println(c[1,:])

#Broadcasting: the function f.(x) applies the function f to each element of x
#Julia guarantees loop fusion: loops over elements exactly once. Avoids using memory for intermediate results and is generally faster.   
using Colors: red,green,blue
println(red.(c)) #find all red components

using Colors: Gray
gray = Gray.(red.(c)) #From loop fusion: each element goes through two functions -> red and Gray 
println(gray) #change all red components to gray

#docstrings: include following quotations before function defintion
"""
hello world
"""
foo()=1

println(@doc foo) #@doc macro before function for more info

#Julia is fast

data = rand(Float64,10^7)

"""
@inbounds is a macro which disabes all bounds checking within a given block
@simd enables additional vector operations by allowing out-of-order execution
"""
function julia_sum(x)
	result = zero(eltype(x)) #creates vector of zeros with same type as x
	@inbounds @simd for element in x 
		result += element
	end
	return result
end

#implement sum in c using julia
C_code = """

#include <stddef.h>
//Note: Julia works for any argument type, but C only works for specified the argument types.

double c_sum(size_t n, double *x) {
	double s = 0.0;
	size_t i;
	for(i=0;i<n;++i){
		s+=x[i];
	}
	return s;
}

""";

#generate shared library
Pkg.add("Libdl")
using Libdl: dlext #gives correct file extension for a shared library on this platform
const Clib = tempname() * "." * dlext

#compiling the c code in julia: open command as a file and write into them
open(`gcc -fPIC -O3 -msse3 -xc -shared -o $Clib -`, "w") do cmd
	print(cmd, C_code) #adds our c code to end of the command
end

#create julia function using c function
c_sum(x::Array{Float64}) = ccall(("c_sum",Clib), Cdouble, (Csize_t, Ptr{Cdouble}), length(x),x)

#Benchmarking tools
Pkg.add("BenchmarkTools")
using BenchmarkTools
println(@btime julia_sum($data)) #@benchmark macro acts on a function and its elements (via $)
println(@btime c_sum($data))

#Julia's verison is completely generic!
println(julia_sum([1,2.5,pi]))

struct Point{T} #Point of type T (int, float etc.)
	x::T
	y::T
end

function Base.zero(::Type{Point{T}}) where {T}
	Point{T}(zero(T),zero(T))
end

Base.:+(p1::Point, p2::Point) = Point(p1.x+p2.x, p1.y+p2.y)

points = [Point(rand(),rand()) for _ in 1:10^7];

println(@btime julia_sum($points)) #you can use your generic functions with any structs with negligible overhead 


#Julia supporst Async/Sync cooperative tasks: great for IO and network requests
Pkg.add("HTTP")
using HTTP: request

@sync for i in 1:5
	@async begin
		println("starting request $i")
		r = request("GET", "https://jsonplaceholder.typicode.com/posts/$i")
		println("got response $i with status $(r.status)")
	end
end

#Multithreading: Julia can call parallelized code without over-subsrcibing CPU resources 
using Base.Threads: @spawn

function fib(n::Int)
	if n<2
		return n
	end
	#@spawn creates a new parallel task. tasks are lightweigth. Scheduling is done in depth-first manner, thus, not over-subscribing resource
	t = @spawn fib(n-2)
	return fib(n-1) + fetch(t)
end

println(fib(17))

#Julia does not copy values unless done so intentionally
"""
Invert the sign of vector x. operating inplace to avoid memory allocation
"""
function invert!(x::AbstractVector) #! is a convention to signal that contents will be modified
	for i in eachindex(x)
		x[i] = -x[i]
	end
	return x
end

x = [1,2,3]
println(@btime invert!($x))


 
#calling c funcitons: currently not supported on macOS
#"""
#calls the strcomp fucntion from libc.so.6
#"""
#function c_compare(x::String,y::String)
#Need to tell compiler the C function retuns an int (Cint) and expects two char * (Cstring) i    nputs.
#       ccall((:strcomp, "libc.so.6"),Cint,(Cstring,Cstring),x,y)
#end
#println(c_compare("hello","hello"))
#println(@btime c_compare($("hello"), $("hello"))) #minimal overhead to call c function
#
#Sum using python
#Pkg.add("PyCall") #something wrong with conda package manager
#using PyCall
# 
#py_math = pyimport("math")
#py_math.sin(1.0) #implemented in python
#
#the PyCall package lets you define python functions directly from julia
#
#py"""
#def sum(a):
#        s=0.0
#        for x in a;
#                s += x
#        return s
#"""     
#py_sum = py"""sum"""o
#ps = py_sum(data)
