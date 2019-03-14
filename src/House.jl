__precompile__()
"""
    House

Household life-cycle optimization problems.
Using our proposed half-analytical algorithm.
Please refer to our academic documents to learn more about this module.

All comments & documentations are provided in both English & Chinese languages.
Therefore, please use UTF-8 encoding to open this file

Tianhao (GitHub: Clpr)
Jan 2019
"""
module House


# -----------------------------------------------------------------------------
## SECTION 0: Sample Datasets 样本数据
# NOTE: in this section, we provide the sample datasets used to test our algorithms.
#       本节提供用于测试本模块算法的样例数据集
#       these datasets, which are general, are provided for lev1Abbr() & lev1Abbr_Retired() as parameters
#       这些样例数据都是一般化的数据，用于输入给lev1Abbr() & lev1Abbr_Retired()
#       In practice, these datasets should be created by two custom functions: lev0Abbr() & lev0Abbr_Retired()
#       在实际计算时，这些样例数据集应当经由 lev0Abbr() & lev0Abbr_Retired() 这两个自定义函数生成
#       The created datasets should have the same type as our sample datasets: NamedTuple, {Symbol,Union{Vector{Float64},Float64}}
#       生成的数据集的数据类型应当和我们的样例数据集相同: NamedTuple, {Symbol,Union{Vector{Float64},Float64}}
#       and have, at least, all the elements (also with the same names) in our sample datasets.
#       （生成的数据集）并且应当至少包含有我们提供的样例数据集里的所有元素并且命名是相同的
#       We use a linear budget constraint like:
#       我们使用如下的线性预算约束:
#       1. `` A_{s} k_{s+1} = B_{s} k_{s} + D_{s} l_{s} - E_{s} c_{s} + F_{s} , s = 1,...,Sr ``
#       2. `` A_{s} k_{s+1} = B_{s} k_{s} - E_{s} c_{s} + F_{s} , s = Sr+1,...,S ``
#       3. `` k_{1} \in R+ or = 0 ``
#       4. `` k_{S+1} = 0 ``
#       In a problem with only retired years, we use constraint 2,3,4, and replace Sr with 0, also S with S (left years to live)
#       在一个只有退休期的问题里，我们使用约束2,3,4，并使用0替换退休年龄Sr，使用剩余存活年数S代替原来的最大年龄S
# ---------
# 0.1 Sample datasets for the problems with both working & retired years
# 0.1 为一个全生命期（同时有工作和退休）的问题的样例数据
# Sample: Constants
SampleConst = (
    S = 20,  # maximum age, requiring S>Sr>=1 最大年龄
    Sr = 11,  # retirement age 退休年龄
    alpha = 1.5 ,  # the preference of leisure on consumption 闲暇对消费的偏好系数
    gamma = 0.5,    # the inter-temporal elasticity of substitutions 跨期替代弹性
    k1 = 0.0  # initial capital when born 出生时持有的资产
)
# Sample: Vectors
SampleLev0Abbr = Dict{Symbol,Union{Vector{Float64},Float64}}(
    :A => fill(0.99, SampleConst.S),  # multiplier on k_{s+1} 通常是生存概率
    :B => fill(1.05, SampleConst.S),  # multiplier on k_{s} 通常是1+r，即资本增长
    :D => fill(0.60, SampleConst.Sr),  # multiplier on l_{s} 通常是工资的扣减项
    :E => fill(1.10, SampleConst.S),  # multiplier on c_{s} 通常是工资税和其他消费附加项
    :F => rand(SampleConst.S),  # extra capital flow unrelated to c_{s} and l_{s} 通常是养老金等转移支付
    :lbar => ones(SampleConst.Sr),  # time endowment 时间禀赋
    :beta => fill(0.99, SampleConst.S),  # utility discounting factor 效用折现因子
    :q => fill(0.15, SampleConst.S)  # the rate of medical expenditure on total consumption c_{s} 医疗支出占总消费的比例
)
# 0.1 Sample datasets for the problems with both working & retired years, but only 1 working year (Sr=1)
# 0.1 为一个全生命期（同时有工作和退休）的问题的样例数据，但只有一年工作期
# Sample: Constants
SampleConst1 = (
    S = 10,  # maximum age, requiring S>Sr>=1 最大年龄
    Sr = 1,  # retirement age 退休年龄
    alpha = 1.5 ,  # the preference of leisure on consumption 闲暇对消费的偏好系数
    gamma = 0.5,    # the inter-temporal elasticity of substitutions 跨期替代弹性
    k1 = 0.0  # initial capital when born 出生时持有的资产
)
# Sample: Vectors
SampleLev0Abbr1 = Dict{Symbol,Union{Vector{Float64},Float64}}(
    :A => fill(0.99, SampleConst.S),  # multiplier on k_{s+1} 通常是生存概率
    :B => fill(1.05, SampleConst.S),  # multiplier on k_{s} 通常是1+r，即资本增长
    :D => fill(0.60, SampleConst.Sr),  # multiplier on l_{s} 通常是工资的扣减项
    :E => fill(1.10, SampleConst.S),  # multiplier on c_{s} 通常是工资税和其他消费附加项
    :F => rand(SampleConst.S),  # extra capital flow unrelated to c_{s} and l_{s} 通常是养老金等转移支付
    :lbar => ones(SampleConst.Sr),  # time endowment 时间禀赋
    :beta => fill(0.99, SampleConst.S),  # utility discounting factor 效用折现因子
    :q => fill(0.15, SampleConst.S)  # the rate of medical expenditure on total consumption c_{s} 医疗支出占总消费的比例
)
# 0.3 Sample datasets for the problems with ONLY retired years
# 0.3 为一个只有退休期的问题的样例数据
# Sample: Constants
SampleConst_Retired = (
    S = 20,  # maximum age left to live, requiring S>=1 尚能存活的最大年龄
    alpha = 1.5 ,  # the preference of leisure on consumption 闲暇对消费的偏好系数
    gamma = 0.5,    # the inter-temporal elasticity of substitutions 跨期替代弹性
    k1 = 5.0  # initial capital when making decision 决策时持有的资产
)
# Sample: Vectors
SampleLev0Abbr_Retired = Dict{Symbol,Union{Vector{Float64},Float64}}(
    :A => fill(0.99, SampleConst_Retired.S),  # multiplier on k_{s+1} 通常是生存概率
    :B => fill(1.05, SampleConst_Retired.S),  # multiplier on k_{s} 通常是1+r，即资本增长
    :E => fill(1.10, SampleConst_Retired.S),  # multiplier on c_{s} 通常是工资税和其他消费附加项
    :F => rand(SampleConst_Retired.S),  # extra capital flow unrelated to c_{s} and l_{s} 通常是养老金等转移支付
    :beta => fill(0.99, SampleConst_Retired.S),  # utility discounting factor 效用折现因子
    :q => fill(0.15, SampleConst_Retired.S)  # the rate of medical expenditure on total consumption c_{s} 医疗支出占总消费的比例
)
# 0.4 Sample datasets for the problems with ONLY ONE retired years
# 0.4 为一个只有1年活头儿的退休期的问题的样例数据
# Sample: Constants
SampleConst_Retired1 = (
    S = 1,  # maximum age left to live, requiring S>=1 尚能存活的最大年龄
    alpha = 1.5 ,  # the preference of leisure on consumption 闲暇对消费的偏好系数
    gamma = 0.5,    # the inter-temporal elasticity of substitutions 跨期替代弹性
    k1 = 5.0  # initial capital when making decision 决策时持有的资产
)
# Sample: Vectors
SampleLev0Abbr_Retired1 = Dict{Symbol,Union{Vector{Float64},Float64}}(
    :A => fill(0.99, SampleConst_Retired1.S),  # multiplier on k_{s+1} 通常是生存概率
    :B => fill(1.05, SampleConst_Retired1.S),  # multiplier on k_{s} 通常是1+r，即资本增长
    :E => fill(1.10, SampleConst_Retired1.S),  # multiplier on c_{s} 通常是工资税和其他消费附加项
    :F => rand(SampleConst_Retired1.S),  # extra capital flow unrelated to c_{s} and l_{s} 通常是养老金等转移支付
    :beta => fill(0.99, SampleConst_Retired1.S),  # utility discounting factor 效用折现因子
    :q => fill(0.15, SampleConst_Retired1.S)  # the rate of medical expenditure on total consumption c_{s} 医疗支出占总消费的比例
)


