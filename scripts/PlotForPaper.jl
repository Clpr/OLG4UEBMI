# this script does plotting for our paper
# ========================================
# NOTE: set pwd() as the root directory of the project to correctly cite paths!
   # --------- for plotting
   import EasyPlot  # custom plotting functions
   using PyPlot  # using PyPlot API
   # --------- for regression
   import Statistics  # std lib, basic stat methods
   import DataFrames  # data frame
   import GLM  # R-style API
   import RCall  # R calling APIs

# SECTION 0: data & expr prepare
# -----------------------------------
# 0.2 short presentation for solving a model
expr_RunModel = :(begin;
   include("$(pwd())\\src\\proc_VarsDeclare.jl"); # use pwd() to avoid possible ambiguity of working directory
   include("$(pwd())\\src\\proc_InitPars.jl");
   Guess = ( r = 0.08, L = 0.2 );EasySearch.SteadyState!( 1, Guess, Dt, Dst, Pt, Ps, Pc, env, atol = 1E-8, MaxIter = 1000, PrintMode = "final", MagicNum = 2.0, StepLen = 0.5 ); Guess = ( r = 0.12, L = 0.75 );
   EasySearch.SteadyState!( env.T, Guess, Dt, Dst, Pt, Ps, Pc, env, atol = 1E-6, MaxIter = 1000, PrintMode = "final", MagicNum = 2.0, StepLen = 0.5 );
   PerfLog = EasySearch.Transition!( Dt, Dst, Pt, Ps, Pc, env, atol = 1E-3, MaxIter = 500, PrintMode = "silent", MagicNum = 2.0, StepLen = 0.7, ReturnLog = true );
   EasySearch.ProcAfterTransition!( Dt, Dst, Pt, Ps, Pc, env );
   end;
)
# 0.3 short presentation for extracting current demographic data
expr_GetDemogDat = :(
   Dict( "TotalPopu" => Dt[:N],
      "LaborPopu" => sum(Ps[:N][:,1:env.Sr],dims=2)[:],
      "AgingPopu_65plus" => sum(Ps[:N][:, (65 - env.START_AGE + 1):env.S],dims=2)[:],
      "AgingPopuRatio" => sum(Ps[:N][:, (65 - env.START_AGE + 1):env.S],dims=2)[:] ./ sum(Ps[:N][:,1:env.Sr],dims=2)[:]
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







# SECTION 1: benchmark plotting
# ---------------------------------------
# 1.1 UE-BMI under benchmark scenario
# NOTE: it is a 4-subfigure figure
   # 1.1.1 second, define a temp expr to save code lines
   tmpexpr = :(
      xlabel("Year"); ylabel("Percentage (%)"); grid(true);
      xlim([ idx_year2plot[1] - 1, idx_year2plot[end] + 1 ]);
      plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* dict_Demog_base["AgingPopuRatio"][idx_plot], "--b" );
   )
   # 1.1.2 then, do plotting
   figure( figsize = (13,8) )
      subplot(2,2,1)  # gap / pooling account's expenditure
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* (DatPkg_base.Dt[:LI]./DatPkg_base.Dt[:AggPoolExp])[idx_plot] )
         eval(tmpexpr)
         legend( ("Pool Gap/Pool Benefits","Aging Population Share (65+)"), loc = "lower right")
      subplot(2,2,2)  # gap / pooling account's income
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* (DatPkg_base.Dt[:LI]./DatPkg_base.Dt[:AggPoolIn])[idx_plot] )
         eval(tmpexpr)
         legend( ("Pool Gap/Pool Incomes","Aging Population Share (65+)"), loc = "lower right")
      subplot(2,2,3)  # gap / GDP
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* (DatPkg_base.Dt[:LI]./DatPkg_base.Dt[:Y])[idx_plot] )
         eval(tmpexpr)
         legend( ("Pool Gap/GDP","Aging Population Share (65+)"), loc = "right")
      subplot(2,2,4)  # gap / fiscal incomes
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* (DatPkg_base.Dt[:LI]./(DatPkg_base.Dt[:TRw] .+ DatPkg_base.Dt[:TRc]))[idx_plot] )
         eval(tmpexpr)
         legend( ("Pool Gap/Tax Revenues","Aging Population Share (65+)"), loc = "right")      tight_layout()  # tight layout of the figure
   # 1.1.3 finally, save the figure as a pdf file
   savefig( "./output/BenchProfile.pdf", format = "pdf" )
