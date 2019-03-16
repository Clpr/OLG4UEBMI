# Sensitivity Analysis (SA)
# ===========================
# NOTE: run this script after evaluating main.jl under benchmark scenario



# ============================================
# SECTION: define a macro to solve a model 定义一个求解一遍模型的macro()
macro quickproc_SolveModel()
    # NOTE: PrintMode in ["full", "concise", "final", "silent"]
       Guess = ( r = 0.08, L = 0.2 )
       @time EasySearch.SteadyState!( 1, Guess, Dt, Dst, Pt, Ps, Pc, env,
          atol = 1E-8, MaxIter = 1000, PrintMode = "final", MagicNum = 2.0, StepLen = 0.5 )
       Guess = ( r = 0.12, L = 0.75 )
       @time EasySearch.SteadyState!( env.T, Guess, Dt, Dst, Pt, Ps, Pc, env,
          atol = 1E-6, MaxIter = 1000,
          PrintMode = "final", MagicNum = 2.0, StepLen = 0.5 )
       @time PerfLog = EasySearch.Transition!( Dt, Dst, Pt, Ps, Pc, env,
          atol = 1E-3, MaxIter = 500,
          PrintMode = "full", MagicNum = 2.0, StepLen = 0.7, ReturnLog = true )
       EasySearch.ProcAfterTransition!( Dt, Dst, Pt, Ps, Pc, env )  # compute other variables
end # end macro





# ============================================
# SECTION: decorate parameters & solving & save models out 开始敏感性测试
# NOTE: we test the relative changes away from the benchmark levels of tested parameters
#       我们测试参数偏离基准情形的相对幅度
# NOTE: and follow "Pannell D J . Sensitivity analysis: strategies, methods, concepts, examples[J]. Agric Econ, 1997."
#       to design tests, then report the results
#       然后参照(Pannel 1997)设计分析并报告结果
# NOTE: the selected objective variable is: the RELATIVE CHANGE of [LI/PoolExp, LI/PoolIn, LI/GDP, LI/TexRev] from 2010 to 2110
#       e.g. x(2110) - x(2010), where x(t) is one of the four variables
#       选定的作为敏感性分析的目标量(output variable)的是正文政策模拟采用的四个指标【在2010至2100这100年间的**相对**变化幅度】
#       the reported figure uses [the % change of tested parameter] as x-axis, and [the % change of objective variable RISE] as y-axis; when lined, approximated slopes indicates elasticities
#       报告的图形以[测试参数相对基准的百分比变化]为x轴，以[目标量的百分比变化]为Y轴，当把某个参数的测试结果连线，近似的斜率就是目标量对测试参数的弹性关系
#       can report multiple tests (tested parameters) on one objective variable in one figure
#       可以在一张图里报告基于一个目标量的对不同测试参数的敏感性分析结果
# -----------------



# relative turbulence vector on parameters (in digits)
SA_RelTurb = [ -0.1, -0.05, 0.0, 0.05, 0.1 ]
# a (generalizable) Dict to save SA results (vectors with length of vecRelTurb_SensiTest::Vector)
SA_ResSet_LI2Exp = Dict( :Turbulence => SA_RelTurb )
SA_ResSet_LI2Inc = Dict( :Turbulence => SA_RelTurb )
SA_ResSet_LI2GDP = Dict( :Turbulence => SA_RelTurb )
SA_ResSet_LI2Tax = Dict( :Turbulence => SA_RelTurb )
# tested parameter name (Symbol)  -> for CONSTANT parameters in Pc::Dict
SA_ParCandidate = [ :α, :γ, :κ, :μ, :σ, :δ ]