# -----------------------------------------------------------------------------
## SECTION 1: The generators of level 0 abbriviations  Level 0 缩写变量生成
# NOTE: in this section, we define two custom funcions: lev0Abbr() & lev0Abbr_Retired
#       本节我们定义两个可以自定义修改的函数：lev0Abbr() & lev0Abbr_Retired
#       the two functions are used to generate the similar datasets in SECTION 0:
#       这两个函数用于生成SECITON 0里提供的样例数据形式的数据:
#       one NamedTuple for constant parameters; one Dict for vector parameters
#       一个NamedTuple存放常数参数，一个字典存放向量参数
#       the Dict dataset, will be modified later to contain more elements, using in-place methods
#       字典数据集，稍后会往里面继续添加元素，使用in-place方法（直接修改当前字典而不是返回一个新拷贝）
#       the created datasets can be used to define a standard problem which can be solved with general APIs
#       生成的数据用于定义一个可以被通用方法求解的问题
#       meanwhile, in the two functions, data validations are also performed
#       同时，这两个函数也进行数据的合法性检查
#       as for the domains of input data, please read our academic documents
#       关于合法性检查的更多问题，请阅读我们单独的学术文档
#       sample datasets for lev0Abbr() & lev0Abbr_Retired() are provided in SECTION 6
#       用于lev0Abbr()和lev0Abbr_Retired()的样例数据在SECTION 6提供
#       these sample datasets are also compatible for HHSolve() & HHSolve_Retired()
#       这些样例数据集同时也对HHSolve()和HHSolve_Retired()适用
# ----------
"""
    lev0Abbr( OriginData::Dict )

Construct level 0 abbreviations; a custom function;
receives a Dict containing all data required (sample datasets are provided in SECTION 6);
returns a NamedTuple, and a Dict.
These two returns are the same as the sample datasets in SECTION 0
(SampleConst, SampleLev0Abbr, SampleConst1, SampleLev0Abbr1)
"""
function lev0Abbr( OriginData::Dict{Symbol,T} where T )
    # The NamedTuple dataset of Constant Parameters
    local ConstPar = (
        S = OriginData[:Smax]::Int,
        Sr = OriginData[:Sret]::Int,
        alpha = OriginData[:alpha]::Real,
        gamma = OriginData[:gamma]::Real,
        k1 = OriginData[:k1]::Real
    )
    @assert( ConstPar.S > ConstPar.Sr >= 1 , "requires S > Sr >= 1" )
    @assert( ConstPar.alpha > 0.0 , "requires alpha > 0" )
    @assert( ConstPar.gamma != 0.0 , "requires gamma != 0" )

    # The Dict dataset of vector/constant parameters
    # NOTE: data validations are performed when records are defined
    local DictPar = Dict{Symbol,Union{Vector{Float64},Float64}}()

    # NOTE: budget: A_{s} k_{s+1} = B_{s} k_{s} + D_{s} l_{s} - E_{s} c_{s} + F_{s}

    # A: the survival prob multipliers, len = S, which indicates the survival prob from moment s to moment s+1
    # NOTE: ask for the last element is 1; every element in (0,1]
    DictPar[:A] = OriginData[:Survival][1:ConstPar.S]::Vector{Float64}
    DictPar[:A][ConstPar.S] = 1.0::Float64
    @assert( all( 0.0 .< DictPar[:A] .<= 1.0 ) , "component A: survival probs should in range (0,1]" )

    # B: the capital growth, len = S
    # NOTE: every B > 0
    DictPar[:B] = 1.0 .+ OriginData[:r][1:ConstPar.S]::Vector{Float64}
    @assert( all( DictPar[:B] .> -0.0 ) , "component B: >0 required" )

    # D: multipliers on labor, including the contributions to social security systems
    # NOTE: len = Sr
    DictPar[:D] = 1.0 .- OriginData[:σ][1:ConstPar.Sr]::Vector{Float64}
    local tmpval = Array{Float64,1}()
    for s in 1:ConstPar.Sr
        push!(tmpval ,
            ( OriginData[:z][s] * ( OriginData[:θ][s] + OriginData[:η][s] ) + ( 1.0 - OriginData[:𝕒][s] ) * OriginData[:ζ][s] ) / ( 1.0 + OriginData[:z][s] * OriginData[:η][s] + OriginData[:ζ][s] )
        )
    end
    @assert( all( DictPar[:D] .> 0.0 ) , "component D: >0 required"  )

    # E: multipliers on consumptionm including the benefits of UEBMI and consumption taxation
    # NOTE: len = S
            # DictPar[:E] = 1.0 .+ OriginData[:μ][1:ConstPar.S] .- OriginData[:q][1:ConstPar.S] .* ( 1.0 .- OriginData[:cpB][1:ConstPar.S] ) ./ ( 1.0 .+ OriginData[:p][1:ConstPar.S] )
    # NOTE: bug fixed on Mar 14,2019
    DictPar[:E] = ( 1.0 .+ OriginData[:μ][1:ConstPar.S] ) .* ( 1.0 .+ OriginData[:q][1:ConstPar.S] .* ( 1.0 .- OriginData[:cpB][1:ConstPar.S] ) ./ ( 1.0 .+ OriginData[:p][1:ConstPar.S] ) )
    @assert( all( DictPar[:E] .> 0.0 ), "component E: >0 required" )

    # F: extra isolated capital flows, the benefits of pension and the transfer payments of UEBMI
    # NOTE: len = S; the 1->Sr are 0.0, the Sr+1 -> S are pension + UEBMI
    DictPar[:F] = zeros(Float64,ConstPar.S)
    for s in ConstPar.Sr+1:ConstPar.S
        DictPar[:F][s] = OriginData[:Λ][s-ConstPar.Sr] + OriginData[:𝕡][s-ConstPar.Sr]
    end

    # lbar: time endowments, len = Sr
    # NOTE: by default, 1
    DictPar[:lbar] = ones(Float64,ConstPar.Sr)
    @assert( all( DictPar[:lbar] .> 0.0 ) , "component lbar: > 0 required" )


    # beta: utility discounting factor
    # NOTE: if using inter-TEMPORAL utility discounting rate/factor,
    #       please cumporduct it to get the discounting factors which discount utility to time 1
    DictPar[:beta] = cumprod( 1.0 ./ (1.0 .+ OriginData[:δ][1:ConstPar.S] ) )::Vector{Float64}
    @assert( all( DictPar[:beta] .!= 0.0 ) , "component beta: != 0 required" )

    # q: the ratio of health expenditure on consumption
    # NOTE: len = S; q in (0,1)
    DictPar[:q] = OriginData[:q][1:ConstPar.S]::Vector{Float64}
    @assert( all( 0.0 .< DictPar[:q] .< 1.0 ) , "component q: in (0,1) required" )


    return ConstPar::NamedTuple, DictPar::Dict
end
# ------
"""
    lev0Abbr_Retired( OriginData::Dict )

Construct level 0 abbreviations; a custom function;
receives a Dict containing all data required (sample datasets are provided in SECTION 6);
returns a NamedTuple, and a Dict.
These two returns are the same as the sample datasets in SECTION 0:
(SampleConst_Retired, SampleLev0Abbr_Retired, SampleConst_Retired1, SampleLev0Abbr_Retired1)
"""
function lev0Abbr_Retired( OriginData::Dict{Symbol,T} where T )
    # The NamedTuple dataset of Constant Parameters
    local ConstPar = (
        S = OriginData[:Smax]::Int,
        alpha = OriginData[:alpha]::Real,
        gamma = OriginData[:gamma]::Real,
        k1 = OriginData[:k1]::Real
    )
    @assert( ConstPar.S >= 1 , "requires S > Sr >= 1" )
    @assert( ConstPar.alpha > 0.0 , "requires alpha > 0" )
    @assert( ConstPar.gamma != 0.0 , "requires gamma != 0" )

    # The Dict dataset of vector/constant parameters
    # NOTE: data validations are performed when records are defined
    local DictPar = Dict{Symbol,Union{Vector{Float64},Float64}}()

    # NOTE: budget: A_{s} k_{s+1} = B_{s} k_{s} - E_{s} c_{s} + F_{s}

    # A: the survival prob multipliers, len = S, which indicates the survival prob from moment s to moment s+1
    # NOTE: ask for the last element is 1; every element in (0,1]
    DictPar[:A] = OriginData[:Survival][1:ConstPar.S]::Vector{Float64}
    DictPar[:A][ConstPar.S] = 1.0::Float64
    @assert( all( 0.0 .< DictPar[:A] .<= 1.0 ) , "component A: survival probs should in range (0,1]" )

    # B: the capital growth, len = S
    # NOTE: every B > 0
    DictPar[:B] = 1.0 .+ OriginData[:r][1:ConstPar.S]::Vector{Float64}
    @assert( all( DictPar[:B] .> -0.0 ) , "component B: >0 required" )

    # E: multipliers on consumptionm including the benefits of UEBMI and consumption taxation
    # NOTE: len = S
            # DictPar[:E] = 1.0 .+ OriginData[:μ][1:ConstPar.S] .- OriginData[:q][1:ConstPar.S] .* ( 1.0 .- OriginData[:cpB][1:ConstPar.S] ) ./ ( 1.0 .+ OriginData[:p][1:ConstPar.S] )
    # NOTE: bug fixed on Mar 14,2019
    DictPar[:E] = ( 1.0 .+ OriginData[:μ][1:ConstPar.S] ) .* ( 1.0 .+ OriginData[:q][1:ConstPar.S] .* ( 1.0 .- OriginData[:cpB][1:ConstPar.S] ) ./ ( 1.0 .+ OriginData[:p][1:ConstPar.S] ) )
    @assert( all( DictPar[:E] .> 0.0 ), "component E: >0 required" )

    # F: extra isolated capital flows, the benefits of pension and the transfer payments of UEBMI
    # NOTE: len = S; the 1->Sr are 0.0, the Sr+1 -> S are pension + UEBMI
    DictPar[:F] = zeros(Float64,ConstPar.S)
    for s in 1:ConstPar.S
        DictPar[:F][s] = OriginData[:Λ][s] + OriginData[:𝕡][s]
    end

    # beta: utility discounting factor
    # NOTE: if using inter-TEMPORAL utility discounting rate/factor,
    #       please cumporduct it to get the discounting factors which discount utility to time 1
    DictPar[:beta] = cumprod( 1.0 ./ (1.0 .+ OriginData[:δ][1:ConstPar.S] ) )::Vector{Float64}
    @assert( all( DictPar[:beta] .!= 0.0 ) , "component beta: != 0 required" )

    # q: the ratio of health expenditure on consumption
    # NOTE: len = S; q in (0,1)
    DictPar[:q] = OriginData[:q][1:ConstPar.S]::Vector{Float64}
    @assert( all( 0.0 .< DictPar[:q] .< 1.0 ) , "component q: in (0,1) required" )


    return ConstPar::NamedTuple, DictPar::Dict