# -----------------------------------------
# 1.2 simulation v.s. accounting
   # 1.2.1 do underlying plotting & read in accounting data
   EasyPlot.Plot_Calibrate( DatPkg_base.Dt, DatPkg_base.Dst, DatPkg_base.Pt, DatPkg_base.Ps, DatPkg_base.Pc, env,
      YearRange = ( 2010, 2050 ), LineWidth = 1.0,   outpdf = nothing, picsize = (17.2,5.8)
   )
   tmpDat = EasyIO.readcsv("./data/Calib_统筹账户收支核算结果v3_190403.csv")
   tmpEndTime = 40 + 2
   # 1.2.2 decoration (NOTE: do not new a figure GUI, just decorate the current one)
   subplot(1,2,1)
      plot( tmpDat[2:tmpEndTime,1] , 100.0 .* tmpDat[2:tmpEndTime,4] ./ tmpDat[2:tmpEndTime,2] , "-.r" )
      legend(["Benchmark Simulation","Accounting Results"])
   subplot(1,2,2)
      plot( tmpDat[2:tmpEndTime,1] , 100.0 .* tmpDat[2:tmpEndTime,4] ./ tmpDat[2:tmpEndTime,3] , "-.r" )
      legend(["Benchmark Simulation","Accounting Results"])
   tight_layout()
   # 1.2.3 save figure
   savefig( "./output/BenchmarkCpAccount.pdf", format = "pdf" )








# SECTION 2: fertility shock plotting
# ---------------------------------------
# ---------------------------------------
# 2.1 Fertility shocks and UE-BMI
   # 2.1.1 a temp macro for fast plotting
   macro fastexpr( Ylab::String, Loc::String )
      return :(
         grid(true); xlabel("Year"); ylabel($Ylab);
         legend(( "Benchmark", "High Fertility", "Low Fertility" ), loc = $Loc );
      )
   end
   # 2.1.2 do plotting
   # NOTE: it is a 4-subfigure figure
   figure(figsize = (13,8))
      subplot(2,2,1)  # gap / pool expenditure
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:AggPoolExp] )[idx_plot]  );
         plot( DatPkg_high.Dt[:Year][idx_plot], 100 .* ( DatPkg_high.Dt[:LI] ./ DatPkg_high.Dt[:AggPoolExp] )[idx_plot], "-.b" );
         plot( DatPkg_low.Dt[:Year][idx_plot], 100 .* ( DatPkg_low.Dt[:LI] ./ DatPkg_low.Dt[:AggPoolExp] )[idx_plot], "--r" );
         @fastexpr( "Pool Gap / Pool Expenditures (%)", "upper left" )
      subplot(2,2,2)  # gap / pool income
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:AggPoolIn] )[idx_plot]  );
         plot( DatPkg_high.Dt[:Year][idx_plot], 100 .* ( DatPkg_high.Dt[:LI] ./ DatPkg_high.Dt[:AggPoolIn] )[idx_plot], "-.b" );
         plot( DatPkg_low.Dt[:Year][idx_plot], 100 .* ( DatPkg_low.Dt[:LI] ./ DatPkg_low.Dt[:AggPoolIn] )[idx_plot], "--r" );
         @fastexpr( "Pool Gap / Pool Incomes (%)", "upper left" )
      subplot(2,2,3)  # gap / GDP
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:Y] )[idx_plot]  );
         plot( DatPkg_high.Dt[:Year][idx_plot], 100 .* ( DatPkg_high.Dt[:LI] ./ DatPkg_high.Dt[:Y] )[idx_plot], "-.b" );
         plot( DatPkg_low.Dt[:Year][idx_plot], 100 .* ( DatPkg_low.Dt[:LI] ./ DatPkg_low.Dt[:Y] )[idx_plot], "--r" );
         @fastexpr( "Pool Gap / GDP (%)", "upper left" )
      subplot(2,2,4)  # gap / tax revenues
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ (DatPkg_base.Dt[:TRw] .+ DatPkg_base.Dt[:TRc]) )[idx_plot]  );
         plot( DatPkg_high.Dt[:Year][idx_plot], 100 .* ( DatPkg_high.Dt[:LI] ./ (DatPkg_high.Dt[:TRw] .+ DatPkg_high.Dt[:TRc]) )[idx_plot], "-.b" );
         plot( DatPkg_low.Dt[:Year][idx_plot], 100 .* ( DatPkg_low.Dt[:LI] ./ (DatPkg_low.Dt[:TRw] .+ DatPkg_low.Dt[:TRc]) )[idx_plot], "--r" );
         @fastexpr( "Pool Gap / Tax Revenues (%)", "upper left" )
      tight_layout()
   # 2.1.3 save figure
   savefig( "./output/FertilityShockProfile.pdf", format = "pdf" )










