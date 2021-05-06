
println("hello world")

#ARRAYS
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
