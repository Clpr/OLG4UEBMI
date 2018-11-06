__precompile__()
"""
    EasyEcon

Easy & friendly mathematics/economics in OLG model;
recommend to using it for fast debugging & mass use
"""
module EasyEcon


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
        WageProfile( w̄::Real, ε::Vector, Nst::Vector, Lst::Vector; GetScalingCoef::Bool = false  )

    profile wage among different working cohorts in year t where age ``s=1,...,S_r`` (``S_r`` is retiring age);
    using equation: ``w̄ L_{t} = \\sum^{S_r}_{s=1} w_{s,t} L_{s,t} N_{s,t}``;
    where ``L_{t} = \\sum^{S_r} L_{s,t}N_{s,t}`` is labour supply, ``w_{s,t} = o_{t} \varepsilon_{s}`` is wage profiling,
    ``o_{t}`` is a year-specific scaling coefficient (computed by the equation), ``\varepsilon_{s}`` is age-specific profiling coefficients;
    using Lst for ``L_{s,t}``, and Nst for ``N_{s,t}``;
    if GetSaclingCoef is true, separately returns: wprofiled::Vector (``w_{s,t}``), o::Real (``o_{t}``);
    if false, only returns: wprofiled;

    ## Inputs:
    1. ̄w: average wage level
    2. ε: wage profiling coefficient
    3. Nst: working population vector
    4. Lst: labour vector (1 - leisure)
    5. GetScalingCoef: if to return the wage scaling coefficient
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
    """
        PAYGPension( πCoef::Real, w::Vector, N::Vector, Lab::Vector, Sr::Int )

    Computes an average pension benefit amount for retired popultion:
        `` \\pi_{t} \\sum^{S_r}_{s=1} w_{s,t} N_{s,t} L_{s,t} = \\Lambda_{t} \\sum^{S}_{s>S_r} N_{s,t}``
    where ``\\pi_{t}`` is total contribution rate in year ``t``, ``L_{s,t}`` is labor supply vector, ``\\Lambda_{t}`` is average pension benefit amount in year ``t``, ``N_{s,t}`` is population.

    ##Inputs:
    1. πCoef : ``\\pi_{t}``
    2. w : ``w_{s,t}``, nomial wage level, len = Sr
    3. N : compelete population, from 1 to Sr (retirement age) to S (max age), len = S
    4. Lab : ``L_{s,t} = 1 - l_{s,t}``, where ``l_{s,t}`` is leisure, len = Sr
    5. Sr : retirement age

    returns a Real number, the average pension benefit amount ``\\Lambda_{t}``.
    """
    function PAYGPension( πCoef::Real, w::Vector, N::Vector, Lab::Vector, Sr::Int )
        # 1. size check
        @assert( length(w) == length(N[1:Sr]) == length(Lab), "uncompatible vector size: w, Nwork or Lab"  )
        # 2. accounting
        local Λ::Float64
        Λ = πCoef * sum( w .* N[1:Sr] .* Lab ) / sum( N[Sr+1:end] )
        return Λ
    end

    # --------------------------------------------
    """
        Get𝕡( 𝕓::Real, πMf::Real, w::Vector, L::Vector, N::Vector, Sr::Int )

    Gets transfer payment amount 𝕡 from firm contribution to UE-BMI in year ``t`` to those retired in this year.
    based on a transfer rate 𝕓.

    ## Inputs:
    1. 𝕓: transfer rate/fraction from firm total contribution amount (to UE-BMI) to retired generations
    2. πMf: total contribution rate by firm on nomial wage level ``w_{s,t}``; it is defined as: ``\\pi^{Mf} = \\frac{\\zeta_{t}}{1+z \\eta + \\zeta}``
    3. w: nomial wage level vector, len = Sr
    4. Lab: labor supply, len = Sr
    5. N: population, len = S (env.MAX_AGE)
    6. Sr: retirement age

    returns a Real number 𝕡, the transfer payment amount per capita to retired generations.
    """
    function Get𝕡( 𝕓::Real, πMf::Real, w::Vector, Lab::Vector, N::Vector, Sr::Int )
        # 1. size check
        @assert( length(w) == length(Lab) == length(N[1:Sr]) , "uncompatible vector size: w, Lab or N" )
        # 2. accounting
        local 𝕡::Float64
        𝕡 = 𝕓 * πMf * sum( w .* N[1:Sr] .* Lab ) / sum( N[Sr+1:end] )
        return 𝕡
    end















# ==============================================================================
end  # module ends