end




# -----------------------------------------------------------------------------
## SECTION 2: The generators of level 1 abbriviations  Level 1 缩写变量生成
# NOTE: in this section, we define Level 1 abbreviations (variables)
#       本节我们定义Level 1的缩写变量
#       this section has two functions: lev1Abbr!() & lev1Abbr_Retired!()
#       本节包含两个函数：lev1Abbr!() & lev1Abbr_Retired!()
#       the two functions receive the datasets (NamedTuple & Dict) created by the functions in SECTION 1
#       这两个函数接收SECTION 1中生成的数据集（NamedTuple和Dict都要）
#       then modify the Dict dataset, adding Level 1 abbreviations to it
#       然后对其中的Dict数据结构操作，往里面添加Level 1的缩写变量
#       the two functions return nothing but modify the Dict dataset, do not modify the NamedTuple (it does not need extra modification)
#       这两个函数不会返回值，而是直接就地修改那个Dict数据集，不修改那个NamedTuple（修改不了，并且也没必要）
#       we assume all data validations have been performed in SECTION 1; no validation in this section and following sections
#       我们假设所有的数据合法性检查都已经在SECTION 1里面完成了；本节及之后的SECTION都不进行数据合法性检查
#       The Level 1 abbreviations consist of:
#       Level 1缩写变量包括：
#       1. M_{s,s+1}, N_{s,s+1}, s=1,...,S-1
#       2. P_{s}, Q_{s}, s=1,...,Sr
#       3. H
#       4. I_{s}, s=1,...,Sr
#       5. J_{s}, K_{s}, s=1,...,S
#       Please note, M_{s,s+1} & N_{s,s+1} (s=1,...,S-1) are now added a FIRST element 1.0 for the convenience of computing
#       注意，为了计算方便，M,N的第一个元素被定义为 1
#       it means c_{s} now should multiply M[s+1], N[s+1] to get c_{s+1}, where M[],N[] are the defined vectors (in code)
#       这意味着第s年的消费现在应当乘上（加了1的）向量M,N的第s+1个元素来得到第s+1年的消费
#       meanwhile, because (in academic documents) we defined \prod^m_n = 1 for all n > m
#       同时，由于我们在单独的学术文档里约定当累乘的下脚标大于上脚标时累乘恒等于 1
#       therefore, we make the cum-product part of the last element of I_{s}, J_{s}, K_{s} (s=S, when S+1>S) be 1, manually
#       因此，我们手动指定I,J,K的最后一个元素中累乘的部分（此时下脚标是S+1,上脚标是S）为 1
#       addtionally, though H is a number, we still save it in the Dict dataset (well ... actually because NamedTuple cannot be modified)
#       另外，虽然H是一个数，我们仍然将其存储在Dict数据集中（好吧，其实是因为NamedTuple无法修改）
# ------------

"""
    lev1Abbr!( DictPar::Dict, ConstPar::NamedTuple )

Defines Level 1 abbriviations for a problem with both working & retired years.
Operates in-place, on :DictPar input; returns nothing.

In julia, we do not need to use log -> exp to avoid float error, just use cumprod() ! :)
"""
function lev1Abbr!( DictPar::Dict, ConstPar::NamedTuple )
    # Euler: M_{s,s+1}, N_{s,s+1}, s = 1,...,S (1.0 added as the first element)
    DictPar[:M] = DictPar[:beta][2:ConstPar.S] ./ DictPar[:beta][1:ConstPar.S-1] .* DictPar[:E][1:ConstPar.S-1] ./ DictPar[:E][2:ConstPar.S] .* DictPar[:B][2:ConstPar.S] ./ DictPar[:A][1:ConstPar.S-1]
    DictPar[:N] = ( 1.0 .- DictPar[:q][2:ConstPar.S] ) ./ ( 1.0 .- DictPar[:q][1:ConstPar.S-1] )
    pushfirst!(DictPar[:M], 1.0)
    pushfirst!(DictPar[:N], 1.0)

    # C-L Conversion: P_{s}, Q_{s}, s = 1,...,Sr (no extra element added)
    DictPar[:P] = ConstPar.alpha .* DictPar[:E][1:ConstPar.Sr] ./ DictPar[:D][1:ConstPar.Sr]
    DictPar[:Q] = 1.0 .- DictPar[:q][1:ConstPar.Sr]

    # Budget: H (const)
    DictPar[:H] = ConstPar.k1 * prod( DictPar[:B][1:ConstPar.S] ./ DictPar[:A][1:ConstPar.S] )

    # useful abbreviation, the series: \prod^S_{j+1} B_{j}/A_{j} for j = 1,...,S
    local tmpCumProd::Vector = []
    for s in 2:ConstPar.S
        push!( tmpCumProd, prod( DictPar[:B][s:ConstPar.S] ./ DictPar[:A][s:ConstPar.S] ) )
    end
    push!( tmpCumProd , 1.0)  # because we assume prod^m_n = 1 for all n>m

    # Budget: I_{s}, s = 1,...,Sr (the last element is modified)
    DictPar[:I] = DictPar[:D][1:ConstPar.Sr] ./ DictPar[:A][1:ConstPar.Sr] .* tmpCumProd[1:ConstPar.Sr]

    # Budget: J_{s}, K_{s}, s = 1,...,S (the last element is modified)
    DictPar[:J] = -1.0 .* DictPar[:E][1:ConstPar.S] ./ DictPar[:A][1:ConstPar.S] .* tmpCumProd[1:ConstPar.S]
    DictPar[:K] =         DictPar[:F][1:ConstPar.S] ./ DictPar[:A][1:ConstPar.S] .* tmpCumProd[1:ConstPar.S]

    return nothing
end
# ----------------
"""
    lev1Abbr_Retired!( DictPar::Dict, ConstPar::NamedTuple )

Defines Level 1 abbriviations for a problem with ONLY retired years.
Operates in-place, on :DictPar input; returns nothing.

In julia, we do not need to use log -> exp to avoid float error, just use cumprod() ! :)
"""
function lev1Abbr_Retired!( DictPar::Dict, ConstPar::NamedTuple )
    # Budget: H (const)
    DictPar[:H] = ConstPar.k1 * prod( DictPar[:B][1:ConstPar.S] ./ DictPar[:A][1:ConstPar.S] )

    if ConstPar.S > 1  # Euler equation is required only if agents live for at least two years,
        # Euler: M_{s,s+1}, N_{s,s+1}, s = 1,...,S (1.0 added as the first element)
        DictPar[:M] = DictPar[:beta][2:ConstPar.S] ./ DictPar[:beta][1:ConstPar.S-1] .* DictPar[:E][1:ConstPar.S-1] ./ DictPar[:E][2:ConstPar.S] .* DictPar[:B][2:ConstPar.S] ./ DictPar[:A][1:ConstPar.S-1]
        DictPar[:N] = ( 1.0 .- DictPar[:q][2:ConstPar.S] ) ./ ( 1.0 .- DictPar[:q][1:ConstPar.S-1] )
        pushfirst!(DictPar[:M], 1.0)
        pushfirst!(DictPar[:N], 1.0)
        # useful abbreviation, the series: \prod^S_{j+1} B_{j}/A_{j} for j = 1,...,S
        local tmpCumProd::Vector = []
        for s in 2:ConstPar.S
            push!( tmpCumProd, prod( DictPar[:B][s:ConstPar.S] ./ DictPar[:A][s:ConstPar.S] ) )
        end
        push!( tmpCumProd , 1.0)  # because we assume prod^m_n = 1 for all n>m

        # Budget: J_{s}, K_{s}, s = 1,...,S (the last element is modified)
        DictPar[:J] = -1.0 .* DictPar[:E][1:ConstPar.S] ./ DictPar[:A][1:ConstPar.S] .* tmpCumProd[1:ConstPar.S]
        DictPar[:K] =         DictPar[:F][1:ConstPar.S] ./ DictPar[:A][1:ConstPar.S] .* tmpCumProd[1:ConstPar.S]
    else  # if agents only live for one year
        # Budget: J_{s}, K_{s}, s = 1,...,S (the last element is modified)
        # NOTE: using the index [1:1] will keep the data as an Array{T} but not a Float64
        DictPar[:J] = -1.0 .* DictPar[:E][1:ConstPar.S] ./ DictPar[:A][1:ConstPar.S] .* 1.0
        DictPar[:K] =         DictPar[:F][1:ConstPar.S] ./ DictPar[:A][1:ConstPar.S] .* 1.0
    end

    return nothing
