# 0.2 short presentation for solving a model
expr_RunModel = :(begin;
   include("$(pwd())\\src\\proc_VarsDeclare.jl"); # use pwd() to avoid possible ambiguity of working directory
   include("$(pwd())\\src\\proc_InitPars.jl");
   Guess = ( r = 0.08, L = 0.2 );EasySearch.SteadyState!( 1, Guess, Dt, Dst, Pt, Ps, Pc, env, atol = 1E-8, MaxIter = 1000, PrintMode = "silent", MagicNum = 2.0, StepLen = 0.5 ); Guess = ( r = 0.12, L = 0.75 );
   EasySearch.SteadyState!( env.T, Guess, Dt, Dst, Pt, Ps, Pc, env, atol = 1E-6, MaxIter = 1000, PrintMode = "silent", MagicNum = 2.0, StepLen = 0.5 );
   PerfLog = EasySearch.Transition!( Dt, Dst, Pt, Ps, Pc, env, atol = 1E-3, MaxIter = 500, PrintMode = "silent", MagicNum = 2.0, StepLen = 0.7, ReturnLog = true );
   EasySearch.ProcAfterTransition!( Dt, Dst, Pt, Ps, Pc, env );
   end;
)
# 0.3 short presentation for extracting current demographic data
expr_GetDemogDat = :(
   Dict( "TotalPopu" => Dt[:N],
      "LaborPopu" => sum(Ps[:N][:,1:env.Sr],dims=2)[:],
      "WorkPopuRatio" => sum(Ps[:N][:,1:env.Sr],dims=2)[:] ./ sum(Ps[:N][:,1:env.S],dims=2)[:] ,
      "AgingPopu_65plus" => sum(Ps[:N][:, (65 - env.START_AGE + 1):env.S],dims=2)[:],
      "AgingPopuRatio" => sum(Ps[:N][:, (65 - env.START_AGE + 1):env.S],dims=2)[:] ./ sum(Ps[:N][:,1:env.S],dims=2)[:]
   )
)
# 0.4 a small function to reset env::NamedTuple
f_resetEnv( demogcsvpath::String ) = (
   T = 400, S = 80, Sr = 40, START_AGE = 20, START_YEAR = 1945,
   PATH_DEMOGCSV = demogcsvpath,
   PATH_WAGEPROFILE = "./data/WageProfileCoef.csv", PATH_MA2MB = "./data/MA2MBCoef.csv",
   PATH_M2C = "./data/M2C.csv", PATH_TFPGROW = "./data/tfpGrowthProfile.csv",
)
# 0.5 year range to plot
idx_year2plot = 2010:2110
idx_plot = idx_year2plot .- env.START_YEAR .+ 1
# -----------------------------------
# 0.6 run models under: base, low, high fertility assumptions, and save results
# NOTE: we will use these data to do plotting and other computations
   # 2.0.1 base (re-run it in case of not running SECTION 1)
   env = f_resetEnv( "./data/Demography_base.csv" )
   eval(expr_RunModel)
   dict_Demog_base = eval(expr_GetDemogDat)
   DatPkg_base = ( Dt = Dt, Dst = Dst, Pt = Pt, Ps = Ps, Pc = Pc )
   # 2.0.2 low fertility
   env = f_resetEnv( "./data/Demography_lowfertility.csv" )
   eval(expr_RunModel)
   dict_Demog_low = eval(expr_GetDemogDat)
   DatPkg_low = ( Dt = Dt, Dst = Dst, Pt = Pt, Ps = Ps, Pc = Pc )
   # 2.0.3 high fertility
   env = f_resetEnv( "./data/Demography_highfertility.csv" )
   eval(expr_RunModel)
   dict_Demog_high = eval(expr_GetDemogDat)
   DatPkg_high = ( Dt = Dt, Dst = Dst, Pt = Pt, Ps = Ps, Pc = Pc )



#
