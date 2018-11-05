# developed in Julia 1.0.1
# -------------------------
# please include() this script; requires "env" defined
# ---------------------------------------



# --------------------------------------- Constants 常数参数
# parameter (constants)
Pc = Dict(
    :κ => 0.05,  # depreciation rate 折旧率
    :μ => 0.10,  # consumption tax rate 消费税率
    :σ => 0.24,  # income tax rate 工资税率
    :δ => 1/0.99 - 1,  # utility discounting rate 效用折现率，若令效用折现因子为0.99，则对应0.0101010101...
    :α => 1.5,  #　leisure preference than consumption 闲暇对消费的偏好系数
    :γ => 0.5,  # inter-temporal substitution elasticity 跨期替代弹性
    :𝒯 => 1.0  # Land factor  土地要素
)

# --------------------------------------- A special section to generate technology series 专门章节用于生成技术系数序列
# NOTE: because technolgies are piecewise functions of time t
    # 1. first, initialize it as one 初始化
    tmpA = ones(env.MAX_YEAR)
    # 2. then, set time points & convert them to index 设置转折点以分割时期
    tmppt = [1980, 2008, 2018]
    tmppt = [ x - env.START_YEAR + 1 for x in tmppt ]
    # 3. modify technology growth path 调整技术
        # 3.1 part 1: before 1980 (before open & reform) 改革开放前
        tmpA[1:tmppt[1]] = 1.0 .* 1.01 .^ (0:tmppt[1]-1)
        # 3.2 part 2: 1980 ~ 2008 (before financial crisis) 金融危机前
        tmpA[tmppt[1]+1:tmppt[2]] = tmpA[tmppt[1]] .* cumprod( 1 .+ LinRange(0.04, 0.045, tmppt[2]-tmppt[1]) )
        # 3.3 part 3: 2008 ~2018 (recent 10 years) 最近十年
        tmpA[tmppt[2]+1:tmppt[3]] = tmpA[tmppt[2]] .* cumprod( 1 .+ LinRange(0.05, 0.011, tmppt[3]-tmppt[2]) )
        # 3.4 part 4: after 2018, grows 50 years 此后再增长50年
        tmpGrowYear = 50::Int
        tmpA[tmppt[3]:tmppt[3]+tmpGrowYear] = tmpA[tmppt[3]] .* 1.01 .^ (0:tmpGrowYear)
        tmpA[tmppt[3]+tmpGrowYear+1:end] = fill(tmpA[tmppt[3]+tmpGrowYear], env.MAX_YEAR-tmppt[3]-tmpGrowYear)


# --------------------------------------- A special section to generate m/c coefficient 用于生成医疗/消费比例
# NOTE: allows to read in external data file
    tmpq = Array(LinRange( 0.07, 0.25, env.MAX_YEAR ))





# --------------------------------------- Vector by Year 序列参数（年）
# NOTE: use Dict to conveniently convert it to a DataFrame
# NOTE: wage profiles will be added later
# parameters (series by year)
Pt = Dict(
    :Year => range(env.START_YEAR,length=env.MAX_YEAR),  # a year index (for table making) 制表时用的年份索引
    # Firm Department 厂商部门
    :A => tmpA,  # urban technology 城镇技术
    :β  => fill(0.55,env.MAX_YEAR),  # capital income share 资本收入占比
    # General Fiscal 一般财政
    :D2Y => fill(0.0,env.MAX_YEAR),  # upper bound of gov outsanding debt to GDP 未偿债务上限
    # Urban Pension 城镇养老金计划
    :z  => fill(0.85,env.MAX_YEAR),  # collection rates 收缴率
    :η  => fill(0.2,env.MAX_YEAR),  # contribution rate: firm -> pension 缴纳（比例）：企业
    :θ  => fill(0.08,env.MAX_YEAR),  # contribution rate: agent -> pension 缴纳（比例）：个人
    # Urban Medical Scheme 城镇医保计划
    :ζ  => fill(0.06,env.MAX_YEAR),  # contribution rate: firm -> medical 缴纳（比例）：企业
    :ϕ  => fill(0.02,env.MAX_YEAR),  # contribution rate: agent -> medical 缴纳（比例）：个人
    :𝕒  => fill(0.30,env.MAX_YEAR),  # transfer rate: firm contribution -> contributor's (working agents) individual account 转移支付（比例）：企业缴纳至缴纳者自己的个人账户的比例
    :𝕓  => fill(0.00,env.MAX_YEAR),  # transfer rate: firm contribution -> retried (cross-sectional in one year) individual account 转移支付（比例）：企业缴纳至当年退休人群个人账户的比例
    # Household & Demands 家庭部门
    :q  => tmpq,  # ratio of total medical expenditure to total consumption 总医疗支出/消费比例系数
)