end


# -----------------------------------------------------------------------------
## SECTION 3: The generators of level 2 abbriviations  Level 2 缩写变量生成
# NOTE: in this section, we define Level 2 abbreviations (variables)
#       本节我们定义Level 2的缩写变量
#       this section has two functions: lev2Abbr!() & lev2Abbr_Retired!()
#       本节包含两个函数：lev2Abbr!() & lev2Abbr_Retired!()
#       the two functions receive the datasets (NamedTuple & Dict) modified by the functions in SECTION 2
#       这两个函数接收SECTION 2中生成的数据集（NamedTuple和Dict都要）
#       then modify the Dict dataset, adding Level 2 abbreviations to it
#       然后对其中的Dict数据结构操作，往里面添加Level 2的缩写变量
#       the two functions return nothing but modify the Dict dataset, do not modify the NamedTuple (it does not need extra modification)
#       这两个函数不会返回值，而是直接就地修改那个Dict数据集，不修改那个NamedTuple（修改不了，并且也没必要）
#       Level 2 abbreviations consist of:
#       1. X_{s}, s = 1,...,S
#       2. Y_{s}, s = 1,...,Sr
#       Because we assume prod^m_n = 1 for all n > m, the cumproduct of the first element of X_{s} is modifed as 1
#       依旧由于我们约定了阶乘的额外的性质，所以X_{1}的阶乘部分被修正为1，意味着X_{1} = 1
# --------------
"""
    lev2Abbr!( DictPar::Dict, ConstPar::NamedTuple )

Defines Level 2 abbriviations for a problem with both working & retired years.
Operates in-place, on :DictPar input; returns nothing.
"""
function lev2Abbr!( DictPar::Dict, ConstPar::NamedTuple )
    # c_{s} = \varepsilon(s|c_{1}): X_{s}, s=1,...,S; the first element is defined as 1.0
    # NOTE: we have add an extra 1.0 into the first position of M, N; so, just compute it!
    # NOTE: we have assumed that S > Sr >= 1, so, no index bound
    DictPar[:X] = Array{Float64,1}()  # an empty vector
    for s in 1:ConstPar.S
        push!( DictPar[:X], prod( DictPar[:M][1:s] ) ^ ConstPar.gamma * prod( DictPar[:M][1:s] ) ^ (1-ConstPar.gamma) )
    end

    # l_{s} = \gamma(s|c_{1}): Y_{s}, s=1,...,Sr
    # NOTE: use list expr to avoid the problem of type conversion
    DictPar[:Y] = [ prod( DictPar[:P][1:s] ) ^ ConstPar.gamma * prod( DictPar[:Q][1:s] ) ^ (1-ConstPar.gamma) for s in 1:ConstPar.Sr ]

    return nothing
end
# ---------
"""
    lev2Abbr_Retired!( DictPar::Dict, ConstPar::NamedTuple )

Defines Level 2 abbriviations for a problem with ONLY retired years.
Operates in-place, on :DictPar input; returns nothing.
"""
function lev2Abbr_Retired!( DictPar::Dict, ConstPar::NamedTuple )
    # c_{s} = \varepsilon(s|c_{1}): X_{s}, s=1,...,S; the first element is defined as 1.0
    DictPar[:X] = Array{Float64,1}()
    if ConstPar.S > 1
        for s in 1:ConstPar.S
            push!( DictPar[:X], prod( DictPar[:M][1:s] ) ^ ConstPar.gamma * prod( DictPar[:M][1:s] ) ^ (1-ConstPar.gamma) )
        end
    end

    return nothing
end


# -----------------------------------------------------------------------------
## SECTION 4: useful functions 实用函数
# NOTE: in this section, we define some useful functions in problem solving.
#       本节我们定义一些在求解过程中很实用的函数
#       including:
#       1. u(): the cross-sectional utility function we use 我们使用的截面效用函数
#       1. getks(), getks_Retired(): get the series of k_{s} at the beginning of age s, s=1,...,S+1 得到s岁年初的资产余额序列，包括死亡时候的遗产
#       1. getcls(), getcls_Retired(): get the series of c_{s} and l_{s}, based on c_{1} 根据输入的c_{1}得到完整的消费和劳动力路径
#       2. G(), G_Retired(): get k_{S+1}, i.e. the budget constraint, the bequest; used to test whether budget constraints are met 得到死亡时的资产余额，用于检查预算约束是否满足
#       the functions receive c_{s}, l_{s}, and the datasets (both ConstPar & DictPar) modified by at least lev0Abbr(), lev0Abbr_Retired()
#       这些函数接收消费和闲暇，以及至少经过lev0Abbr(),lev0Abbr_Retired()修饰的NamedTupe和Dict数据集
#       they have returns
#       有返回值
#       meanwhile, we also provide some other decorated functions
#       同时，我们也提供其他的一些修饰过的函数
# ---------------
"""
    u( c::Real, l::Real ; q::Real = 0.15, alpha::Real = 1.5, gamma::Real = 0.5 )

A dessert function: cross-sectional utility function we used:
`` u(c\\geq 0,l\\geq 0|q\\in(0,1),\\bar{l}_{s}>0,\\alpha>0,\\gamma>0) = \\frac{1}{1-\\gamma^{-1}} [  [(1-q)c + \\epsilon]^{1-\\gamma^{-1}} + \\alpha [\\bar{l}_{s} - l + \\epsilon]^{1-\\gamma^{-1}}  ] ``,
where ``c`` is consumption, ``l`` is **labor**, ``q`` is the proportion of non-utility-improved consumtpion (e.g. health expenditure),
``\\bar{l}_{s}`` is time endowment, ``\\alpha`` is the leisure preference than consumption,
``\\gamma`` is the inter-temporal elasiticy of substitutions,
and ``\\epsilon`` is a infinitesimal (eps()) to avoid the domain errors raised by exact 0.

Returns a Real, the value of utility.
"""
function u( c::Real, l::Real ; lbar::Real = 1.0, q::Real = 0.15, alpha::Real = 1.5, gamma::Real = 0.5 )
    @assert( (c >= 0)&(l >= 0)&(lbar > 0)&(0 < q < 1)&(alpha > 0)&(gamma > 0), "at least one out-of-bound parameter in House.u()" )
    @assert( isfinite(c) & isfinite(l) & isfinite(lbar) & isfinite(q) & isfinite(alpha) & isfinite(gamma), "at least one infinite parameter in House.u()" )
    local uval::Float64 = 1.0 / (1.0 - 1.0 / gamma) * (  ( (1.0 - q) * c + eps() ) ^ ( 1.0 - 1.0 / gamma ) + alpha * ( lbar - l + eps() ) ^ ( 1.0 - 1.0 / gamma )  )
    return uval::Float64
end
# -----------
"""
    getks( cpath::Vector, lpath::Vector, DictPar::Dict, ConstPar::NamedTuple )

Get the series of k_{s}, s=1,...,S+1;
receives c_{1}, and datasets decorated by lev0Abbr();
Returns a vector whose length is S+1
"""
function getks( cpath::Vector, lpath::Vector, DictPar::Dict, ConstPar::NamedTuple )
    # assertions
    @assert( length(cpath) == ConstPar.S, "invalid length of consumption path, expect S"  )
    @assert( length(lpath) == ConstPar.Sr, "invalid length of labor path, expect Sr"  )

    # define the vector to return
    local ks = [ConstPar.k1]

    # fill
    for s in 1:ConstPar.Sr
        tmpknext = DictPar[:B][s] * ks[s] + DictPar[:D][s] * lpath[s] - DictPar[:E][s] * cpath[s] + DictPar[:F][s]
        push!(ks, tmpknext / DictPar[:A][s] )
    end
    for s in (ConstPar.Sr+1):ConstPar.S
        tmpknext = DictPar[:B][s] * ks[s]                             - DictPar[:E][s] * cpath[s] + DictPar[:F][s]
        push!(ks, tmpknext / DictPar[:A][s] )
    end

    # return
    return ks::Vector
