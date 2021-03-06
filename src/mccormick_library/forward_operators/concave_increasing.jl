for opMC in (:log, :log2, :log10, :log1p, :acosh, :sqrt)
   opMC_kernel = Symbol(String(opMC)*"_kernel")
   dop = diffrule(:Base, opMC, :midcc)
   MCexp = quote
              xL = x.Intv.lo
              xU = x.Intv.hi
              xLc = z.lo
              xUc = z.hi
              midcc, cc_id = mid3(x.cc, x.cv, xU)
              midcv, cv_id = mid3(x.cc, x.cv, xL)
              dcv = (xUc > xLc) ? (xUc - xLc)/(xU - xL) : 0.0
              convex = dcv*(midcv - xL)+ xLc
              concave = ($opMC)(midcc)
              concave_grad = mid_grad(x.cc_grad, x.cv_grad, cc_id)*$dop
              convex_grad = mid_grad(x.cc_grad, x.cv_grad, cv_id)*dcv
              convex, concave, convex_grad, concave_grad = cut(xLc, xUc, convex, concave, convex_grad, concave_grad)
              return MC{N, NS}(convex, concave, z, convex_grad, concave_grad, x.cnst)
        end
    dop = diffrule(:Base, opMC, :(x.cv))
    dMCexp = quote
               xL = x.Intv.lo
               xU = x.Intv.hi
               xLc = z.lo
               xUc = z.hi
               midcc, cc_id = mid3(x.cc, x.cv ,xU)
               midcv, cv_id = mid3(x.cc, x.cv ,xL)
               dcv = (xUc > xLc) ? (xUc - xLc)/(xU - xL) : 0.0
               if (xU - xL) == 0.0
                  convex = xLc
               else
                  convex = xLc*((xU - midcv)/(xU - xL)) + xUc*((midcv - xL)/(xU - xL))
               end
               concave = ($opMC)(midcc)
               convex_grad = ((xUc - xLc)/(xU - xL))*x.cv_grad
               concave_grad = ($dop)*x.cc_grad
               return MC{N, Diff}(convex, concave, z, convex_grad, concave_grad, x.cnst)
         end

     @eval @inline ($opMC_kernel)(x::MC{N, NS}, z::Interval{Float64}) where {N} = $MCexp
     @eval @inline ($opMC_kernel)(x::MC{N, Diff}, z::Interval{Float64}) where {N} = $dMCexp
     @eval @inline ($opMC)(x::MC) = ($opMC_kernel)(x, ($opMC)(x.Intv))
end
