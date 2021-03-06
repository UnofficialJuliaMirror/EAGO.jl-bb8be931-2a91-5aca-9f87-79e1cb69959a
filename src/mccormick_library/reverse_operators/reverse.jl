empty(x::MC{N,T}) where {N,T <: RelaxTag} = MC{N}(Inf, -Inf, Interval{Float64}(Inf,-Inf),
                                                  SVector{N,Float64}(zeros(Float64,N)),
                                                  SVector{N,Float64}(zeros(Float64,N)), false)

include("arithmetic.jl")
include("exponential.jl")
include("extrema.jl")
include("hyperbolic.jl")
include("inverse_hyperbolic.jl")
include("inverse_trig.jl")
include("trig.jl")

#=
TO DO List:
    - Add nontrivial reverse McCormick contractors for abs, max, min, sin, cos, tan
=#