end
# -------
"""
    getks_Retired( cpath::Vector, DictPar::Dict, ConstPar::NamedTuple )

Get the series of k_{s}, s=1,...,S+1;
receives c_{1}, and datasets decorated by lev0Abbr();
Returns a vector whose length is S+1
"""
function getks_Retired( cpath::Vector, DictPar::Dict, ConstPar::NamedTuple )
    # assertions
    @assert( length(cpath) == ConstPar.S, "invalid length of consumption path, expect S"  )

    # define the vector to return
    local ks = [ConstPar.k1]

    # fill
    local tmpknext::Float64
    for s in 1:ConstPar.S
        tmpknext = DictPar[:B][s] * ks[s] - DictPar[:E][s] * cpath[s] + DictPar[:F][s]
        push!(ks, tmpknext / DictPar[:A][s] )
    end

    # return
    return ks::Vector
end
# -----------
"""
    getcls( c1::Real, DictPar::Dict, ConstPar::NamedTuple )

Gets the series of c_{s}, s=1,...,S, and the series of l_{s}, s=1,...,Sr
receives c_{1}, and datasets decorated by lev2Abbr();
Returns a tuple of two vectors (cs,ls), where cs's length is S, and ls's length is Sr
"""
function getcls( c1::Real, DictPar::Dict, ConstPar::NamedTuple )
    # NOTE: using list expr to avoid the problems of type conversion
    # NOTE: if the Dict dataset was not modifed by lev2Abbr(), a KeyError will be auto thrown
    # Consumptions:
    local cs = [ c1 * DictPar[:X][s] for s in 1:ConstPar.S ]
    # Leisures:
    local ls = [ DictPar[:lbar][s] - cs[s] * DictPar[:P][s] ^ ConstPar.gamma * DictPar[:Q][s] ^ (1.0 - ConstPar.gamma) for s in 1:ConstPar.Sr ]

    return cs, ls
end
# -------------
"""
    getAdjcs( c1::Real, DictPar::Dict, ConstPar::NamedTuple )

Gets the series of c_{s}, s=1,...,S when given adjusted l_{s}, s=1,...,Sr;
receives c_{1} and datasets decorated by lev2Abbr();
please note, we assume Euler equation still works;
Returns a tuple of two vectors (cs,ls), where cs's length is S, and ls's length is Sr
"""
function getAdjcs( c1::Real, DictPar::Dict, ConstPar::NamedTuple )
    # NOTE: using list expr to avoid the problems of type conversion
    # NOTE: if the Dict dataset was not modifed by lev2Abbr(), a KeyError will be auto thrown
    # Consumptions:
    local cs = [ c1 * DictPar[:X][s] for s in 1:ConstPar.S ]

    return cs
end
# -------
"""
    getcls_Retired( c1::Real, DictPar::Dict, ConstPar::NamedTuple )

Gets the series of c_{s}, s=1,...,S
receives c_{1}, and datasets decorated by lev2Abbr_Retired();
Returns a tuple of one vector (cs), where cs's length is S, the left years to live
"""
function getcls_Retired( c1::Real, DictPar::Dict, ConstPar::NamedTuple )
    # NOTE: using list expr to avoid the problems of type conversion
    # NOTE: if the Dict dataset was not modifed by lev2Abbr(), a KeyError will be auto thrown
    # Consumptions:
    local cs = [ c1 ]
    if ConstPar.S >1
        for s in 2:ConstPar.S
            push!( cs, c1 * DictPar[:X][s] )
        end
    end

    return ( cs )
end
# -------------
# NOTE: for the problems with only retired years, adjusted leisure is not needed;
#       therefore, no getadjcs_Retired()
# -------------
G( c1::Real, DictPar::Dict, ConstPar::NamedTuple ) = begin
    local cls = getcls( c1, DictPar, ConstPar )
    local kdead = getks( cls[1], cls[2], DictPar, ConstPar )[ConstPar.S+1]
    return kdead  # "kdead" means "k when die, i.e. k_{S+1}"
end
GAdj( c1::Real, ls::Vector, DictPar::Dict, ConstPar::NamedTuple ) = begin
    local cs::Vector = getAdjcs( c1, DictPar, ConstPar )
    local kdead = getks( cs, ls, DictPar, ConstPar )[ConstPar.S+1]
    return kdead  # "kdead" means "k when die, i.e. k_{S+1}"
end
G_Retired( c1::Real, DictPar::Dict, ConstPar::NamedTuple ) = begin
    local cs = getcls_Retired( c1, DictPar, ConstPar )
    local kdead = getks_Retired( cs, DictPar, ConstPar )[ConstPar.S+1]
    return kdead
end













# -----------------------------------------------------------------------------
## SECTION 5: Solving APIs 求解算法
# NOTE: in this section, we define two methods: HHSolve() & HHSolve_Retired()
#       本节我们定义两个函数： HHSolve() & HHSolve_Retired()
#       they are the main APIs to call to solve our household optimization problems
#       这两个函数就是这个模块的主函数，用于求解家庭生命期优化问题
#       please customize lev0Abbr() & lev0Abbr_Retired()
#       请自定义设计 lev0Abbr() & lev0Abbr_Retired()函数
#       and package your original data (like r,w) which construct Level0 abbreviations in a Dict
#       请将原始数据（如利率、工资等），用于构筑Level 0缩写变量的数据，封装在一个Dict里
#       then pass this Dict to HHSolve() &/| HHSolve_Retired()
#       然后将这个Dict传给本节的两个API
#       the construction of Level 0 Abbreviations will be performed in HHSolve() & HHSolve_Retired()
#       Level 0 缩写变量的构筑在本节两个API内部
#       the two APIs return a Dict which contains: 这两个函数返回：
#       1. cs::Vector, consumption path, len = S
#       2. ls::Vector, LABOR path (not leisure!), len = Sr (not applicable in HHSolve_Retired())
#       3. ks::Vector, capital path, len = S+1 (k_{S+1} * k_{1} included)
#       4. other custom elements (e.g. SECTION 6)
#       in SECTION 6, we define some custom functions which are specially for this paper
# -----------
"""
    HHSolve( OriginData::Dict )

The main API of this module. It receives a Dict similar to the sample datasets in SECTION 6,
then solve a life-cycle optimization problem which have both working & retired years.
the keyword parameter :ReturnData indicates whether to return the two run-time datasets (a NamedTuple & a Dict);
if you need to further work on the solved capital path, you may need the two datasets.

It returns a Dict{Symbol,T} which contains:
1. :cs::Vector len = S,  consumption path
2. :ls::Vector len = Sr, LABOR path (not leisure!)
3. :ks::Vector len = S+1, capital path, where the bequest, k_{S+1} = 0 (if solved successfully)
4. :ConstPar::NamedTuple, run-time dataset, returned if ReturnData is true
5. :DictPar::Dict, run-time dataset, returned if ReturnData is true
"""
function HHSolve( OriginData::Dict ; ReturnData::Bool = true )
    # create level 0 abbreviations, create run-time datasets
    ConstPar, DictPar = lev0Abbr( OriginData )
    # create level 1 abbreviations, modify the run-time datasets
    lev1Abbr!( DictPar, ConstPar )
    # create level 2 abbreviations, modify the run-time datasets
    lev2Abbr!( DictPar, ConstPar )

    # get c*_{1} without time endowments
    local c1::Float64 =
        (  DictPar[:H] + sum(DictPar[:I] .* DictPar[:lbar]) + sum(DictPar[:J] .* DictPar[:K])  ) /
        (  sum(DictPar[:I] .* DictPar[:X][1:ConstPar.Sr] .* DictPar[:Y]) - sum(DictPar[:J] .* DictPar[:X])  )
    # get the series of c*_{s} & l*_{s}
    cs, ls = getcls( c1, DictPar, ConstPar )
    # adjust l*_{s} to \tilde{l}^*_{s} in the range [0,lbar]
    local lsAdj = max.( 0.0, min.( ls, DictPar[:lbar] ) )
    # get adjusted \tilde{c}*_{1} according to \tilde{l}^*_{s}
    local c1Adj::Float64 =
        (  DictPar[:H] + sum(DictPar[:I] .* lsAdj) + sum(DictPar[:K])  ) /
        (  - sum(DictPar[:J] .* DictPar[:X])  )
    # get the series of \tilde{c}*_{1}
    local csAdj = getAdjcs( c1Adj, DictPar, ConstPar )

    # compute the value of compressed budget constraint (bequest)
    local chkG::Float64 = GAdj( c1Adj, lsAdj, DictPar, ConstPar )
    # check if the budget constraint met
    abs(chkG) >= 1E-6  &&  throw(ErrorException(string( "the budget constraint is not satisfied at the tolerance level of 1E-06: ", abs(chkG) )))
    # @assert( abs(chkG) < 1E-6 , "the budget constraint is not satisfied at the tolerance level of 1E-08" )

    # when solved successfully, get the series of \tilde{k}*_{s}
    local ksAdj = getks( csAdj, lsAdj, DictPar, ConstPar )

    # returns
    if ReturnData
        return Dict(
            :cs => csAdj,
            :ls => lsAdj,
            :ks => ksAdj,
            :ConstPar => ConstPar,
            :DictPar => DictPar,
        )
    else
        return Dict(
            :cs => csAdj,
            :ls => lsAdj,
            :ks => ksAdj,
        )
    end
    # nominal returns
    return nothing
