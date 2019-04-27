
# SECTION 2: REFORM - contribution rate rising
# --------------------------
# NOTE: (CHINESE) 由于提高ζ表现出非线性的永久level冲击，所以画一下
#       "ζ -> 2020冲击"的图像
# NOTE: ζ从基准的0.06到0.12以栅格变化，记录4个经济变量在2020年的相对基准的偏移
# (records the 4 econ vars' deviation from benchmark in 2020)
# --------------------------
res_ContriRatRise = Dict(
   "zetalevels" => LinRange( 0.06, 0.08, 20 ),  # lattice sampling, from benchmark (0.06) to 0.12
   "gap/exp" => [],
   "gap/in" => [],
   "gap/gdp" => [],
   "gap/taxrev" => [],
)
tmpidx = 2020 - env.START_YEAR + 1
# evaluate models
for tmpzeta in res_ContriRatRise["zetalevels"]
   println("Current zeta: ",tmpzeta); println("-"^20); # info
   # ------ data loading
   include("$(pwd())\\src\\proc_VarsDeclare.jl");
   include("$(pwd())\\src\\proc_InitPars.jl");
   # ------ reform (the same as above)
   Pt[:ζ][ ( tmpidx ) : end ] .= tmpzeta
   # ------ evaluate model
   eval(expr_RunModel)
   # ------ save in percent format
   # NOTE: but now we only record the var's value in 2020
   push!( res_ContriRatRise["gap/exp"], 100 .* (Dt[:LI] ./ Dt[:AggPoolExp])[tmpidx] )
   push!( res_ContriRatRise["gap/in"] , 100 .* (Dt[:LI] ./ Dt[:AggPoolIn])[tmpidx] )
   push!( res_ContriRatRise["gap/gdp"], 100 .* (Dt[:LI] ./ Dt[:Y])[tmpidx] )
   push!( res_ContriRatRise["gap/taxrev"], 100 .* (Dt[:LI] ./ (Dt[:TRc] .+ Dt[:TRw]))[tmpidx] )
end





#
