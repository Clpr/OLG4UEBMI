
# SECTION 2: data & expr prepare (CONTRIBUTION RATIO INCREASE)
# -----------------------------------
# 0.2 short presentation for solving a model
expr_RunModel = :(begin;
   Guess = ( r = 0.08, L = 0.2 );EasySearch.SteadyState!( 1, Guess, Dt, Dst, Pt, Ps, Pc, env, atol = 1E-8, MaxIter = 1000, PrintMode = "silent", MagicNum = 2.0, StepLen = 0.5 ); Guess = ( r = 0.12, L = 0.75 );
   EasySearch.SteadyState!( env.T, Guess, Dt, Dst, Pt, Ps, Pc, env, atol = 1E-6, MaxIter = 1000, PrintMode = "silent", MagicNum = 2.0, StepLen = 0.5 );
   PerfLog = EasySearch.Transition!( Dt, Dst, Pt, Ps, Pc, env, atol = 1E-3, MaxIter = 500, PrintMode = "silent", MagicNum = 2.0, StepLen = 0.7, ReturnLog = true );
   EasySearch.ProcAfterTransition!( Dt, Dst, Pt, Ps, Pc, env );
   end;
)
# 0.3 short expr for extracting current demographic data
expr_GetDemogDat = :(
   Dict( "TotalPopu" => Dt[:N],
      "LaborPopu" => sum(Ps[:N][:,1:env.Sr],dims=2)[:],
      "AgingPopu_65plus" => sum(Ps[:N][:, (65 - env.START_AGE + 1):env.S],dims=2)[:],
      "AgingPopuRatio" => sum(Ps[:N][:, (65 - env.START_AGE + 1):env.S],dims=2)[:] ./ sum(Ps[:N][:,1:env.Sr],dims=2)[:]
   )
)
# 0.4 refresh demography to benchmark
f_resetEnv( demogcsvpath::String ) = (
   T = 400, S = 80, Sr = 40, START_AGE = 20, START_YEAR = 1945,
   PATH_DEMOGCSV = demogcsvpath,
   PATH_WAGEPROFILE = "./data/WageProfileCoef.csv", PATH_MA2MB = "./data/MA2MBCoef.csv",
   PATH_M2C = "./data/M2C.csv", PATH_TFPGROW = "./data/tfpGrowthProfile.csv",
)
env = f_resetEnv( "./data/Demography_base.csv" )
# 0.5 year range to plot
idx_year2plot = 2010:2110
idx_plot = idx_year2plot .- env.START_YEAR .+ 1
# 0.6 reforming macro
macro reform( ReformYear, ReformLev )
   return :( Pt[:ζ][ ( $ReformYear - env.START_YEAR + 1 ) : end] .= $ReformLev )
end # end macro


# SECTION 2: REFORM - contribution rate rising (Rising of firm’s contribution rate to UE-BMI)
# --------------------------------
# 2.1 prepare a dict to store result vars
# NOTE: each member of res_ContriRatRise is a list of lists,
# i.e. typeof(res_ContriRatRise) == Dict{String,Vector{Vector{Float64}}}
res_ContriRatRise = Dict(
   "gap/exp" => [],
   "gap/in" => [],
   "gap/gdp" => [],
   "gap/taxrev" => [],
)
# 2.2 initialize
reform_zeta_levs = [ 0.06, 0.08, 0.10, 0.12 ] # bench lev: 0.06
reform_zeta_stys = [ "-", "-.b", "--r", ":m" ] # style
# 2.3 run & save
for tmpzeta in reform_zeta_levs
   println("Current zeta: ",tmpzeta); println("-"^20);
   # ------ data loading
   include("$(pwd())\\src\\proc_VarsDeclare.jl"); # use pwd() to avoid possible ambiguity of working directory
   include("$(pwd())\\src\\proc_InitPars.jl");
   # ------ reform
   Pt[:ζ][ ( 2020 - env.START_YEAR + 1 ) : end ] .= tmpzeta
   # ------ evaluate model & save
   eval(expr_RunModel)
   push!( res_ContriRatRise["gap/exp"], 100 .* (Dt[:LI] ./ Dt[:AggPoolExp])[idx_plot] )
   push!( res_ContriRatRise["gap/in"] , 100 .* (Dt[:LI] ./ Dt[:AggPoolIn])[idx_plot] )
   push!( res_ContriRatRise["gap/gdp"], 100 .* (Dt[:LI] ./ Dt[:Y])[idx_plot] )
   push!( res_ContriRatRise["gap/taxrev"], 100 .* (Dt[:LI] ./ (Dt[:TRc] .+ Dt[:TRw]))[idx_plot] )
end # end loops






#