end
# -----------------
"""
    HHSolve_Retired( OriginData::Dict )

The main API of this module. It receives a Dict similar to the sample datasets in SECTION 6,
then solve a life-cycle optimization problem which have ONLY retired years.
the keyword parameter :ReturnData indicates whether to return the two run-time datasets (a NamedTuple & a Dict);
if you need to further work on the solved capital path, you may need the two datasets.

It returns a Dict{Symbol,T} which contains:
1. :cs::Vector len = S,  consumption path
2. :ks::Vector len = S+1, capital path, where the bequest, k_{S+1} = 0 (if solved successfully)
3. :ConstPar::NamedTuple, run-time dataset, returned if ReturnData is true
4. :DictPar::Dict, run-time dataset, returned if ReturnData is true
"""
function HHSolve_Retired( OriginData::Dict ; ReturnData::Bool = true )
    # create level 0 abbreviations, create run-time datasets
    ConstPar, DictPar = lev0Abbr_Retired( OriginData )
    # create level 1 abbreviations, modify the run-time datasets
    lev1Abbr_Retired!( DictPar, ConstPar )
    # create level 2 abbreviations, modify the run-time datasets
    lev2Abbr_Retired!( DictPar, ConstPar )

    # cases: S = 1 & S > 1
    if ConstPar.S > 1
        # get c*_{1} without time endowments
        local c1Adj::Float64 =
            (  DictPar[:H] + sum(DictPar[:K])  ) /
            (  - sum(DictPar[:J] .* DictPar[:X])  )
        # get the series of c*_{s} & l*_{s}
        csAdj = getcls_Retired( c1Adj, DictPar, ConstPar )

        # compute the value of compressed budget constraint (bequest)
        local chkG::Float64 = G_Retired( c1Adj, DictPar, ConstPar )
        # check if the budget constraint met
        @assert( abs(chkG) < 1E-6 , "the budget constraint is not satisfied at the tolerance level of 1E-06" )

        # when solved successfully, get the series of \tilde{k}*_{s}
        local ksAdj = getks_Retired( csAdj, DictPar, ConstPar )
    else
        # just compute \tilde{c}^*_{1} according to inter-temporal budget constraint
        csAdj = [
            ( DictPar[:B][1] * ConstPar.k1 + DictPar[:F][1] ) / DictPar[:E][1]
        ]
        # NOTE: because we use: A_{s} k_{s+1} = 0 = B_{s} k_{s} - E_{s} c_{s} + F_{s}
        #       therefore, the compressed budget constraint must meet
        #       but we still need to validate \tilde{c}^*_{1} >= 0
        @assert( csAdj[1] >= 0.0 , "negative consumption found when S = 1" )
        # get the optimal series of \tilde{k}*_{s}
        ksAdj = [ ConstPar.k1 , 0.0 ]
    end

    # returns
    if ReturnData
        return Dict(
            :cs => csAdj,
            :ks => ksAdj,
            :ConstPar => ConstPar,
            :DictPar => DictPar,
        )
    else
        return Dict(
            :cs => csAdj,
            :ks => ksAdj,
        )
    end
    # nominal returns
    return nothing
end





# -----------------------------------------------------------------------------
## SECTION 6: Other Custom Functions & Sample Datasets 其他自定义函数与样例数据集
# NOTE: in this section, we define some other custom functions which are more specific to this paper
#       本节我们定义一批其他的更加针对这篇文章的自定义函数
#       they are:
#       -------------- Sample Datasets 样例数据集
#       1. SampleOriginData::Dict, a sample dataset which can be input to lev0Abbr() or HHSolve(), the returns of SliceData() then is input to lev0Abbr()    (case Sr>1)
#       2. SampleOriginData_Retired::Dict, a sample dataset which can be input to lev0Abbr_Retired() or HHSolve_Retired(), the returns of SliceData_Retired() then is input to lev0Abbr_Retired()  (case S>1)
#       3. SampleOriginData1::Dict, a sample dataset which can be input to lev0Abbr() or HHSolve(), the returns of SliceData() then is input to lev0Abbr()   (case Sr=1)
#       4. SampleOriginData_Retired1::Dict, a sample dataset which can be input to lev0Abbr_Retired() or HHSolve_Retired(), the returns of SliceData_Retired() then is input to lev0Abbr_Retired() (case S=1)
#       -------------- Results Analysis (extract a_{s}, Φ_{s} from k_{s}) 结果修饰函数
#       1. ExtractAPhi!(), extract a_{s}, Φ_{s} from k_{s}, also requiring the ConstPar & DictPar in computing; add new elements to the returned Dict of HHSolve()
#       2. ExtractAPhi_Retired!(), extract a_{s}, Φ_{s} from k_{s}, also requiring the ConstPar & DictPar in computing; add new elements to the returned Dict of HHSolve_Retired()
# ----------------
"""
    ExtractAPhi!( ResHHSolve::Dict, OriginData::Dict ; a1::Float64 = 0.0 )

**(Specially designed for this paper!!!)**

Extract personal asset (a_{s}) (s=1,...S+1) & the individual account of UE-BMI (Φ_{s}) (s=1,...S+1)
from the results of HHSolve();
requiring a Dict created by HHSolve(), a Dict passed to HHSolve() (original data),
and (optional) a_{1} (Φ_{1} is calculated through Φ_{1} = k_{1} - a_{1})
adds new elements (:as, :Φs, :Ms, :MAs, :MBs) to the Dict;
where: len(as)==len(Φs)==S+1, and len(Ms)==len(MAs)==len(MBs)==S
"""
function ExtractAPhi!( ResHHSolve::Dict, OriginData::Dict ; a1::Float64 = 0.0 )
    # compute Φ_{1}
    local Φ1 = ResHHSolve[:ConstPar].k1 - a1
    # assertions
    # @assert( (a1 >= 0.0) & (Φ1 >= 0.0) , "invalid a1 or Phi1, requiring: >= 0"  )
    # 1. the individual account of UE-BMI (Φ_{s})
    # NOTE: account budget:
    #       A_{s} Φ_{s+1} = B_{s} Φ_{s} + newD_{s} l_{s} - newE_{s} c_{s} , s = 1,...,Sr
    #       A_{s} Φ_{s+1} = B_{s} Φ_{s}                  - newE_{s} c_{s} , s = Sr+1,...,S
    #       where:
    #       1. newD_{s} = w_{s}  \frac{ ϕ_{s} + 𝕒_{s} }{ 1 + z_{s} η_{s} + ζ_{s} }
    #       2. newE_{s} = \frac{ q_{s} p_{s} }{ 1 + p_{s} }
    # -----------
    # the abbreviations of indices
    local idxS = 1:ResHHSolve[:ConstPar].S
    local idxSr = 1:ResHHSolve[:ConstPar].Sr
    # define newD (len=Sr) & newE (len=S)
    local newD = OriginData[:w][idxSr] .*
        ( OriginData[:ϕ][idxSr] .+ OriginData[:𝕒][idxSr] ) ./
        ( 1.0 .+ OriginData[:z][idxSr] .* OriginData[:η][idxSr] .+ OriginData[:ζ][idxSr] )
    local newE = OriginData[:q][idxS] .* OriginData[:p][idxS] ./ ( 1.0 .+ OriginData[:p][idxS] )
    # define the series of Φ_{s}
    # NOTE: please note, we have learnt that S > Sr >= 1
    local Φs = [Φ1]
    for s in idxSr
        tmpΦnext = ResHHSolve[:DictPar][:B][s] * Φs[s] + newD[s] * ResHHSolve[:ls][s] - newE[s] * ResHHSolve[:cs][s]
        push!( Φs, tmpΦnext / ResHHSolve[:DictPar][:A][s] )
    end
    for s in (ResHHSolve[:ConstPar].Sr+1):ResHHSolve[:ConstPar].S
        tmpΦnext = ResHHSolve[:DictPar][:B][s] * Φs[s]                                - newE[s] * ResHHSolve[:cs][s]
        push!( Φs, tmpΦnext / ResHHSolve[:DictPar][:A][s] )
    end
    # 2. adjust Φ_{s} to \tilde{Φ}_{s} = [ Φ_{s} , 0.0 ]^+
    local ΦsAdj = max.( Φs , 0.0 )
    # 3. record the difference between Φ_{s} & \tilde{Φ}_{s}
    # NOTE: positive ΦsGap is "gap" (i.e. Φs < 0);
    local ΦsGap = ΦsAdj .- Φs
    # 4. get the personal asset account \tilde{a}_{s}
    local asAdj = ResHHSolve[:ks] .- ΦsAdj

    # 5. get total medical expenditure m_{s}, s=1,...,S
    local MsAdj = ResHHSolve[:cs] .* ResHHSolve[:DictPar][:q]
    # 6. get inpatient expenditure MB_{s}, s=1,...,S
    # NOTE: according to MA_{s}/MB_{s} = p_{s}
    local MBsAdj = MsAdj ./ ( 1.0 .+ OriginData[:p][idxS] )
    # 7. get outpatient expenditure MA_{s}, s=1,...,S
    local MAsAdj = MsAdj .- MBsAdj

    # 5. modifying ResHHSolve
    ResHHSolve[:as] = asAdj; ResHHSolve[:Φs] = ΦsAdj;
    ResHHSolve[:Ms] = MsAdj;
    ResHHSolve[:MAs] = MAsAdj; ResHHSolve[:MBs] = MBsAdj;
    ResHHSolve[:ΦGaps] = ΦsGap

    # nominal returns
    return nothing
