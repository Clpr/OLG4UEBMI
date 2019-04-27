
# SECTION 3: DECREASE INDI-ACCOUNT'S INCOME
# --------------------------------
# NOTE: we use the expr, macros in SECTION 2

# 3.1 the parameter combinations of this section's reforms
ReformYear = 2020 - env.START_YEAR + 1
idx_plot = (2010:2110) .- env.START_YEAR .+ 1
reform_indiacct_expr = Dict(
   "Benchmark" => :(
      nothing
   ),  # benchmark, no change
   "NoFirmTrans2Indi" => :(
      Pt[:𝕒][ReformYear:end] .= 0.0
   ),  # firm's contrib now only go to pool & retirees's indi acct
   "NoFirmTrans2Retiree" => :(
      # Pt[:𝕒][ReformYear:end] .= 0.0;
      Pt[:𝕓][ReformYear:end] .= 0.0;
   ),  # canceling transfer payment to retirees
   "Everything2Pool" => :(
      # it is equvalent to the parameters let new piM = old piM, where new phi = 0
      tmpNewZeta = (1.0 + Pt[:z][ReformYear-1] * Pt[:η][ReformYear-1]) * (Pt[:ζ][ReformYear-1] + Pt[:ϕ][ReformYear-1]) ;
      tmpNewZeta /= 1.0 + Pt[:z][ReformYear-1] * Pt[:η][ReformYear-1] - Pt[:ϕ][ReformYear-1] ;
      # let new phi = 0, bba = 0, bbb = 0
      Pt[:ϕ][ReformYear:end] .= 0.0;
      Pt[:𝕒][ReformYear:end] .= 0.0;
      Pt[:𝕓][ReformYear:end] .= 0.0;
      # set new zeta to equilize the old piM & new piM
      Pt[:ζ][ReformYear:end] .= tmpNewZeta;
   ),  # hold personal contributions, both personal & firm's contrib all go to pool, i.e. no individual account
   "JustKillIndiAcct" => :(
      Pt[:ϕ][ReformYear:end] .= 0.0;
      Pt[:𝕒][ReformYear:end] .= 0.0;
      Pt[:𝕓][ReformYear:end] .= 0.0;
   ) # just kill individual accounts but change nothing (no contribution, no transfer payments, no benefits)
)

# 3.2 spaces to store results
res_IndiInDesc = Dict(
   "reformNames" => [ "Benchmark", "NoFirmTrans2Indi",       "NoFirmTrans2Retiree",     "Everything2Pool",                      "JustKillIndiAcct" ],
   "plotlegends" => [ "Benchmark", "No transfer to workers", "No transfer to retirees", "Keep contribution but all to pooling", "Canceling individual accounts" ],
   "plotstyles" => [ "-", "-.b", "-r", ":m", "--c" ],
   "gap/exp" => [],
   "gap/in" => [],
   "gap/gdp" => [],
   "gap/taxrev" => [],
   "Dt" => [],
)

# 3.3 evaluate reforms
for tmpreform in res_IndiInDesc["reformNames"]
   # ------ data loading
   include("$(pwd())\\src\\proc_VarsDeclare.jl"); # use pwd() to avoid possible ambiguity of working directory
   include("$(pwd())\\src\\proc_InitPars.jl");
   # ------ reform
   eval( reform_indiacct_expr[tmpreform] )
   # ------ evaluate model & save
   eval(expr_RunModel)
   push!( res_IndiInDesc["gap/exp"], 100 .* (Dt[:LI] ./ Dt[:AggPoolExp])[idx_plot] )
   push!( res_IndiInDesc["gap/in"] , 100 .* (Dt[:LI] ./ Dt[:AggPoolIn])[idx_plot] )
   push!( res_IndiInDesc["gap/gdp"], 100 .* (Dt[:LI] ./ Dt[:Y])[idx_plot] )
   push!( res_IndiInDesc["gap/taxrev"], 100 .* (Dt[:LI] ./ (Dt[:TRc] .+ Dt[:TRw]))[idx_plot] )
   push!( res_IndiInDesc["Dt"], copy(Dt) )
end # end loops





#
