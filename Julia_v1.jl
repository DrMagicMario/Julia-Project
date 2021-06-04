#!/usr/local/bin/julia

#single-line comment

#=
Multi-line comment
=#

import Pkg
Pkg.activate(".")
Pkg.instantiate()

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
sum = 3+7; difference = 10 - 3; product = 20*5; quotient = 100/10; power = 10^2; modulus= 100%2;
@show sum; @show difference; @show product; @show quotient; @show power; @show modulus;

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

println("done")