# --------------------------------------- Read-in Data 读入数据
# NOTE: read-in data e.g. wage profiling coefficients
# NOTE: vector data should be saved in columns, with header or not
# NOTE: using CSV package (to save time) 使用CSV包（不想自己写read）
# 1. initialization 准备一个空字典
Ps = Dict()

# 2. Wage Profiling Coefficients 工资系数
tmpε = CSV.read(env.PATH_WAGEPROFILE)[1]  # read in
tmpε = tmpε ./ tmpε[1]  # Normalization
Ps[:ε] = Array{Float64}( tmpε[1:env.RETIRE_AGE] )  # add to Ps

# 3. MA2MB ratio (outpatient expenditure / inpatient expenditure) 门诊/住院费用比例
tmpMA2MB = CSV.read(env.PATH_MA2MB)
Ps[:MA2MB] = tmpMA2MB[1] ./ tmpMA2MB[2]

# 4. Demography 人口结构
# NOTE: provided data are from real age 0 to real age 100 (similar to life table)
# NOTE: usually, ask for extra data (in both year, age dimensions) for flexibility
    # 4.1 read in 读入
    tmpN = CSV.read(env.PATH_DEMOGCSV)
    tmpN = convert(Array{Float64,2}, tmpN)
    # 4.2 add a new first row, adjust the origin 1st row to steady distribution (non-increasing) 添加一个新的第一行，修正为平稳的人口分布（非增）
    tmpNewRow = copy( tmpN[1:1,1:end] )  # attention: use 1:1 to keep it as a row vector
    for s in 2:length(tmpNewRow)
        if tmpNewRow[s] > tmpNewRow[s-1]
            tmpNewRow[s] = tmpNewRow[s-1]
        end
    end
    # 4.3 raising the non-increasing distribution to make it also non-increasing when transferred to the 2nd year (old 1st year) 将新的第一行向上平移一个值，使得到下一年上每一代都不会出现人口增加（因为我们假设了没有外部移民）
    tmpNewRow .+= findmax( abs.( tmpN[2,2:end] .- tmpNewRow[1:end-1] ) )[1]
    # 4.3 bind the new 1st row with the origin matrix 将新的第一行与原来的人口矩阵拼接起来
    tmpN = cat( tmpNewRow, tmpN, dims = 1 )
    # 4.4 compute accident mortalities 计算意外死亡率
    tmpF = 1.0 .- tmpN[2:end,2:end] ./ tmpN[1:end-1,1:end-1]
    # 4.4 Data truncation from env.START_AGE 从真实年龄处截取人口数据&死亡率
    tmpN = tmpN[ 1:env.MAX_YEAR, env.START_AGE:env.START_AGE+env.MAX_AGE-1 ]
    tmpF = tmpF[ 1:env.MAX_YEAR, env.START_AGE:env.START_AGE+env.MAX_AGE-1 ]
    # 4.5 adjust mortalities, make the last column be 0 (because we force all agents die at end of the last age year, so there is no "accident" death) 修正死亡率最后一列令所有值为0，因为我们已经假设了所有人在最后一年末都会死掉，所以“意外死亡率”为0
    tmpF[:,end] .= 0
    # 4.6 normallize population, let total population in the first year be 1 标准化人口，令第一年总人口为1
    tmpN ./= sum(tmpN[1,:])
    # 4.7 save demography to dictionary Ps
    Ps[:N] = tmpN
    Ps[:F] = tmpF








#