end
# ----------
"""
    ExtractAPhi_Retired!( ResHHSolve::Dict, OriginData::Dict ; a1::Float64 = 0.0 )

**(Specially designed for this paper!!!)**

Extract personal asset (a_{s}) (len=S+1) & the individual account of UE-BMI (Φ_{s}) (len=S+1)
from the results of HHSolve_Retired();
requiring a Dict created by HHSolve_Retired(), a Dict passed to HHSolve_Retired() (original data),
and (optional) a_{1} (Φ_{1} is calculated through Φ_{1} = k_{1} - a_{1})
adds new elements (:as, :Φs, :Ms, :MAs, :MBs) to the Dict;
where: len(as)==len(Φs)==S+1, and len(Ms)==len(MAs)==len(MBs)==S
"""
function ExtractAPhi_Retired!( ResHHSolve::Dict, OriginData::Dict ; a1::Float64 = 0.0 )
    # compute Φ_{1}
    local Φ1 = ResHHSolve[:ConstPar].k1 - a1
    # assertions
    # @assert( (a1 >= 0.0) & (Φ1 >= 0.0) , "invalid a1 or Phi1, requiring: >= 0"  )
    # 1. the individual account of UE-BMI (Φ_{s})
    # NOTE: account budget:
    #       A_{s} Φ_{s+1} = B_{s} Φ_{s} - newE_{s} c_{s} , s = 1,...,S
    #       where:
    #       1. newE_{s} = \frac{ q_{s} p_{s} }{ 1 + p_{s} }
    # -----------
    # Cases: S = 1 & S > 1
    if ResHHSolve[:ConstPar].S == 1
        ResHHSolve[:as] = [ a1, 0.0 ]; ResHHSolve[:Φs] = [ Φ1, 0.0 ]
        ResHHSolve[:Ms] = [ ResHHSolve[:cs][1] * ResHHSolve[:DictPar][:q][1] ]
        ResHHSolve[:MBs] = [ ResHHSolve[:Ms][1] / ( 1.0 + OriginData[:p][1] )  ]
        ResHHSolve[:MAs] = ResHHSolve[:Ms] .- ResHHSolve[:MBs]
        ResHHSolve[:ΦGaps] = [0.0, 0.0]  # because we have ensured Φ1>=0
        return nothing
    else
        # the abbreviations of indices
        local idxS = 1:ResHHSolve[:ConstPar].S
        # define newE (len=S)
        local newE = OriginData[:q][idxS] .* OriginData[:p][idxS] ./ ( 1.0 .+ OriginData[:p][idxS] )
        # define the series of Φ_{s}
        # NOTE: please note, we have learnt that S > Sr >= 1
        local Φs = [Φ1]
        for s in 1:ResHHSolve[:ConstPar].S  # NOTE: different from ExtractAPhi()
            tmpΦnext = ResHHSolve[:DictPar][:B][s] * Φs[s] - newE[s] * ResHHSolve[:cs][s]
            push!( Φs, tmpΦnext / ResHHSolve[:DictPar][:A][s] )
        end
        # 2. adjust Φ_{s} to \tilde{Φ}_{s} = [ Φ_{s} , 0.0 ]^+
        local ΦsAdj = max.( Φs , 0.0 )
        # 3. record the difference between Φ_{s} & \tilde{Φ}_{s}
        # NOTE: positive ΦsGap is "gap" (i.e. Φs < 0);
        local ΦsGap = ΦsAdj .- Φs
        # 4. get the personal asset account \tilde{a}_{s}
        local asAdj = ResHHSolve[:ks] .- ΦsAdj

        # 5. get total medical expenditure m_{s}, s=1,...,S
        local MsAdj = ResHHSolve[:cs] .* ResHHSolve[:DictPar][:q]
        # 6. get inpatient expenditure MB_{s}, s=1,...,S
        # NOTE: according to MA_{s}/MB_{s} = p_{s}
        local MBsAdj = MsAdj ./ ( 1.0 .+ OriginData[:p][idxS] )
        # 7. get outpatient expenditure MA_{s}, s=1,...,S
        local MAsAdj = MsAdj .- MBsAdj

        # 5. modifying ResHHSolve
        ResHHSolve[:as] = asAdj; ResHHSolve[:Φs] = ΦsAdj
        ResHHSolve[:Ms] = MsAdj
        ResHHSolve[:MAs] = MAsAdj; ResHHSolve[:MBs] = MBsAdj
        ResHHSolve[:ΦGaps] = ΦsGap

    end  # branch ends

    # nominal returns
    return nothing
end

