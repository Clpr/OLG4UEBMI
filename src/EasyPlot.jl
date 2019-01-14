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
      PyPlot.plot(Xval, Dst[:𝒜][t,:] .* Ps[:N][t,:] )
      PyPlot.xlabel("Age"); PyPlot.ylabel("k Distribution among ages"); PyPlot.grid(true)
   PyPlot.subplot(2,2,2)
      PyPlot.plot(Xval, Dst[:c][t,:] .* Ps[:N][t,:] )
      PyPlot.xlabel("Age"); PyPlot.ylabel("Consumption Distribution"); PyPlot.grid(true)
   PyPlot.subplot(2,2,3)
      PyPlot.plot(Xval[1:env.Sr], Dst[:Lab][t,:] .* Ps[:N][t,1:env.Sr] )
      PyPlot.xlabel("Age"); PyPlot.ylabel("Labor Distribution"); PyPlot.grid(true)
   PyPlot.subplot(2,2,4)
      PyPlot.plot(Xval, Dst[:a][t,:] .* Ps[:N][t,:] )
      PyPlot.plot(Xval, Dst[:Φ][t,:] .* Ps[:N][t,:] )
      PyPlot.legend(["Asset Distri","UEBMI-Indi Distri"]); PyPlot.grid(true)
   PyPlot.tight_layout()

   if isa(outpdf, String)
   PyPlot.savefig( outpdf, format = "pdf" )
   end

   return nothing
end
# ----------
"""
   Plot_PerformProfile( PerfLog::Dict ; startiter::Int = 1 )

Plots for the Dict of performance/convergence returned by EasySearch.Transition!(ReturnLog=true);
startiter= receives an integer indicating which round to start to plot;
returns nothing
"""
function Plot_PerformProfile( PerfLog::Dict ; startiter::Int = 1 )
   local XVAL = startiter:length(PerfLog[:K])
   PyPlot.figure( figsize = (8,4) )
   PyPlot.subplot(1,2,1)
      PyPlot.plot( XVAL, PerfLog[:K][XVAL], linewidth = 1.0 )
      PyPlot.title("Capital (K)")
      PyPlot.xlabel("Iteration Round")
      PyPlot.ylabel("Relative Error (%)")
      PyPlot.grid(true)
   PyPlot.subplot(1,2,2)
      PyPlot.plot( XVAL, PerfLog[:L][XVAL], linewidth = 1.0 )
      PyPlot.title("Labor (L)")
      PyPlot.xlabel("Iteration Round")
      PyPlot.grid(true)
   PyPlot.suptitle("Convergence Profile")
   # nominal returns
   return nothing
end
# ----------
"""
   Plot_Transition( t::Int, Dt::Dict, Dst::Dict, Pt::Dict, Ps::Dict, Pc::Dict, env::NamedTuple ; outpdf::Union{Nothing,String} = nothing, picsize::Tuple = (12,8) )


the keyword parameter outpdf= indicates whether to output to a pdf figure & the file directory,
it is nothing ("not output") by default;

Plots:
1. Y,   ΔY/Y,   LI/Y,   Δ(LI/Y)/(LI/Y)
2. r,   w̄,      K,      L
3. C,   I,      G,      SubstituionRate(Pension)
"""
function Plot_Transition( Dt::Dict, Dst::Dict, Pt::Dict, Ps::Dict, Pc::Dict, env::NamedTuple ;
   YearRange::Tuple = ( env.START_YEAR, env.START_YEAR + env.T - 1 ),  # the range of years to plot
   LineWidth::Float64 = 1.0,  # the width of lines to plot
   outpdf::Union{Nothing,String} = nothing, picsize::Tuple = (12,8) )
   # -----------------
   # assertion: years
   @assert( env.START_YEAR <= YearRange[1] < YearRange[2] < (env.START_YEAR + env.T - 1)  ,  "out of the range of years! Maximum T-1 years" )
   # prepare the values of X axis
   local tmpDisplaceYear = 1 - env.START_YEAR  # the shift to convert real years to index
   local XYEAR = YearRange[1]:YearRange[2]  # the years to plot on x-axis
   local XLOC = XYEAR .+ tmpDisplaceYear  # the index to slice data

   # prepare the growth rate of LI/Y
   local LI2Ygrowth = (Dt[:LI2Y][2:env.T] ./ Dt[:LI2Y][1:env.T-1] .- 1.0) .* 100

   # maximum layout
   local tmpLayout = (3,4)
   # Plotting
   PyPlot.figure( figsize = picsize )
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 1)
      PyPlot.plot( XYEAR, Dt[:Y][XLOC], linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("GDP")
      # ------------
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 2)
      PyPlot.plot( XYEAR, Dt[:GDPgrowth][XLOC], linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("GDP Growth Rate (%)")
      # ------------
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 3)
      PyPlot.plot( XYEAR, Dt[:LI2Y][XLOC] .* 100, linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("UEBMI-POOL Gaps / GDP (%)")
      # ------------
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 4)
      PyPlot.plot( XYEAR, LI2Ygrowth[XLOC], linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("Growth of UEBMI-POOL Gaps / GDP (%)")
      # ------------
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 5)
      PyPlot.plot( XYEAR, Dt[:r][XLOC] .* 100, linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("Net Interest Rate (%)")
      # ------------
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 6)
      PyPlot.plot( XYEAR, Dt[:w̄][XLOC], linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("Average Wage Level")
      # ------------
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 7)
      PyPlot.plot( XYEAR, Dt[:K][XLOC], linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("Aggregated Capital (K)")
      # ------------
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 8)
      PyPlot.plot( XYEAR, Dt[:L][XLOC], linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("Aggregated Labor (L)")
      # ------------
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 9)
      PyPlot.plot( XYEAR, Dt[:C][XLOC], linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("Aggregated Consumption (C)")
      # ------------
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 10)
      PyPlot.plot( XYEAR, Dt[:I][XLOC], linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("Aggregated Investment (I)")
      # ------------
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 11)
      PyPlot.plot( XYEAR, Dt[:G][XLOC], linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("Government Purchase (G)")
      # ------------
      PyPlot.subplot(tmpLayout[1],tmpLayout[2], 12)
      PyPlot.plot( XYEAR, Dt[:SubstiRat][XLOC] .* 100, linewidth = LineWidth )
         PyPlot.xlabel("Year"); PyPlot.grid(true)
         PyPlot.ylabel("Substitution Rate of Pension (%)")

      # tight layout
      PyPlot.tight_layout()

      # output
      if isa(outpdf, String)
      PyPlot.savefig( outpdf, format = "pdf" )
      end

   return nothing
end























end  # module ends
#
