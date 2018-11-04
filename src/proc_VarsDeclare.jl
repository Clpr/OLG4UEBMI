# developed in Julia 1.0.1
# -----------------------------
# prepare memories for variables (not parameters)
# NOTE: using Dict which can be quite easily converted to a DataFrame (by DataFrames package)
# NOTE: requires "env" defined
# ==============================================================================
# MAX_AGE = 80
# RETIRE_AGE = 35
# MAX_YEAR = 400
# REAL_STARTYEAR = 1946
# REAL_STARTAGE = 20

# ---------------------------------------------------- Vector data 序列数据（年）
# NOTE: use Dict to conveniently convert it to a DataFrame
# Data (by year)
Dt = Dict(
    :Year => Array( range(env.START_YEAR,length=env.MAX_YEAR) ),  # Years  年份索引（从真实年份开始）
    # ---------------- Economic States (stocks) 经济状态（存量）
    :K => zeros(env.MAX_YEAR),  # Urban capital supply  城镇资本存量供应
    :L => zeros(env.MAX_YEAR),  # Urban labour supply  城镇劳动力供应
    # ---------------- Economic States (flows & prices) 经济状态（流量&价格）
    :Y => zeros(env.MAX_YEAR),  # Urban output (GDP)  城镇产出
    :r  => zeros(env.MAX_YEAR),  # Net interest rate (investment returns)  净投资利率
    :w̄ => zeros(env.MAX_YEAR),  # Urban average wage level  城镇平均工资水平
    :C  => zeros(env.MAX_YEAR),  # Aggregated consumption  总消费
    :I  => zeros(env.MAX_YEAR),  # Investment  总投资
    :G  => zeros(env.MAX_YEAR),  # Government purchase  政府购买
    # ---------------- Social Security Benefits 社会保障给付
    :Λ => zeros(env.MAX_YEAR),  # Urban average pension benefits  城镇平均养老金发放量
    # ---------------- Fiscal 财政
    :D => zeros(env.MAX_YEAR),  # Government outstanding debt  政府未偿债务余额 (verbose, not used)
    :D2Y => zeros(env.MAX_YEAR),  # Government outstanding debt to GDP  政府未偿债务余额/GDP (verbose, not used)
    :TRc => zeros(env.MAX_YEAR),  # Urban total consumption tax revenues  城镇总消费税收入
    :TRw => zeros(env.MAX_YEAR),  # Urban total income tax revenues  城镇总收入税收入
    :LI  => zeros(env.MAX_YEAR),  # Gap/Surplus of urban pooling medical account  城镇医保统筹账户缺口
    # ---------------- Welfare 福利
    :U => zeros(env.MAX_YEAR),  # aggregated cross-sectional social utility 当年城镇居民效用之和
    # ---------------- Abstract & Intermediate 抽象变量和中间变量
    :o => zeros(env.MAX_YEAR),  # wage scaling coefficient 工资放缩系数
    :𝕡 => zeros(env.MAX_YEAR),  # transfer amount from firm contirbution to retired households 企业医保缴纳对退休人群个人账户的转移支付量
)

# ----------------------------------------------------- Matrix data (t*s) 矩阵数据（年*岁）
# Data (by year * age)
Dst = Dict(
    :Year => Array( range(env.START_YEAR,length=env.MAX_YEAR) ),  # Years  年份索引（从真实年份开始）
    :Age => Array( range(env.START_AGE,length=env.MAX_AGE) ),  # Ages  年龄索引（从真实年龄开始）
    # -------------------- Full ages: Stocks 全年龄存量
    :𝒜 => zeros(env.MAX_YEAR,env.MAX_AGE),  # Urban agents Wealth = a + Φ 城镇居民个人财富
    :a => zeros(env.MAX_YEAR,env.MAX_AGE),  # Urban agents Asset (not wealth) 城镇居民个人资产
    :Φ => zeros(env.MAX_YEAR,env.MAX_AGE),  # Urban agents Individual medical accounts  城镇居民个人医保账户
    # -------------------- Full ages: Flows 全年龄流量
    :c => zeros(env.MAX_YEAR,env.MAX_AGE),  # total consumption 消费
    :m => zeros(env.MAX_YEAR,env.MAX_AGE),  # total medical expenses 总医疗支出
    :MA => zeros(env.MAX_YEAR,env.MAX_AGE),  # outpatient expenses 门诊医疗支出
    :MB => zeros(env.MAX_YEAR,env.MAX_AGE),  # inpatient expenses 住院医疗支出
    # -------------------- Working ages 工作时期
    :w => zeros(env.MAX_YEAR,env.RETIRE_AGE),  # profiled age-specific wage level 经过profiling的工资水平
    :l => zeros(env.MAX_YEAR,env.RETIRE_AGE),  # leisure 闲暇
)






























#
