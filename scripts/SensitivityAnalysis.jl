# Sensitivity Analysis
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

# relative turbulence vector on parameters (in digits)
vecRelTurb_SensiTest = [ -0.1, -0.05, 0.0, 0.05, 0.1 ]

for tmpLoop in 1:vecRelTurb_SensiTest

   # 1. first, refresh all data & parameters 首先刷新所有数据&参数
   include("src/proc_VarsDeclare.jl")
   include("src/proc_InitPars.jl")

   # 2. then, manually decorate/edit the parameters to test 然后手动修饰参数
   # NOTE: please MANUALLY edit what parameters to test
   #        请手动修改到底测试哪个参数
   #        though we provide all parameters we test in our paper and comment most of them
   #        虽然我们提供了所有论文中我们涉及到的参数并且将大部分注释掉了
   # ============================





end


































#