# you should run this loop for enough times to fill the results of diff parameters in SA_ResSet_xxx::Dict
# then these Dict will be used to do plotting ()
for tmpPar in SA_ParCandidate
   # 0. create vectors for current tested parameter to save results
   SA_ResSet_LI2Exp[Symbol(tmpPar)] = []
   SA_ResSet_LI2Inc[Symbol(tmpPar)] = []
   SA_ResSet_LI2GDP[Symbol(tmpPar)] = []
   SA_ResSet_LI2Tax[Symbol(tmpPar)] = []

   for tmpTurb in SA_RelTurb
      # ----------------
      # 1. first, refresh all data & parameters 首先刷新所有数据&参数
      include("../src/proc_VarsDeclare.jl")  # NOTE: please be careful about directory references
      include("../src/proc_InitPars.jl")

      # 2. then, manually decorate/edit the parameters to test 然后手动修饰参数
      # NOTE: please MANUALLY edit the parameters to test
      #        请手动修改到底测试哪个参数
      #        though we provide all parameters we test in our paper and comment most of them
      #        虽然我们提供了所有论文中我们涉及到的参数并且将大部分注释掉了
      # ----------------------
      # all relevant parameters:
      # \alpha, \gamma, \kappa, \mu, \sigma  (CONSTANT)
      # \beta_t, \eta_t, \theta_t, z_t, \zeta_t, \phi_t, \mathbb{A}_t, \mathbb{B}_t  (TIME SERIES, not recommended)
      # ---------------------
         # for constant parameters in Pc::Dict
            Pc[ Symbol(tmpPar) ] *= 1.0 + tmpTurb

      # -------------------
      # 3. solve the model & compute temporaty variables
      Guess = ( r = 0.08, L = 0.2 )
      EasySearch.SteadyState!( 1, Guess, Dt, Dst, Pt, Ps, Pc, env,
         atol = 1E-8, MaxIter = 1000, PrintMode = "final", MagicNum = 2.0, StepLen = 0.5 )
      Guess = ( r = 0.12, L = 0.75 )
      EasySearch.SteadyState!( env.T, Guess, Dt, Dst, Pt, Ps, Pc, env,
         atol = 1E-6, MaxIter = 1000,
         PrintMode = "final", MagicNum = 2.0, StepLen = 0.5 )
      PerfLog = EasySearch.Transition!( Dt, Dst, Pt, Ps, Pc, env,
         atol = 1E-3, MaxIter = 500,
         PrintMode = "full", MagicNum = 2.0, StepLen = 0.7, ReturnLog = true )
      EasySearch.ProcAfterTransition!( Dt, Dst, Pt, Ps, Pc, env )  # compute other variables


      # ----------------
      # 4. collect objective variable series
      tmpLoc = [2010, 2110] .- env.START_YEAR .+ 1
      tmpRes = (
         LI2Exp = Dt[:LI] ./ Dt[:AggPoolExp],
         LI2Inc = Dt[:LI] ./ Dt[:AggPoolIn],
         LI2GDP = Dt[:LI] ./ Dt[:Y],
         LI2Tax = Dt[:LI] ./ (Dt[:TRc] .+ Dt[:TRw]),
      )

      # -------------------
      # 5. collect SA result data through push!() method
      # NOTE: use esp() to avoid domain error (devided by zero)
      push!( SA_ResSet_LI2Exp[Symbol(tmpPar)] , tmpRes.LI2Exp[tmpLoc[2]] / (tmpRes.LI2Exp[tmpLoc[1]] .+ eps()) - 1 )
      push!( SA_ResSet_LI2Inc[Symbol(tmpPar)] , tmpRes.LI2Inc[tmpLoc[2]] / (tmpRes.LI2Inc[tmpLoc[1]] .+ eps()) - 1 )
      push!( SA_ResSet_LI2GDP[Symbol(tmpPar)] , tmpRes.LI2GDP[tmpLoc[2]] / (tmpRes.LI2GDP[tmpLoc[1]] .+ eps()) - 1 )
      push!( SA_ResSet_LI2Tax[Symbol(tmpPar)] , tmpRes.LI2Tax[tmpLoc[2]] / (tmpRes.LI2Tax[tmpLoc[1]] .+ eps()) - 1 )

   end
end

# ==============================
# finally, do plotting with PyPlot
# but before that, save the results! (time-costing the SA is! value it! lol)
# NOTE: CAUTION! NOT NORMALIZED ON BENCHMARK!!! 注意，输出的原始数据尚未对benchmark进行rescale！
EasyIO.writecsv( string("./output/SA_LI2Exp_",EasyIO.LogTag(),".csv"), SA_ResSet_LI2Exp )
EasyIO.writecsv( string("./output/SA_LI2Inc_",EasyIO.LogTag(),".csv"), SA_ResSet_LI2Inc )
EasyIO.writecsv( string("./output/SA_LI2GDP_",EasyIO.LogTag(),".csv"), SA_ResSet_LI2GDP )
EasyIO.writecsv( string("./output/SA_LI2Tax_",EasyIO.LogTag(),".csv"), SA_ResSet_LI2Tax )