# --------------
# 6.1 Sample Dataset: both working & retired years, S > Sr > 1
# NOTE: can be created by EasySearch.DatSlice4Household()
# NOTE: will be input to lev0Abbr() or HHSolve()
SampleOrigindata = Dict(
    # ---------- Constants
    :Smax => 40,  # maximum age
    :Sret => 21,  # retirement age
    :alpha => 1.5, # leisure preference than consumption
    :gamma => 0.5, # the inter-temporal elasticity of substitution
    :k1 => 0.0, # capital when born
    # ---------- Vectors
    :Survival => fill(0.99, 40),  # survival probabilities between two years
    :q => fill(0.15, 40),  # the ratio of health expenditure on consumption
    :r => fill(0.08, 40),  # interest rate
    :w => fill(3.25, 21),  # wage level
    :z => fill(0.85, 21),  # the collection rate of PAYG pension
    :θ => fill(0.08, 21),  # contribution: agent -> PAYG pension
    :η => fill(0.20, 21),  # contribution: firm  -> PAYG pension
    :ϕ => fill(0.02, 21),  # contribution: agent -> UEBMI
    :ζ => fill(0.06, 21),  # contribution: firm  -> UEBMI
    :cpB => fill(0.30, 40),  # copayment rate of UEBMI (inhospital)
    :p => fill(1.10, 40),  # the ratio of outpatient expenditure on inpatient expenditure
    :Λ => fill(0.95, 40-21),  # the benefits of PAYG pension
    :𝕡 => fill(0.10, 40-21),  # the amount of the transfer payment from this year's firm contribution to UEBMI to those have retired in this year
    :𝕒 => fill(0.30, 21),  # the rate of the money transferred from this year's firm contribution to those working men's individual account of UEBMI
    # ------------ Constant in this paper but converted to vectors in a standard problem
    :σ => fill(0.24, 21),  # wage taxation
    :μ => fill(0.10, 40),  # consumption taxation
    :δ => fill(1/0.99 - 1, 40), # the discounting rate of utility
)
# 6.2 Sample Dataset (Steady State): both working & retired years, S > Sr > 1
# NOTE: can be created by EasySearch.DatSlice4Household()
# NOTE: will be input to lev0Abbr() or HHSolve()
SampleOrigindata1 = Dict(
    # ---------- Constants
    :Smax => 10,  # maximum age
    :Sret => 1,  # retirement age
    :alpha => 1.5, # leisure preference than consumption
    :gamma => 0.5, # the inter-temporal elasticity of substitution
    :k1 => 0.0, # capital when born
    # ---------- Vectors
    :Survival => fill(0.99, 10),  # survival probabilities between two years
    :q => fill(0.15, 10),  # the ratio of health expenditure on consumption
    :r => fill(0.08, 10),  # interest rate
    :w => fill(3.25, 1),  # wage level
    :z => fill(0.85, 1),  # the collection rate of PAYG pension
    :θ => fill(0.08, 1),  # contribution: agent -> PAYG pension
    :η => fill(0.20, 1),  # contribution: firm  -> PAYG pension
    :ϕ => fill(0.02, 1),  # contribution: agent -> UEBMI
    :ζ => fill(0.06, 1),  # contribution: firm  -> UEBMI
    :cpB => fill(0.30, 10),  # copayment rate of UEBMI (inhospital)
    :p => fill(1.10, 10),  # the ratio of outpatient expenditure on inpatient expenditure
    :Λ => fill(0.95, 10-1),  # the benefits of PAYG pension
    :𝕡 => fill(0.10, 10-1),  # the amount of the transfer payment from this year's firm contribution to UEBMI to those have retired in this year
    :𝕒 => fill(0.30, 1),  # the rate of the money transferred from this year's firm contribution to those working men's individual account of UEBMI
    # ------------ Constant in this paper but converted to vectors
    :σ => fill(0.24, 1),  # wage taxation
    :μ => fill(0.10, 10),  # consumption taxation
    :δ => fill(1/0.99 - 1, 10), # the discounting rate of utility
)
# 6.3 Sample Dataset: only retired years, S > 1
# NOTE: can be created by EasySearch.DatSlice4Household()
# NOTE: will be input to lev0Abbr_Retired() or HHSolve_Retired()
SampleOrigindata_Retired = Dict(
    # ---------- Constants
    :Smax => 40,  # maximum age
    :alpha => 1.5, # leisure preference than consumption
    :gamma => 0.5, # the inter-temporal elasticity of substitution
    :k1 => 10.0, # capital when born
    # ---------- Vectors
    :Survival => fill(0.99, 40),  # survival probabilities between two years
    :q => fill(0.15, 40),  # the ratio of health expenditure on consumption
    :r => fill(0.08, 40),  # interest rate
    # :w => fill(3.25, 21),  # wage level
    # :z => fill(0.85, 21),  # the collection rate of PAYG pension
    # :θ => fill(0.08, 21),  # contribution: agent -> PAYG pension
    # :η => fill(0.20, 21),  # contribution: firm  -> PAYG pension
    # :ϕ => fill(0.02, 21),  # contribution: agent -> UEBMI
    # :ζ => fill(0.06, 21),  # contribution: firm  -> UEBMI
    :cpB => fill(0.30, 40),  # copayment rate of UEBMI (inhospital)
    :p => fill(1.10, 40),  # the ratio of outpatient expenditure on inpatient expenditure
    :Λ => fill(0.95, 40),  # the benefits of PAYG pension
    :𝕡 => fill(0.10, 40),  # the amount of the transfer payment from this year's firm contribution to UEBMI to those have retired in this year
    # :𝕒 => fill(0.30, 21),  # the rate of the money transferred from this year's firm contribution to those working men's individual account of UEBMI
    # ------------ Constant in this paper but converted to vectors
    # :σ => fill(0.24, 21),  # wage taxation
    :μ => fill(0.10, 40),  # consumption taxation
    :δ => fill(1/0.99 - 1, 40), # the discounting rate of utility
)
# 6.4 Sample Dataset: only retired years, S = 1
# NOTE: can be created by EasySearch.DatSlice4Household()
# NOTE: will be input to lev0Abbr_Retired() or HHSolve_Retired()
SampleOrigindata_Retired1 = Dict(
    # ---------- Constants
    :Smax => 1,  # maximum age
    :alpha => 1.5, # leisure preference than consumption
    :gamma => 0.5, # the inter-temporal elasticity of substitution
    :k1 => 10.0, # capital when born
    # ---------- Vectors
    :Survival => fill(0.99, 1),  # survival probabilities between two years
    :q => fill(0.15, 1),  # the ratio of health expenditure on consumption
    :r => fill(0.08, 1),  # interest rate
    # :w => fill(3.25, 21),  # wage level
    # :z => fill(0.85, 21),  # the collection rate of PAYG pension
    # :θ => fill(0.08, 21),  # contribution: agent -> PAYG pension
    # :η => fill(0.20, 21),  # contribution: firm  -> PAYG pension
    # :ϕ => fill(0.02, 21),  # contribution: agent -> UEBMI
    # :ζ => fill(0.06, 21),  # contribution: firm  -> UEBMI
    :cpB => fill(0.30, 1),  # copayment rate of UEBMI (inhospital)
    :p => fill(1.10, 1),  # the ratio of outpatient expenditure on inpatient expenditure
    :Λ => fill(0.95, 1),  # the benefits of PAYG pension
    :𝕡 => fill(0.10, 1),  # the amount of the transfer payment from this year's firm contribution to UEBMI to those have retired in this year
    # :𝕒 => fill(0.30, 21),  # the rate of the money transferred from this year's firm contribution to those working men's individual account of UEBMI
    # ------------ Constant in this paper but converted to vectors
    # :σ => fill(0.24, 21),  # wage taxation
    :μ => fill(0.10, 1),  # consumption taxation
    :δ => fill(1/0.99 - 1, 1), # the discounting rate of utility
)










# -----------------------------------------------------------------------------
# SECTION 7: Commented Test Code 被注释的测试代码
# NOTE: in this section, we provide sample code to test our algorithms
#       本节我们提供测试算法的代码
#       these codes consider 4 different cases in practice, and separately test different functions
#       这些代码考虑了4中实际中会遇见的情形，并分别测试本模块里不同的关键函数
#       they use the sample datasets in SECTION 0 & SECTION 6
#       测试代码使用了第0节和第6节里的样例数据
#       and please import this module, and run these testing codes in another script
#       请导入本模块，并在新脚本里运行测试代码
#       by default, this section is completely commented; keep it commented unless you need to do tests
#       默认情况下这一节是完全被注释掉的，除非需要做测试，否则保持原样
# -----------------
# # Case: both working years & retired years, and S > Sr > 1 正常working + retire
# tmpConst = House.SampleConst; tmpDict = copy(House.SampleLev0Abbr);
# tmpOriginData = House.SampleOrigindata;
# tmpConst, tmpDict = House.lev0Abbr( tmpOriginData )
# House.lev1Abbr!(tmpDict,tmpConst)
# House.lev2Abbr!(tmpDict,tmpConst)
# tmpcs, tmpls = House.getcls( 0.1, tmpDict, tmpConst )
# tmpks = House.getks( tmpcs, tmpls, tmpDict, tmpConst )
# House.G( 0.1, tmpDict, tmpConst )
# @time tmpRes = House.HHSolve( tmpOriginData , ReturnData = true )
# House.ExtractAPhi!( tmpRes, tmpOriginData , a1 = 0.0 )
# # -----------------
# # Case: both working years & retired years, and S > Sr = 1 只有1期working
# tmpConst1 = House.SampleConst1; tmpDict1 = copy(House.SampleLev0Abbr1);
# tmpOriginData1 = House.SampleOrigindata1;
# tmpConst1, tmpDict1 = House.lev0Abbr( tmpOriginData1 )
# House.lev1Abbr!(tmpDict1,tmpConst1)
# House.lev2Abbr!(tmpDict1,tmpConst1)
# tmpcs1, tmpls1 = House.getcls( 0.1, tmpDict1, tmpConst1 )
# tmpks1 = House.getks( tmpcs1, tmpls1, tmpDict1, tmpConst1 )
# House.G( 0.1, tmpDict1, tmpConst1 )
# @time tmpRes1 = House.HHSolve( tmpOriginData1 , ReturnData = true )
# House.ExtractAPhi!( tmpRes1, tmpOriginData , a1 = 0.0 )
# # ----------------
# # Case: only retired years, and S > 1 只有退休期
# tmpConst_Retired = House.SampleConst_Retired; tmpDict_Retired = copy(House.SampleLev0Abbr_Retired);
# tmpOriginData_Retired = House.SampleOrigindata_Retired;
# tmpConst_Retired, tmpDict_Retired = House.lev0Abbr_Retired( tmpOriginData_Retired )
# House.lev1Abbr_Retired!(tmpDict_Retired,tmpConst_Retired)
# House.lev2Abbr_Retired!(tmpDict_Retired,tmpConst_Retired)
# tmpcs_Retired = House.getcls_Retired( 0.1, tmpDict_Retired, tmpConst_Retired )
# tmpks_Retired = House.getks_Retired( tmpcs_Retired, tmpDict_Retired, tmpConst_Retired )
# House.G_Retired( 0.1, tmpDict_Retired, tmpConst_Retired )
# @time tmpRes_Retired = House.HHSolve_Retired( tmpOriginData_Retired , ReturnData = true )
# House.ExtractAPhi_Retired!( tmpRes_Retired, tmpOriginData_Retired , a1 = 0.0 )
# # -----------------
# # Case: only retired years, and S = 1  只有1期退休期
# tmpConst_Retired1 = House.SampleConst_Retired1; tmpDict_Retired1 = copy(House.SampleLev0Abbr_Retired1);
# tmpOriginData_Retired1 = House.SampleOrigindata_Retired1;
# tmpConst_Retired1, tmpDict_Retired1 = House.lev0Abbr_Retired( tmpOriginData_Retired1 )
# House.lev1Abbr_Retired!(tmpDict_Retired1,tmpConst_Retired1)
# House.lev2Abbr_Retired!(tmpDict_Retired1,tmpConst_Retired1)
# tmpcs_Retired1 = House.getcls_Retired( 0.1, tmpDict_Retired1, tmpConst_Retired1 )
# tmpks_Retired1 = House.getks_Retired( tmpcs_Retired1, tmpDict_Retired1, tmpConst_Retired1 )
# House.G_Retired( 0.1, tmpDict_Retired1, tmpConst_Retired1 )
# @time tmpRes_Retired1 = House.HHSolve_Retired( tmpOriginData_Retired1 , ReturnData = true )
# House.ExtractAPhi_Retired!( tmpRes_Retired1, tmpOriginData_Retired1 , a1 = 0.0 )
















































end  # module ends
#
