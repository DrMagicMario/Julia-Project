using Pkg
Pkg.activate(".")
Pkg.add("Knet")
Pkg.add("IJulia")

using IJulia, Knet

notebook(dir=Knet.dir("dl-tutorial"))
