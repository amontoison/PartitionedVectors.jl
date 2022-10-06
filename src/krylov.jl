import LinearAlgebra: axpy!, axpby!
import Krylov.CgSolver
import Base.setproperty!

function axpy!(s::Y, x::PartitionedVector{T}, y::PartitionedVector{T}) where {T<:Number,Y<:Number}
  axpy!(s, x, y, Val(x.simulate_vector), Val(y.simulate_vector))
end

function axpy!(s::Y, x::PartitionedVector{T}, y::PartitionedVector{T}, ::Val{true}, ::Val{true}) where {T<:Number,Y<:Number}
  y .+= s .* x
  return y
end

function axpy!(s::Y, x::PartitionedVector{T}, y::PartitionedVector{T}, ::Val{false}, ::Val{true}) where {T<:Number,Y<:Number}
  build!(x)
  build!(y)
  xvector = x.epv.v
  yvector = y.epv.v
  epv_from_v!(y.epv, s .* xvector .+ yvector)
  return y
end

function axpy!(s::Y, x::PartitionedVector{T}, y::PartitionedVector{T}, ::Val{false}, ::Val{false}) where {T<:Number,Y<:Number}
  y .+= s .* x
  return y
end

function axpby!(s::Y1, x::PartitionedVector{T}, t::Y2, y::PartitionedVector{T}) where {T<:Number,Y1<:Number,Y2<:Number}
  axpby!(s, x, t, y, Val(x.simulate_vector), Val(y.simulate_vector))
end

function axpby!(s::Y1, x::PartitionedVector{T}, t::Y2, y::PartitionedVector{T}, ::Val{false}, ::Val{true}) where {T<:Number,Y1<:Number,Y2<:Number}
  build!(x)
  build!(y)
  xvector = x.epv.v
  yvector = y.epv.v
  epv_from_v!(y.epv, s .* xvector .+ yvector .* t)
  return y
end

function axpby!(s::Y1, x::PartitionedVector{T}, t::Y2, y::PartitionedVector{T}, ::Val{false}, ::Val{false}) where {T<:Number,Y1<:Number,Y2<:Number}
  y .= x .* s .+ y .* t
  return y
end

function axpby!(s::Y1, x::PartitionedVector{T}, t::Y2, y::PartitionedVector{T}, ::Val{true}, ::Val{true}) where {T<:Number,Y1<:Number,Y2<:Number}
  y .= x .* s .+ y .* t
  return y
end

function CgSolver(pv::PartitionedVector{T}) where T  
  Δx = similar(pv; simulate_vector=true)
  Δx .= (T)(0) # by setting Δx .= 0, we ensure that at each iterate the initial point `r` is 0.
  x  = similar(pv; simulate_vector=true)
  x .= (T)(0)
  r  = similar(pv; simulate_vector=true)
  r .= (T)(0) # will be reset at each cg! call to 0 because of mul!(r,A,Δx)
  p  = similar(pv; simulate_vector=true)
  p .= (T)(0)
  Ap = similar(pv; simulate_vector=false)
  Ap .= (T)(0)
  z = similar(pv; simulate_vector=true)
  z .= (T)(0)
  stats = Krylov.SimpleStats(0, false, false, T[], T[], T[], "unknown")
  solver = Krylov.CgSolver{T,T,PartitionedVector{T}}(Δx, x, r, p, Ap, z, true, stats)
  return solver
end

# This way, solver.warm_start stays true at all time.
# It prevents the else case where r .= b at the beginning of cg!.
# r is supposed to simulate while b is not.
function setproperty!(solver::CgSolver{T,T,PartitionedVector{T}}, sym::Symbol, val::Bool) where T
  if sym === :warm_start
    return nothing
  else
    setfield!(solver, sym, val)
  end
end 