# -----------
# NOTE: SA_ParCandidate = [ :α, :γ, :δ, :κ, :μ, :σ ]; SA_RelTurb = [ -0.1, -0.05, 0.0, 0.05, 0.1 ]
#       LineStyle: all dashes --
#       markers: circle o, diamond d, star *, upper-triangle ^, crux x, square s
#       all converted from digits to per-cent-ages
# NOTE: need to normalize/centralize SA results on parameter-change = 0 (benchmark)
#       to obtain the relative change from benchmark
#       注意，展示时需要基于benchmark进行中心化得到相对于benchmark的百分比偏离!
# -----------
PyPlot.figure( figsize = [16,9] )  # figsize measured in inches
   PyPlot.subplot(2,2,1)  # subfigure: gap / pool account expenditure
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Exp[:α] ./SA_ResSet_LI2Exp[:α][3], "--o" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Exp[:γ] ./SA_ResSet_LI2Exp[:γ][3], "--d" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Exp[:δ] ./SA_ResSet_LI2Exp[:δ][3], "--*" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Exp[:κ] ./SA_ResSet_LI2Exp[:κ][3], "--^" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Exp[:μ] ./SA_ResSet_LI2Exp[:μ][3], "--x" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Exp[:σ] ./SA_ResSet_LI2Exp[:σ][3], "--s" )
      PyPlot.xlabel("Parameter (% change from benchmark)")
      PyPlot.ylabel("Relative change from benchmark (%)")
      PyPlot.title("Rise from 2010 to 2110: Pool gap / Pool expenditure")
      PyPlot.grid(true)
      PyPlot.legend(SA_ParCandidate)
   # --------------------------
   PyPlot.subplot(2,2,2)  # subfigure: gap / pool account incomes
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Inc[:α] ./SA_ResSet_LI2Inc[:α][3], "--o" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Inc[:γ] ./SA_ResSet_LI2Inc[:γ][3], "--d" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Inc[:δ] ./SA_ResSet_LI2Inc[:δ][3], "--*" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Inc[:κ] ./SA_ResSet_LI2Inc[:κ][3], "--^" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Inc[:μ] ./SA_ResSet_LI2Inc[:μ][3], "--x" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Inc[:σ] ./SA_ResSet_LI2Inc[:σ][3], "--s" )
      PyPlot.xlabel("Parameter (% change from benchmark)")
      PyPlot.ylabel("Relative change from benchmark (%)")
      PyPlot.title("Rise from 2010 to 2110: Pool gap / Pool incomes")
      PyPlot.grid(true)
      PyPlot.legend(SA_ParCandidate)
   # --------------------------
   PyPlot.subplot(2,2,3)  # subfigure: gap / GDP
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2GDP[:α] ./SA_ResSet_LI2GDP[:α][3], "--o" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2GDP[:γ] ./SA_ResSet_LI2GDP[:γ][3], "--d" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2GDP[:δ] ./SA_ResSet_LI2GDP[:δ][3], "--*" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2GDP[:κ] ./SA_ResSet_LI2GDP[:κ][3], "--^" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2GDP[:μ] ./SA_ResSet_LI2GDP[:μ][3], "--x" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2GDP[:σ] ./SA_ResSet_LI2GDP[:σ][3], "--s" )
      PyPlot.xlabel("Parameter (% change from benchmark)")
      PyPlot.ylabel("Relative change from benchmark (%)")
      PyPlot.title("Rise from 2010 to 2110: Pool gap / GDP")
      PyPlot.grid(true)
      PyPlot.legend(SA_ParCandidate)
   # --------------------------
   PyPlot.subplot(2,2,4)  # subfigure: gap / Tax Revenues
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Tax[:α] ./SA_ResSet_LI2Tax[:α][3], "--o" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Tax[:γ] ./SA_ResSet_LI2Tax[:γ][3], "--d" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Tax[:δ] ./SA_ResSet_LI2Tax[:δ][3], "--*" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Tax[:κ] ./SA_ResSet_LI2Tax[:κ][3], "--^" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Tax[:μ] ./SA_ResSet_LI2Tax[:μ][3], "--x" )
      PyPlot.plot( 100 .* SA_RelTurb, 100 .* SA_ResSet_LI2Tax[:σ] ./SA_ResSet_LI2Tax[:σ][3], "--s" )
      PyPlot.xlabel("Parameter (% change from benchmark)")
      PyPlot.ylabel("Relative change from benchmark (%)")
      PyPlot.title("Rise from 2010 to 2110: Pool gap / Tax revenues")
      PyPlot.grid(true)
      PyPlot.legend(SA_ParCandidate)
   # --------------------------
   # layout adjustment
   PyPlot.tight_layout()

# ============================
# finally, finally, save out the figure
   PyPlot.savefig( string( "./output/SAresult_",EasyIO.LogTag(),".pdf" ), format = "pdf" )





















#
