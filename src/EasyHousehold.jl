__precompile__()
"""
    EasyHousehold

a module for utility optimization problems in household department;
uses adjusted analytical solution; DP has been roughly deprecated.
"""
    module EasyHousehold
        import Roots: find_zero, Bisection  # using root searching method in package Root (faster than Bisection() written by myself)


    # ---------------------------------------------
    """
        u(c::Real, l::Real, q::Real, γ::Real, α::Real)

    cross-sectional utility function;
    a divisible CES one: ``u = \\frac{1}{1-\\gamma^{-1}} [ ((1-q)c)^{1-\\gamma^{-1}} + \\alpha l^{1-\\gamma^{-1}}   ] ``;
    where ``\\gamma`` is inter-temporal elasticity of substitution, ``\\alpha`` is leisure preference;
    c is consumption, l is leisure, q is ratio of total medical expenditure to total consumption (c);
    returns a utility value

    p.s.:
    1. minor amounts are added to avoid Inf at zero
    2. no validation (it should have been ``c,l>0`` and ``0 \\leq q \\leq 1``)
    """
    function u(c::Real, l::Real, q::Real, γ::Real, α::Real)
        uval = 1/(1-1/γ) * (  ( (1-q) * c + 1E-12 )^(1-1/γ)  +  α * ( l + 1E-12 )^(1-1/γ)  )
        return uval::Real
    end

    # ---------------------------------------------
    """
        LifeDecision( a0::Real, Φ0::Real, Pc::Dict, d::Dict{Symbol,Vector{Float64}}, S::Int, Sr::Int )

    solves lifetime utility optimization problem through adjusted-analytical method;
    where a0 & Φ0 are initial values when paths begin (for personal asset **a** and individual medical account **Φ**);
    and where **Pc** is a dictionary of constant parameters defined in *proc_InitPars.jl* (not all members used but you may pass it for convenience);
    and **d** is a dictionary of data used in decision making (listed below);
    and **S** is MAX_AGE, **Sr** is RETIRE_AGE;
    no bequest left;
    returns a collection (NamedTuple) of solved paths (listed below);

    p.s.: I strictly assert type of **d** to avoid possible numerical errors

    ## Essential Members of **Pc**
    1. μ [num]: consumption tax rate
    2. σ [num]: wage tax rate
    3. α [num]: leisure preference (used in utiltiy function)
    4. γ [num]: inter-temporal elasticity of substitution (used in utility function)
    5. δ [num]: utility discounting rate (used in Lagrange function)

    ## Essential Members of **d** (all 1d arrays/vectors)
    1. length = S (MAX-AGE)
        1. :r : interest rates
        2. :F : mortality, the last element should be 0
        3. :q : ratio of total medical expenditure to total consumption
        4. :p : ratio of outpatient to inpatient expenditure
        5. :cpB : co-payment rate of inpatient expenditure
    2. length = Sr (RETIRE-AGE)
        1. :ϕ : contribution rate from household to UE-BMI
        2. :ζ : contribution rate from firm to UE-BMI
        3. :η : contribution rate from firm to PAYG pension
        4. :θ : contribution rate from household to PAYG pension
        5. :z : collection rate of the PAYG pension
        6. :w : wage levels
        7. :𝕒 : transfer **RATE** (not amount!!!) from firm contribution to working households
    3. length = S-Sr
        1. :Λ : pension benefit **amounts**
        2. :𝕡 : transfer **AMOUNT** (not rate!!!) from firm contribution to retired households
    4. p.s.: 𝕡 is amount of capital because we need external information of the macro-economy to get their values; it is not a good idea to do this in such an isolated household decision making function

    ## Members of returned NamedTuple (ordered, as well by name):
    1. 𝒜 [Vector{Float64},len=S]: wealth path
    2. a [Vector{Float64},len=S]: personal asset path
    3. Φ [Vector{Float64},len=S]: individual medical account
    4. c [Vector{Float64},len=S]: consumption path
    5. l [Vector{Float64},len=Sr]: leisure path in **working** years

    ## Depends on: function [module]
    1. u [EasyHousehold]: cross-sectional utility function
    2. AddAbbrs! [EasyHousehold]: define a series of abbreviations and add them to data dictionary
    3. GetC [EasyHousehold]: get consumption path from data and abbreviations
    4. Get𝒜, Geta, GetΦ [EasyHousehold]: get paths of wealth, personal asset, individual medical account
    5. find_zero [Roots]: search a c(1) which makes 𝒜dead == 0
    """
    function LifeDecision( a0::Real, Φ0::Real, Pc::Dict, d::Dict{Symbol,Vector{Float64}}, S::Int, Sr::Int )
        ## Section 1: validation 合法性检查
            # 1.1 too-short path length
            @assert( S>2 & 1<=Sr<=S, "too short path to solve, requiring: S > 2 and 1 ≦ Sr ≦ S" )
            # 1.2 interest rate cannot be -1 (zero domain)
            @assert( all(d[:r] .!= -1.0), "invalid interest rate found: -1"   )
            # 1.3 utility discounting rate cannot be -1 (zero domain)
            @assert( Pc[:δ] != -1.0, "invalid utility discounting rate δ: -1" )
            # 1.4 mortality in the very last year/age must be 0 (if not, correct it)
            d[:F][end] = 0.0
        ## Section 2: prepare members of result collection 准备结果变量
            Ret = Dict(
                :𝒜 => fill(a0 + Φ0, S),  # wealth
                :a => fill(a0, S),  # personal asset
                :Φ => fill(Φ0, S),  # individual medical account
                :c => zeros(S),  # total consumption
                :l => zeros(Sr),  # leisure
            )

        ## Section 3: abbreviations 定义一批缩写以简化运算
        # NOTE: pls refer to academic documents to learn mathematics about these defined abbreviation variables
        # NOTE: use an in-place function to clear format code; the results are written/added into d
            AddAbbrs!(a0,Φ0,Pc,d,S,Sr)  # using the same parameter combinition & order for convenience

        ## Section 4: get un-limited soltion & check endowment constraints 先求一个不含禀赋约束的解路径，并检查是否满足（本来就是内点解，不需要矫正）
            # 1. get un-limited consumption path (validation integrated)
            Ret[:c] = GetC( d, S, Sr, Ret[:𝒜][1], givenleisure = nothing )
            # 2. get un-limited leisure path through leisure → consumption relationship
            for s in 1:Sr
                Ret[:l][s] = Ret[:c][s] * (1.0 - d[:q][s]) / d[:ℛ][s] ^ Pc[:γ]
            end
            # 3. check if all leisure is valid, set a flag
            flag_NeedAdjust = false
            all( 0.0 .<= Ret[:l] .<= 1.0 )  ||  (flag_NeedAdjust = true)

        ## Section 5: adjust leisure path if it touches bounds, then adjust consumptions correspondingly (to meet budgets) 若闲暇touch到了上下界，那么修正闲暇并随即修正消费（使满足预算约束）
        # NOTE: the section only runs when flag_NeedAdjust == true
        if flag_NeedAdjust
            # 1. find out which points are out of the bounds [0,1]
            LocOut0 = Ret[:l] .< 0.0; LocOut1 = Ret[:l] .> 1.0
            # 2. forcely adjust these points to be just at the bounds
            Ret[:l][LocOut0] .= 0.0; Ret[:l][LocOut1] .= 1.0
            # 3. get consumption path based on limited leisure (validation integrated)
            Ret[:c] = GetC( d, S, Sr, Ret[:𝒜][1], givenleisure = Ret[:l] )
        end

        ## Section 6: use convenient functions to get full asset, wealth and individual medical account paths 使用额外的函数计算完整的资产路径
            # 1. total wealth (𝒜 = a + Φ), returns a path and a real number of wealth at dead moment
            Ret[:𝒜], tmp𝒜dead = Get𝒜( d, Ret[:c], Ret[:l], S, Sr, a0 + Φ0 )
            # 2. individual medical account (Φ), returns a path (non-negative) and a gap path
            Ret[:Φ], tmpGap = GetΦ( d, Ret[:c], Ret[:l], S, Sr, Φ0 )
            # 2. personal asset (a), only returns a path, but use tmpGap to adjust the path
            Ret[:a] = Geta( d, Ret[:c], Ret[:l], S, Sr, a0 )
            Ret[:a] .+= tmpGap

        ## Section 7: check if the relationship 𝒜 = a + Φ met; then check if no-bequest constraint met 检查是否符合相加关系，以及是否满足无遗产约束            return Ret
            @assert( all(isapprox.(Ret[:𝒜], Ret[:a] .+ Ret[:Φ], atol = 1E-6)) , "relationship scrA = a + Phi not met"   )
            if isapprox(tmp𝒜dead, 0.0, atol = 1E-6)
                return Ret::Dict
            end

        ## Section 8: search a c(1) which results in 𝒜dead == 0 搜一个c(1)，使得死亡时财富为0
        # NOTE: keep Euler equation determined; keep leisure path determined (cauz we've adjusted it)
        # NOTE: use bisection method to search the zero point (scriptA_dead = 0)
            # 1. an object function, receiving c(1), returns 𝒜dead
            objfunc(tmpc1::Real) = begin
                tmppath_c = tmpc1 .* d[:𝒯]  # get a temporary consumption path
                return Get𝒜(d,tmppath_c,Ret[:l], S, Sr, a0 + Φ0)[2]  # only return the 2nd element (𝒜 at dead moment)
            end
            # 2. search a root, using c(1) on the unlimited path as initial guess
            # NOTE: the monotonicity (decreasing) of function 𝒜dead = 𝒜dead( c(1) ) can be wasily proved, and 𝒜dead(0) > 0 ensured
            # NOTE: using bisection searching
                # 2.1 set search range
                tmpVal = Ret[:c][1] # use unlimited c(1) as initial guess
                tmpBisecRange = [0.0, 0.0] # a range for bisection searching, where the left bound must be 0 (𝒜dead(0) >= 0), so we need to ensure 𝒜dead(rightbound) < 0
                while objfunc(tmpVal) >= 0.0  # there are two cases: tmpVal > 0 or tmpVal < 0; if <0, just use tmpVal as the right bound of search, if >0, find a tmpVal large enough to make 𝒜dead(tmpVal) < 0
                    tmpVal *= 2.0
                end
                tmpBisecRange[2] = tmpVal
                # 2.2 search c(1) through Bisection searching
                Ret[:c][1] = find_zero(objfunc, tmpBisecRange, Bisection())
            # 3. get complete consumption path (through Euler Equation)
            Ret[:c][:] = Ret[:c][1] .* d[:𝒯]

        ## Section 9: get 𝒜, a, Φ paths 得到财富、资产和个人医保账户的路径
        # NOTE: nearly the same as section 6
            # 1. total wealth (𝒜 = a + Φ), returns a path and a real number of wealth at dead moment
            Ret[:𝒜], tmp𝒜dead = Get𝒜( d, Ret[:c], Ret[:l], S, Sr, a0 + Φ0 )
            # 2. individual medical account (Φ), returns a path (non-negative) and a gap path
            Ret[:Φ], tmpGap = GetΦ( d, Ret[:c], Ret[:l], S, Sr, Φ0 )
            # 2. personal asset (a), only returns a path, but use tmpGap to adjust the path
            Ret[:a] = Geta( d, Ret[:c], Ret[:l], S, Sr, a0 )
            Ret[:a] .+= tmpGap

        ## Section 10: validate results 结果合法性验证
            # 1. relationship: 𝒜 = a + Φ
            @assert( all(isapprox.(Ret[:𝒜], Ret[:a] .+ Ret[:Φ], atol = 1E-6)) , "relationship scrA = a + Phi not met"   )
            # 2. constraint: c >= 0
            @assert( all(Ret[:c] .>= 0.0) , "consumptions are requested to be greater than or equal to 0" )

        return Ret::Dict
    end
    # ---------------------------------------------
    """
        AddAbbrs!( a0::Real, Φ0::Real, Pc::Dict, d::Dict{Symbol,Vector{Float64}}, S::Int, Sr::Int  )

    a **in-place** method, adding abbreviations to **d**;
    receives the same parameter combinition as LifeDecision() for convenience;
    return nothing;
    """
    function AddAbbrs!( a0::Real, Φ0::Real, Pc::Dict, d::Dict{Symbol,Vector{Float64}}, S::Int, Sr::Int  )
        # NOTE: pls refer to academic documents to learn mathematics about these defined abbreviation variables
        # Abbrevation Level: 1
            # total pension contribution rate on nomial wage level w
            d[:π] = d[:z] .* ( d[:θ] .+ d[:η] ) ./ ( 1.0 .+ d[:z] .* d[:η] .+ d[:ζ] )
            # total medical contribution rate on nomial wage level w
            d[:πM] = ( d[:ϕ] .+ d[:ζ] ) ./ ( 1.0 .+ d[:z] .* d[:η] .+ d[:ζ] )
        # Abbreviation Level: 2
            d[:𝒶] = 1.0 .- d[:F]  # survival probability
            d[:𝒷] = 1.0 .- Pc[:σ] .- d[:π] .- d[:πM]  # multiplier on nomial wage level in personal asset budgets
            d[:𝒹] = d[:q] .* ( d[:p] .+ (1.0 .- d[:cpB]) ) ./ (1.0 .+ d[:p]) # multiplier on total consumption c to get the part of inpatient expenditure covered by PAYG pool fund of UE-BMI
            d[:𝒻] = ( d[:ϕ] .+ d[:𝕒] .* d[:ζ] ) ./ ( 1.0 .+ d[:z] .* d[:η] .+ d[:ζ] )  # multiplier on nomial wage level, which denotes the transferred part from firm contribution to individual medical account Φ
            d[:ℊ] = -1.0 .* d[:q] .* d[:p] ./ (1.0 .+ d[:p])  # multiplier on total consumption, denoting full bill of outpatient expenditure
            d[:𝒽] = d[:q] .* (1.0 .- d[:cpB]) ./ (1.0 .+ d[:p])  # multiplier on total consumption, denoting full bill of inpatient expenditure
            d[:𝒿] = d[:Λ] .+ d[:𝕡]  # total incomes (pension benefits & transfer payments from UE-BMI) in retired years
        # Abbreviation Level: 2.5
            # capital discounting factors
            d[:V] = cumprod( 1.0 ./ (1.0 .+ d[:r]) ) # NOTE: Julia supports any-precision floating computation, which allows us to directly use cumproduction rather than convert it to logarithms.
            # adjust the Discounting factors by mortalities (pls refer to academic documents to learn why to do so)
            d[:V] ./= d[:𝒶]
            # utility discounting factors (mortality considered) (mark:\tilde\beta)
            d[:βtilde] = ( 1.0 ./ (1.0 .+ Pc[:δ]) ) .^ ( 0:(S-1) )
            d[:βtilde] .*= d[:𝒶]
        # Interval: Essential Validation
            @assert( all(0.0 .< d[:𝒽] .< 1.0) , "scrh is required to be in the open range (0,1)"  ) # NOTE: or there will be numerical collapses in consumptions; however, in fact, according to the definition of \scripth, we have secured the condition in previous validations in "AmmoReload_DATA_w()" function; if much worse performance here, consider ignore/comment this validation process
            @assert( all(d[:𝒷] .+ d[:𝒻] .> 0.0) , "scrb + scrf should be greater than 0"  ) # NOTE: or all wage incomes are contributed/taxed, no left to consume
        # Abbreviation Level: 3
            # part of inter-temporal function c(s) = 𝒯[c(1)], as a multiplier
            # NOTE: len = S - 1; 𝒫[s] works on c(s)
            d[:𝒫] = (1.0 .+ d[:r][2:S]) ./ (1.0 .+ Pc[:δ])
            d[:𝒫] .*= (1.0 .- d[:𝒽][1:S-1]) ./ (1.0 .- d[:𝒽][2:S])
            # another component of 𝒯(c) function
            d[:𝒬] = (1.0 .- d[:q][1:S-1]) ./ (1.0 .- d[:q][2:S])
            # multiplier in leisure → consumption relationship; NOTE: len = Sr - 1
            d[:ℛ] = (1.0 .- d[:q][1:Sr]) .* (d[:𝒷] .+ d[:𝒻]) .* d[:w] ./ (1.0 .- d[:𝒽][1:Sr])
            d[:ℛ] ./= Pc[:α]
        # Interval: Essential Validation
            @assert( all(d[:𝒫] .> 0) , "invalid scrP which leads to invalid consumpton path"   )
            @assert( all(d[:𝒬] .> 0) , "invalid scrQ which leads to invalid consumpton path"   )
            @assert( all(d[:ℛ] .> 0) , "invalid scrR which leads to invalid consumpton path"   )
        # Abbreviation Level: 4
            # multiplier in accumulated Euler equatino function c(s) = 𝒯[c(1)]
            # NOTE: len = S; because c(1) = 𝒯[c(1)]
            d[:𝒯] = ones(S)
            for s in 1:S-1
                d[:𝒯][s+1] = d[:𝒫][s] ^ Pc[:γ] * d[:𝒬][s] ^ (1.0 - Pc[:γ])
            end
            d[:𝒯] = cumprod(d[:𝒯])
        # Interval: Essential Validation
            @assert( all(d[:𝒯] .> 0.0) , "invalid scrT which leads to invalid consumption path"  )

        return nothing
    end

    # ---------------------------------------------
    """
        GetC( d::Dict{Symbol,Vector{Float64}}, S::Int, Sr::Int, 𝒜0::Real ; givenleisure::Union{Nothing,Vector{Float64}} = nothing )

    use data & abbreviations to get path of consumption;
    if an exogenous leisure path (len=Sr) given, use it, or use leisure → consumption (unlimited problem) relationship
    *givenleisure* is nothing by default, which means use leisure → consumption relationship;
    returns a Vector{Float64} of consumption (len=S);
    """
    function GetC( d::Dict{Symbol,Vector{Float64}}, S::Int, Sr::Int, 𝒜0::Real ; givenleisure::Union{Nothing,Vector{Float64}} = nothing )
        path_c = ones(S)  # prepare an empty path for consumption
        if givenleisure == nothing
            # 1. define abbreviations in final equation about c(1)
                # left side of final equation about c(1) (a number, as domain)
                # NOTE: for unlimited solution (without endowment constraints)
                tmp𝒳 = sum( d[:V][1:Sr] .* (d[:𝒷] .+ d[:𝒻]) .* d[:w] .* (1.0 .- d[:𝒬][1:Sr]) .* d[:𝒯][1:Sr] )
                tmp𝒳 += sum( d[:V] .* (1.0 .- d[:𝒽]) .* d[:𝒯] )
                # right side of final equation about c(1) (a number)
                tmp𝒴 = sum( d[:V][1:Sr] .* (d[:𝒷] .+ d[:𝒻]) .* d[:w] )
                tmp𝒴 += d[:V][1] * 𝒜0
                tmp𝒴 += sum( d[:V][Sr+1:S] .* d[:𝒿] )
            # Interval: Essential Validation
            @assert( tmp𝒳 != 0.0 , "zero scriptX leads to Inf consumption!"   )
            # 2. get consumption in the 1st year
            path_c[1] = ( tmp𝒴 / tmp𝒳 ) * (1.0 + d[:r][1])  # discount to s = 1
            # 3. use c(s) = 𝒯[c(1)] to get complete consumption path
            path_c[:] = path_c[1] .* d[:𝒯]
        else  # (if leisure path given)
            # 1. define abbreviations
                tmp𝒳 = sum( d[:V] .* (1.0 .- d[:𝒽]) .* d[:𝒯] )
                tmp𝒴 = sum( d[:V][1:Sr] .* (d[:𝒷] .+ d[:𝒻]) .* d[:w] .* (1.0 .- givenleisure) )
                tmp𝒴 += d[:V][1] * 𝒜0
                tmp𝒴 += sum( d[:V][Sr+1:S] .* d[:𝒿] )
            # Interval: Essential Validation
            @assert( tmp𝒳 != 0.0 , "zero scriptX leads to Inf consumption!"   )
            # 2. get new consumption path
            path_c[1] = ( tmp𝒴 / tmp𝒳 ) * (1.0 + d[:r][1])  # discount to s = 1
            path_c[:] = path_c[1] .* d[:𝒯]
        end
        # check if all consumptions are valid
        @assert( all(0.0 .<= path_c .< Inf) , "negative or Inf consumption found in unlimited problem"  )
        return path_c::Vector{Float64}
    end

    # ---------------------------------------------
    """
        Get𝒜( d::Dict{Symbol,Vector{Float64}}, path_c::Vector, path_l::Vector, S::Int, Sr::Int, 𝒜0::Real )

    get lifetime wealth path (𝒜) using inter-temporal budgets;
    requiring consumption path (path_c, len=S) & leisure path (path_l, len=Sr);
    return a collection in order:
    1. path_𝒜 [len=S]: lifetime wealth path
    2. 𝒜dead [Real]: left wealth when dead (end of the last year, the beginning of S+1 year)

    p.s.: the 𝒜dead is used to search c(1) which make 𝒜 meet the constraint of no bequest
    """
    function Get𝒜( d::Dict{Symbol,Vector{Float64}}, path_c::Vector, path_l::Vector , S::Int, Sr::Int, 𝒜0::Real )
        # 1. malloc
        path_𝒜 = fill(𝒜0,S); 𝒜dead = 0.0
        # 2. working years
        for s in 1:Sr
            path_𝒜[s+1] = (1+d[:r][s]) * path_𝒜[s] + ( d[:𝒷][s] + d[:𝒻][s] ) * d[:w][s] * (1.0 - path_l[s]) - (1.0 - d[:𝒽][s]) * path_c[s]
            path_𝒜[s+1] /= d[:𝒶][s]  # adjusted by mortality
        end
        # 3. retired years
        # NOTE: the loop is disigned for case: S-Sr>=1, if S=Sr, only need to run section 4
        if S - Sr >= 1
            for s in Sr:S-1
                path_𝒜[s+1] = (1+d[:r][s]) * path_𝒜[s] + d[:𝒿][s-Sr+1] - (1.0 - d[:𝒽][s]) * path_c[s]
                path_𝒜[s+1] /= d[:𝒶][s]  # adjusted by mortality
            end
        end
        # 4. get wealth when dead (at end of year S)
        𝒜dead = (1+d[:r][S]) * path_𝒜[S] + d[:𝒿][S-Sr] - (1.0 - d[:𝒽][S]) * path_c[S]
        # returns
        return path_𝒜::Vector, 𝒜dead::Real
    end

    # ---------------------------------------------
    """
        Geta( d::Dict{Symbol,Vector{Float64}}, path_c::Vector, path_l::Vector , S::Int, Sr::Int, a0::Real )

    gets personal asset (a) by inter-temporal budgets;
    assumes all outpatient bills are fully paid by Φ, does not consider possible gaps;
    returns a Vector of personal asset
    """
    function Geta( d::Dict{Symbol,Vector{Float64}}, path_c::Vector, path_l::Vector , S::Int, Sr::Int, a0::Real )
        # 1. malloc
        path_a = fill(a0,S)
        # 2. working years
        for s in 1:Sr
            path_a[s+1] = (1.0 + d[:r][s]) * path_a[s] + d[:𝒷][s] * d[:w][s] * (1.0 - path_l[s]) - (1.0 - d[:𝒹][s]) * path_c[s]
            path_a[s+1] /= d[:𝒶][s]
        end
        # 3. retired years
        # NOTE: the loop is for the case S-Sr>=1, if S=Sr, just return
        if S - Sr >= 1
            for s in Sr:S-1
                path_a[s+1] = (1.0 + d[:r][s]) * path_a[s] + d[:Λ][s-Sr+1] - (1.0 - d[:𝒹][s]) * path_c[s]
                path_a[s+1] /= d[:𝒶][s]
            end
        end
        # return
        return path_a::Vector
    end

    # ---------------------------------------------
    """
        GetΦ( d::Dict{Symbol,Vector{Float64}}, path_c::Vector, path_l::Vector , S::Int, Sr::Int, Φ0::Real )

    gets individual medical account path (Φ);
    has Φ(s) >= 0 constraint;
    returns a collection in order:
    1. path_Φ [Vector]: individual medical account path
    2. path_gap [Vector]: min.( 0.0 , Φ ), latent gap which will be covered by personal asset (a)

    p.s.: add path_a from Geta() to path_gap, to get adjusted personal asset path (considered non-negative constraint of Φ)
    """
    function GetΦ( d::Dict{Symbol,Vector{Float64}}, path_c::Vector, path_l::Vector , S::Int, Sr::Int, Φ0::Real )
        # 1. malloc
        path_Φ = fill(Φ0, S); path_gap = zeros(S)
        # 2. working years
        for s in 1:Sr
            path_Φ[s+1] = (1.0 + d[:r][s]) * path_Φ[s] + d[:𝒻][s] * d[:w][s] * (1.0 - path_l[s]) + d[:ℊ][s] * path_c[s]
            path_Φ[s+1] /= d[:𝒶][s]
        end
        # 3. retired years
        # NOTE: the loop is for the case S-Sr>=1, if S=Sr, just return
        if S - Sr >= 1
            for s in Sr:S-1
                path_Φ[s+1] = (1.0 + d[:r][s]) * path_Φ[s] + d[:𝕡][s-Sr+1] + d[:ℊ][s] * path_c[s]
                path_Φ[s+1] /= d[:𝒶][s]
            end
        end
        # 4. get gaps, and adjust Φ path to non-negative
        for s in 1:S
            path_gap[s] = min( 0.0, path_Φ[s] )
            path_Φ[s] = max( 0.0, path_Φ[s] )
        end
        # return
        return path_Φ::Vector, path_gap::Vector
    end










    # ---------------------------------------------
    """
        GetTestData(a0::Real,Φ0::Real,S::Int,Sr::Int)

    generates a template **d** and **Pc** for testing LifeDecision()
    returns two Dict{Symbol,Vector{Float64}} in order: (Pc, d)
    """
    function GetTestData(S::Int,Sr::Int)
        d = Dict(
            # -------- len = S
            :r => fill(0.07,S), # interest rates
            :F => fill(0.01,S), # mortality
            :q => fill(0.15,S), # m2c ratio
            :p => fill(1.11,S), # MA/MB ratio
            :cpB => fill(0.30,S), # co-payment rate of inpatient expenditure
            # -------- len = Sr
            :ϕ => fill(0.02,Sr), # contribution: agent → UEBMI
            :ζ => fill(0.85,Sr), # contribution: firm → UEBMI
            :η => fill(0.20,Sr), # contribution: firm → pension
            :θ => fill(0.08,Sr), # contribution: agent → pension
            :z => fill(0.85,Sr), # collection rate of pension
            :w => fill(1.21,Sr), # wage level
            :𝕒 => fill(0.30,Sr), # transfer rate from firm contribution of UEBMI to working agents
            # -------- len = S - Sr
            :Λ => fill(0.25,S-Sr), # pension benefit amounts
            :𝕡 => fill(0.10,S-Sr), # transfer amounts from firm contribution of UEBMI to retired agents
        )
        Pc = Dict(
            :κ => 0.05,  # depreciation rate 折旧率
            :μ => 0.10,  # consumption tax rate 消费税率
            :σ => 0.24,  # income tax rate 工资税率
            :δ => 1/0.99 - 1,  # utility discounting rate 效用折现率，若令效用折现因子为0.99，则对应0.0101010101...
            :α => 1.5,  #　leisure preference than consumption 闲暇对消费的偏好系数
            :γ => 0.5,  # inter-temporal substitution elasticity 跨期替代弹性
        )
        return Pc = Pc::Dict, d::Dict{Symbol,Vector{Float64}}
    end



# ==============================================================
end # module ends
#
