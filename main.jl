# Master: Basic 80-generation OLG model for UE-BMI
# (Main control flow)
# -------------------------------------------------------
# ====================== Section: Envrionment Loading 环境配置
   # 0. using Revise for dynamic development 引入Revise用于动态调试（必须最先引入）
   using Revise  # (must be firstly used; comment it when everything alright)
   # 1. add source files path 添加源文件搜索路径
   push!(LOAD_PATH,pwd())  # current root directory 当前根目录
   push!(LOAD_PATH,"./src/")  # source files directory 源文件目录
   # 2. import standard libraries & functions 导入标准库&函数
   import Statistics: mean  # standard aggregating functions 基本汇总用函数
   # 3. import 3rd-party public libraries 导入第三方公开库&函数
   import DataFrames, CSV  # for data I/O 数据读写用
   import PyPlot  # for plotting 绘图用
   # 4. import custom modules 导入自制模块
   import EasyHousehold
   import EasyEcon  # economic functions


# ======================= Section: Basic Parameters & Consts 基本参数与常量
   env = (
      # measured by index 以脚标标记
      T = 400, # max year
      S = 80, # max age
      Sr = 40, # retirement age
      # measured by reality 以真实尺度标记（用于索引、输出、绘图等）
      START_AGE = 20,
      START_YEAR = 1945,
      # paths & references 路径与索引
      PATH_DEMOGCSV = "./data/Demography_base.csv",  # 人口数据 csv matrix file (year × age, no headers or row-indexes) of population
      PATH_WAGEPROFILE = "./data/WageProfileCoef.csv", # 工资曲线数据路径 csv column vector (age × 1, no header or row-indexes) of relative wage profiling coefficients
      PATH_MA2MB = "./data/MA2MBCoef.csv", # 门诊/住院费用数据路径 csv column vector (age × 1, no header or row-indexes) of MA/MB for each generation
      PATH_M2C = "./data/M2C.csv"  # 总医疗支出/消费比例路径 csv column vector (age × 1, no header or row-indexes) of m/c in each year
   )


# ======================= Section: Initialization 初始化数据结构&参数包等
   # 1. initialize: data collections
   include("src/proc_VarsDeclare.jl")
   # 2. initialize: parameter collections (including Demography and m2c ratio)
   include("src/proc_InitPars.jl")


# ======================= Section: Initial Steady State 初始稳态搜索
# 0. print a flag 打印章节名
println("+ Section: Initial Steady State Search ...")
# 1. prepare guesses 准备猜测/初始值
Guess = (
   r = 0.08,  # we guess interest rate, a relative price, rather than an absolute capital factor 猜测利率这样一个相对价格而非猜测资本存量的绝对数值
   L = 0.2  # labor has a relatively constant scale when demography normalized 标准化人口后劳动力供应的规模也相对稳定
)
# 2. begin searching
EasySearch.SteadyState!( 1, Guess,
   Dt, Dst, env, Pt, Ps, Pc,
   atol = 1E-8,  # tolerance of Gauss-Seidel iteration
   MaxIter = 100,  # maximum loops
   PrintMode = "full",  # mode of printing
   MagicNum = 2.0,  # magic number, the lower bound of K/L (capital per labor)
   StepLen = 0.5  # relative step length to update guesses, in range (0,1]
)



































#