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








# ======================= Section: Basic Parameters & Consts 基本参数与常量
   env = (
      # measured by index 以脚标标记
      MAX_YEAR = 400,
      MAX_AGE = 80,
      RETIRE_AGE = 40,
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
   # 2. initialize: parameter collections
   include("src/proc_InitPars.jl")







































#
