# developed in Julia 1.0.1
# -----------------------------
# prepare memories for variables (not parameters)
# NOTE: using Dict which can be quite easily converted to a DataFrame (by DataFrames package)
# NOTE: requires "env" defined
# ==============================================================================

# ---------------------------------------------------- Vector data 序列数据（年）
# NOTE: use Dict to conveniently convert it to a DataFrame
# Data (by year)
Dt = Dict(
    :Year => Array( range(env.START_YEAR,length=env.T) ),  # Years  年份索引（从真实年份开始）
    # ---------------- Economic States (stocks) 经济状态（存量）
    :K => zeros(env.T),  # Urban capital supply  城镇资本存量供应
    :L => zeros(env.T),  # Urban labour supply  城镇劳动力供应
    # ---------------- Economic States (flows & prices) 经济状态（流量&价格）
    :Y => zeros(env.T),  # Urban output (GDP)  城镇产出
    :r  => zeros(env.T),  # Net interest rate (investment returns)  净投资利率
    :w̄ => zeros(env.T),  # Urban average wage level  城镇平均工资水平
    :C  => zeros(env.T),  # Aggregated consumption  总消费
    :I  => zeros(env.T),  # Investment  总投资
    :G  => zeros(env.T),  # Government purchase  政府购买
    # ---------------- Social Security Benefits 社会保障给付
    :Λ => zeros(env.T),  # Urban average pension benefits  城镇平均养老金发放量
    # ---------------- Fiscal 财政
    :D => zeros(env.T),  # Government outstanding debt  政府未偿债务余额 (verbose, not used)
    :D2Y => zeros(env.T),  # Government outstanding debt to GDP  政府未偿债务余额/GDP (verbose, not used)
    :TRc => zeros(env.T),  # Urban total consumption tax revenues  城镇总消费税收入
    :TRw => zeros(env.T),  # Urban total income tax revenues  城镇总收入税收入
    :LI  => zeros(env.T),  # the gap/surplus of the urban pooling medical account (UE-BMI)  城镇医保统筹账户缺口
    # ---------------- Welfare 福利
    :U => zeros(env.T),  # aggregated cross-sectional social utility 当年城镇居民效用之和
    # ---------------- Abstract & Intermediate 抽象变量和中间变量
    :o => zeros(env.T),  # wage scaling coefficient 工资放缩系数
    :𝕡 => zeros(env.T),  # transfer amount from firm contirbution to retired households 企业医保缴纳对退休人群个人账户的转移支付量
)

# ----------------------------------------------------- Matrix data (t*s) 矩阵数据（年*岁）
# Data (by year * age)
Dst = Dict(
    :Year => Array( range(env.START_YEAR,length=env.T) ),  # Years  年份索引（从真实年份开始）
    :Age => Array( range(env.START_AGE,length=env.S) ),  # Ages  年龄索引（从真实年龄开始）
    # -------------------- Full ages: Stocks 全年龄存量
    :𝒜 => zeros(env.T,env.S),  # Urban agents Wealth = a + Φ 城镇居民个人财富
    :a => zeros(env.T,env.S),  # Urban agents Asset (not wealth) 城镇居民个人资产
    :Φ => zeros(env.T,env.S),  # Urban agents Individual medical accounts  城镇居民个人医保账户
    # -------------------- Full ages: Flows 全年龄流量
    :c => zeros(env.T,env.S),  # total consumption 消费
    :m => zeros(env.T,env.S),  # total medical expenses 总医疗支出
    :MA => zeros(env.T,env.S),  # outpatient expenses 门诊医疗支出
    :MB => zeros(env.T,env.S),  # inpatient expenses 住院医疗支出
    :ΦGaps => zeros(env.T,env.S),  # the transfer payments from agent's own a_{s} to the individual account of UEBMI Φ_{s}
    # -------------------- Working ages 工作时期
    :w => zeros(env.T,env.Sr),  # profiled age-specific wage level 经过profiling的工资水平
    :Lab => zeros(env.T,env.Sr),  # labor supply 劳动
)






























#
