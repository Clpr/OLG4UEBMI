"""
    EasyPlot

Masked APIs of plotting; based on PyPlot
"""
module EasyPlot
   import PyPlot  # based on PyPlot

# -----------------------------------------------------------------------------
# a public Dict of the attributes of fonts; modify a copy of it in functions
public_fontdict = Dict(
   "family" => "Times New Roman",
   "weight" => "normal",
   "color" => "black",
   "size" => 16
)



# ----------
"""
    Plot_SteadyState( t::Int, Dt::Dict, Dst::Dict, Pt::Dict, Ps::Dict, Pc::Dict, env::NamedTuple ; outpdf::Union{Nothing,String} = nothing )

plot 4 sub-plots: capital distribution, consumption distribution, labor distribution, asset & UEBMI-Indi distribution;
the keyword parameter outpdf= indicates whether to output to a pdf figure & the file directory,
it is nothing ("not output") by default;
"""
function Plot_SteadyState( t::Int, Dt::Dict, Dst::Dict, Pt::Dict, Ps::Dict, Pc::Dict, env::NamedTuple ;
      outpdf::Union{Nothing,String} = nothing, picsize::Tuple = (12,8) )
   # define an age-based x-axis
   local Xval = env.START_AGE : env.START_AGE + env.S - 1
   # plotting
   PyPlot.figure( figsize = picsize )
   PyPlot.subplot(2,2,1)
      PyPlot.plot(Xval, Dst[:𝒜][t,:] )
      PyPlot.xlabel("Age"); PyPlot.ylabel("Capital"); PyPlot.grid(true)
   PyPlot.subplot(2,2,2)
      PyPlot.plot(Xval, Dst[:c][t,:] )
      PyPlot.xlabel("Age"); PyPlot.ylabel("Consumption"); PyPlot.grid(true)
   PyPlot.subplot(2,2,3)
      PyPlot.plot(Xval[1:env.Sr], Dst[:Lab][t,:] )
      PyPlot.xlabel("Age"); PyPlot.ylabel("Labor"); PyPlot.grid(true)
   PyPlot.subplot(2,2,4)
      PyPlot.plot(Xval, Dst[:a][t,:] )
      PyPlot.plot(Xval, Dst[:Φ][t,:] )
      PyPlot.legend(["Asset","UEBMI-Indi"]); PyPlot.grid(true)
   PyPlot.tight_layout()

   if isa(outpdf, String)
   PyPlot.savefig( outpdf, format = "pdf" )
   end

   return nothing
end













































end  # module ends
#