# SECTION 3: other visualization in BENCHMARK
# ----------------------------------------------
# 3.1 benchmark: correlations (during plotting years)
   println(
      "Cor between Aging Population Ratio & gap/pool expenditures: ",
      Statistics.cor( dict_Demog_base["AgingPopuRatio"][idx_plot], (DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:AggPoolExp])[idx_plot] )
   )
   println(
      "Cor between Aging Population Ratio & gap/pool incomes: ",
      Statistics.cor( dict_Demog_base["AgingPopuRatio"][idx_plot], (DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:AggPoolIn])[idx_plot] )
   )
   println(
      "Cor between Aging Population Ratio & gap/GDP: ",
      Statistics.cor( dict_Demog_base["AgingPopuRatio"][idx_plot], (DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:Y])[idx_plot] )
   )
   println(
      "Cor between Aging Population Ratio & gap/tax revenues: ",
      Statistics.cor( dict_Demog_base["AgingPopuRatio"][idx_plot], (DatPkg_base.Dt[:LI] ./ ( DatPkg_base.Dt[:TRw] .+ DatPkg_base.Dt[:TRc] ) )[idx_plot] )
   )
# 3.2 regression on Aging population share
   # 3.2.1 prepare regression data frame
   df_Reg = DataFrames.DataFrame(
      # ------------- dependent
      Gap2Exp = 100 .* DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:AggPoolExp],
      Gap2In = 100 .* DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:AggPoolIn],
      Gap2GDP = 100 .* DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:Y],
      Gap2TaxRev = 100 .* DatPkg_base.Dt[:LI] ./ (DatPkg_base.Dt[:TRw] .+ DatPkg_base.Dt[:TRc]),
      # ------------- independent
      Year = DatPkg_base.Dt[:Year],
      AgePopuRat = 100 .* dict_Demog_base["AgingPopuRatio"],
   )[idx_plot,:]  # only regress plotting periods (2010 ~ 2110)
   # 3.2.2 linear regression
   mod_ols = GLM.glm( GLM.@formula( Gap2Exp ~ 1 + Year + AgePopuRat ), df_Reg, GLM.Normal() )
   println(mod_ols)
# 3.3 time series analysis (via R language API)









# SECTION 4: GAP & interest rate
# ----------------------------------------------
# 4.0 fast macro
   tmpexpr = :(
      xlabel("Year"); ylabel("Percentage (%)"); grid(true);
      xlim([ idx_year2plot[1] - 1, idx_year2plot[end] + 1 ]);
      # plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* dict_Demog_base["AgingPopuRatio"][idx_plot], "--b" );
   )

# 4.1 FIGURE: fertility & interest rate
   figure(figsize = (8,6))
      plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* DatPkg_base.Dt[:r][idx_plot] )
      plot( DatPkg_high.Dt[:Year][idx_plot], 100 .* DatPkg_high.Dt[:r][idx_plot], "-.b" )
      plot( DatPkg_low.Dt[:Year][idx_plot], 100 .* DatPkg_low.Dt[:r][idx_plot], "--r" )
      eval(tmpexpr)
      legend(("Benchmark","High Fertility","Low Fertility"),loc = "upper left");
      tight_layout()
# 4.2 FIGURE: GAP/TAX-REV & interest rate (Benchmark fertility)
   figure(figsize = (13,6))
      subplot(1,2,1)
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* DatPkg_base.Dt[:r][idx_plot] )
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ (DatPkg_base.Dt[:TRw] .+ DatPkg_base.Dt[:TRc]) )[idx_plot], "-.b"  );
         eval(tmpexpr)
         legend(("Net Capital Returns","Gap / Tax Revenues"), loc = "upper left")
      subplot(1,2,2)
         scatter( 100 .* DatPkg_base.Dt[:r][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ (DatPkg_base.Dt[:TRw] .+ DatPkg_base.Dt[:TRc]) )[idx_plot] )
         xlabel("Net Capital Returns (%)"); ylabel("Gap / Tax Revenues (%)"); grid(true);
      tight_layout()





w



















#
