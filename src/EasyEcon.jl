__precompile__()
"""
    EasyEcon

Easy & friendly mathematics/economics in OLG model;
recommend to using it for fast debugging & mass use
"""
module EasyEcon
    using EasyTypes  # 主要使用其中的快速类型定义 NumVec & NumMat，单个数值请直接使用 Real 抽象类型

# ==============================================================================
    """
        CDProdFunc( A::Real, K::Real, L::Real, β::Real; κ::Real = 0.05, GetPrice::Bool = true, TechType::String = "Hicks"  )

    Cobb-Douglas production function, where A is technology, K is capital, L is labour, β is income share of capital;
    allows three types of technology: "Hicks", "Harod" & "Solow", controled by TechType parameter;
    if GetPrice is true, separately returns: output (Y), equilibrium NET interest rate (r-κ) & equilibrium wage level (w̄);
    where the capital depreciation rate is controled by keyword parameter κ;
    if GetPrice is false, only returns: output (Y), a real number
    """
    function CDProdFunc( A::Real, K::Real, L::Real, β::Real; κ::Real = 0.05, GetPrice::Bool = true, TechType::String = "Hicks"  )
        # 1. bounding check
        tmp = [A,K,L,β,κ]
        @assert( all(tmp .> 0), string("bound failure [A,K,L,β,κ], all positive required: ",tmp) )
        # 2. compute
        if TechType == "Hicks"
            Y = A * K^β * L^(1-β)
            if GetPrice
                r = β * A * (K/L)^(β-1) - κ
                w̄ = (1-β) * A * (K/L)^β
                return Y::Real, r::Real, w̄::Real
            else
                return Y::Real
            end
        elseif TechType == "Harod"
            Y = K^β * (A * L)^(1-β)
            if GetPrice
                r = β * (K/A/L)^(β-1) - κ
                w̄ = (1-β) * A * (K/A/L)^β
                return Y::Real, r::Real, w̄::Real
            else
                return Y::Real
            end
        elseif TechType == "Solow"
            Y = (A * K)^β * L^(1-β)
            if GetPrice
                r = β * (A*K/L)^(β-1) - κ
                w̄ = (1-β) * (A*K/L)^β
                return Y::Real, r::Real, w̄::Real
            else
                return Y::Real
            end
        else
            throw( ErrorException("invalid TechType, pls choose from \"Hicks\", \"Harod\", \"Solow\"") )
        end
        return nothing
    end

    # --------------------------------------------
    """
        TerraProdFunc( A::Real, L::Real, T::Real; GetPrice::Bool = true )

    production function with constant land ``T``: `` Y = A T L ``, where ``L`` is labour supply (all incomes to it);
    if GetPrice is true, separately returns: output (Y), equilibrium (marginal also average) wage level (w̄);
    if false, only retuns: output (Y);
    """
    function TerraProdFunc( A::Real, L::Real, T::Real; GetPrice::Bool = true )
        # 1. bound check
        tmp = [A,L,T]
        @assert( all(tmp .> 0), string("positive constraint against: [A,L,T] ",tmp) )
        # 2. compute
        Y = A * T * L
        if GetPrice
            w̄ = A * T
            return Y::Real, w̄::Real
        else
            return Y::Real
        end
        return nothing
    end

    # --------------------------------------------
    """
        WageProfile( w̄::Real, ε::Vector, Nst::Vector, Lst::Vector; GetScalingCoef::Bool = false  )

    profile wage among different working cohorts in year t where age ``s=1,...,S_r`` (``S_r`` is retiring age);
    using equation: ``w̄ L_{t} = \\sum^{S_r}_{s=1} w_{s,t} L_{s,t} N_{s,t}``;
    where ``L_{t} = \\sum^{S_r} L_{s,t}N_{s,t}`` is labour supply, ``w_{s,t} = o_{t} \varepsilon_{s}`` is wage profiling,
    ``o_{t}`` is a year-specific scaling coefficient (computed by the equation), ``\varepsilon_{s}`` is age-specific profiling coefficients;
    using Lst for ``L_{s,t}``, and Nst for ``N_{s,t}``;
    if GetSaclingCoef is true, separately returns: wprofiled::Vector (``w_{s,t}``), o::Real (``o_{t}``);
    if false, only returns: wprofiled;
    """
    function WageProfile( w̄::Real, ε::Vector, Nst::Vector, Lst::Vector; GetScalingCoef::Bool = false  )
        # 1. size check
        @assert( length(ε) == length(Nst) == length(Lst), "requires same length: ε, Nst, Lst" )
        # 2. compute
        L = sum( Nst .* Lst )  # get total labour supply
        o = L / sum( Nst .* Lst .* ε )  # get scaling coefficient
        wprofiled = w̄ .* o .* ε  # get profiled wage levels
        # 3. return
        if GetScalingCoef
            return wprofiled::Vector, o::Real
        else
            return wprofiled::Vector
        end
        return nothing
    end

    # --------------------------------------------
    # """
    #     tmp()
    #
    #
    #
    # """
    # function tmp()
    #
    #
    #
    #     return nothing
    # end
    #




















# ==============================================================================
end  # module ends
