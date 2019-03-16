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
       EasySearch.ProcAfterTransition!( Dt, Dst, Pt, Ps, Pc, env )
end # end macro





# ============================================
# SECTION: decorate parameters & solving & save models out 开始敏感性测试
# NOTE: we test the relative changes away from the benchmark levels of tested parameters
#       我们测试参数偏离基准情形的相对幅度
# NOTE: and follow "Pannell D J . Sensitivity analysis: strategies, methods, concepts, examples[J]. Agric Econ, 1997."
#       to design tests, then report the results
#       然后参照(Pannel 1997)设计分析并报告结果
# NOTE: the selected objective variable is: the percentage RISE of [LI/PoolExp, LI/PoolIn, LI/GDP, LI/TexRev] from 2010 to 2110
#       e.g. x(2110) - x(2010), where x(t) is one of the four variables
#       选定的作为敏感性分析的目标量(output variable)的是正文政策模拟采用的四个指标
#       the reported figure uses [the % change of tested parameter] as x-axis, and [the % change of objective variable RISE] as y-axis; when lined, approximated slopes indicates elasticities
#       报告的图形以[测试参数相对基准的百分比变化]为x轴，以[目标量的百分比变化]为Y轴，当把某个参数的测试结果连线，近似的斜率就是目标量对测试参数的弹性关系
#       can report multiple tests (tested parameters) on one objective variable in one figure
#       可以在一张图里报告基于一个目标量的对不同测试参数的敏感性分析结果
# -----------------


# relative turbulence vector on parameters (in digits)
SA_RelTurb = [ -0.1, -0.05, 0.0, 0.05, 0.1 ]
# a (generalizable) Dict to save SA results (vectors with length of vecRelTurb_SensiTest::Vector)
SA_ResSet_LI2Exp = Dict()
SA_ResSet_LI2Inc = Dict()
SA_ResSet_LI2GDP = Dict()
SA_ResSet_LI2Tax = Dict()

# you should run this loop for enough times to fill the results of diff parameters in SA_ResSet_xxx::Dict
# then these Dict will be used to do plotting ()
for tmpLoop in 1:length(vecRelTurb_SensiTest)

   # 1. first, refresh all data & parameters 首先刷新所有数据&参数
   include("../src/proc_VarsDeclare.jl")  # NOTE: please be careful about directory references
   include("../src/proc_InitPars.jl")

   # 2. then, manually decorate/edit the parameters to test 然后手动修饰参数
   # NOTE: please MANUALLY edit the parameters to test
   #        请手动修改到底测试哪个参数
   #        though we provide all parameters we test in our paper and comment most of them
   #        虽然我们提供了所有论文中我们涉及到的参数并且将大部分注释掉了
   # ============================
   # all relevant parameters:
   # \beta, \alpha, \gamma, \kappa, \mu, \sigma
   # \eta_t, \theta_t, z_t, \zeta_t, \phi_t, \mathbb{A}_t, \mathbb{B}_t
   # ============================
      # a. \beta: the share of capital incomes
         Pc[:β] *= 1.0 + SA_RelTurb[tmpLoop]
      # b. \alpha: the preference of leisure than consumption
         Pc[:α] *= 1.0 + SA_RelTurb[tmpLoop]
      # c. \gamma: inter-temporal elasticity of substitution
         Pc[:γ] *= 1.0 + SA_RelTurb[tmpLoop]
      # d. \kappa: depreciation rate
         Pc[:κ] *= 1.0 + SA_RelTurb[tmpLoop]
      # e. \mu: value-added tax rate
         Pc[:μ] *= 1.0 + SA_RelTurb[tmpLoop]
      # f. \sigma: wage tax rate
         Pc[:σ] *= 1.0 + SA_RelTurb[tmpLoop]

   # =============================
   # 3. solve the model, then collect data
   @quickproc_SolveModel()


end


































#
