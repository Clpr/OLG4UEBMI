__precompile__()
# A general API for the household life-cycle problems with a linear budget constraint
# encoding: utf-8; because the comments are contrated in both En & Ch languages
# ----------------------------
#
#
# Tianhao (GitHub: Clpr)
# Jan 2019
# ----------------------------
module DPHouse




# ------------------------------------------------------------------------------
# PART I: common types of utility functions 常用效用函数
# NOTE: in this sections, several kinds of utility functions are defined. These functions
#       can be used as the inputs to our DP algorithms.
#       of course, you may design your own utility functions.
#       however, please note that this module (now) only supports two things to consume: consumption & leisure;
#       therefore, please make sure that there are ONLY TWO POSITIONAL PARAMETERS! if more, please use annonymous functions to mask them.
    """
        u_CD( c::Real, l::Real; beta::Real = 0.5 )

    Two goods (consumption, leisure) Cobb-Douglas utility function
    (or called as logarithm linear utility function),
    whose formula is `` u = c^\\beta l^(1-\\beta) ``;
    where ``c`` is a non-negative consumption, ``l`` is a non-negative leisure,
    `\\beta`` is the income share of consumption.

    Returns a Float64, the value of utility
    """
    function u_CD( c::Real, l::Real; A::Real = 1.0, beta::Real = 0.5 )
        @assert (c>=0)&(l>=0) , "invalid c or l"
        local u::Float64
        u = ( c + eps() ) ^ beta * ( l + eps() ) ^ ( 1 - beta )
        return u::Float64
    end
    # -------------
    """
        u_CES( c::Real, l::Real; A::Real = 1.0, sigma::Real = 1.0, xi::Real = 0.5 )

    Two goods (consumption, leisure) CES (const elasticity of substitution) utility function,
    whose formula is : ``u = [ c^\\sigma + \\alpha l^\\sigma ] ^ \\xi ``.
    requires ``\\simga \\times \\xi < 1``.

    Returns a Float64, the value of utility
    """
    function u_CES( c::Real, l::Real; alpha::Real = 1.0, sigma::Real = 1.0, xi::Real = 0.5 )
        @assert (c>=0)&(l>=0) , "invalid c or l"
        @assert sigma * xi < 1  , "the product of sigma and xi should be less than one"
        local u::Float64
        u = (  ( c + eps() ) ^ sigma + alpha * ( l + eps() ) ^ sigma  ) ^ xi
        return u::Float64
    end
    # -----------
    """
        u_Log( c::Real, l::Real; beta::Real = 0.5 )

    Two goods (consumption, leisure) Separable logarithm utility function,
    i.e. the logarithm of Cobb-Douglas utility function;
    whose formula is : `` u = \\beta \\log (c) + (1-\\beta) \\log(l) ``.

    Returns a Float64, the value of utility
    """
    function u_Log( c::Real, l::Real; beta::Real = 0.5 )
        @assert (c>=0)&(l>=0) , "invalid c or l"
        local u::Float64
        u = beta * ( c + eps() ) + (1-beta) * ( l + eps() )
        return u::Float64
    end
    # -----------

# ------------------------------------------------------------------------------
# PART II: data types of a linear-budget DP problem 线性预算约束的动态规划问题的标准模型
# NOTE: in this part, we define data types which define a standard DP problem to solve;
#       users need to initialize such a problem instance, then pass it to our solving APIs.
#       Please read our academic document to learn the mathematics of our standard DP problem.
    """
        DPProblem( Smax::Int, Sret::Sret, DatPkg::Dict{Symbol,Vector} )

    a standard linear-budget DP problem, where:
    1. Smax: the number of maximum age
    2. Sret: the number of working years, requiring: Smax > Sret >= 1
    3. DatPkg: a dictionary, containing:
        1. A: the multiplier on ``k_{s+1}``, A>0; len = Smax
        2. B: the multiplier on ``k_{s}``, B>0; len = Smax
        3. D: the multiplier on ``l`` (leisure); len = Sret
        4. E: the multiplier on ``c`` (consumption); len = Smax
        5. F: the constant term; len = Smax
        6. beta: utility discounting factor; len = Smax
        7. lbar: time endowment; len = Sret

    The linear budget is:
    `` A_s k_{s+1} = B_s k_{s} + D_s (\\bar{l}_s - l_s) - E_s c_s + F_s, 1\\leq s \\leq S_r ``

    `` A_s k_{s+1} = B_s k_{s} - E_s c_s + F_s, S_r < s \\leq S ``

    And the boundary conditions are:
    `` k_{1} = 0; k_{S+1} = 0 ``
    """
    mutable struct DPProblem
        # basic pars 基本参数
        Smax::Int # maximum age (natural death)
        Sret::Int # retirement age (the number of working years)
        # budget pars 预算约束数据
        A::Vector # the multiplier on k_{s+1}, A>0; len = Smax
        B::Vector # the multiplier on k_{s}, B>0; len = Smax
        D::Vector # the multiplier on l (leisure); len = Sret
        E::Vector # the multiplier on c (consumption); len = Smax
        F::Vector # the constant term; len = Smax
        # preference & endowment
        beta::Vector # utility discounting factor; len = Smax
        lbar::Vector # time endowment; len = Sret
        # ------ constructor
        function DPProblem( Smax::Int, Sret::Int, DatPkg::Dict{Symbol,Vector{Float64}} )
            # assertion
            @assert( (Smax > Sret) & (Sret >= 1) , "requires: Smax > Sret >= 1" )
            # unpackaging
            local A::Vector = DatPkg[:A]
            local B::Vector = DatPkg[:B]
            local D::Vector = DatPkg[:D]
            local E::Vector = DatPkg[:E]
            local F::Vector = DatPkg[:F]
            local beta::Vector; beta = DatPkg[:beta]
            local lbar::Vector; lbar = DatPkg[:lbar]
            # assertions
            @assert( length(A)==length(B)==length(E)==length(F)==length(beta)==Smax , "A,B,E,F,beta should have Smax elements" )
            @assert( length(D)==length(lbar)==Sret,  "D,lbar should have Sret elements" )
            @assert( all(A .> 0.0) & all(B .> 0.0) , "A,B should be greater than zero" )
            @assert( all(D .!= 0.0) & all(E .!= 0.0) , "D,E should not be zero" )
            @assert( all(beta .!= 0.0) & all(lbar .> 0.0) , "beta should not be zero, and lbar should be greater than zero" )
            # initialization
            new( Smax,Sret,A,B,D,E,F,beta,lbar )
        end
    end
    # ----------------
    # sample datasets for demo 样例数据集
    SampleSmax = 40::Int; SampleSret = 21::Int
    SampleDatPkg = Dict(
        :A => fill(0.99,SampleSmax),  # usually be the adjustment term of accidental mortalities
        :B => fill(1.07,SampleSmax),  # usually be capital returns
        :D => fill(0.64,SampleSret),  # usually be wage taxations and the contributions to social security plans
        :E => fill(1.10,SampleSmax),  # usually be consumption taxations
        :F => rand(SampleSmax),  # usually be other kinds of capital flows, e.g. pension benefits
        :beta => fill(0.99,SampleSmax),  # utility discounting factors
        :lbar => ones(SampleSret),  # time endowments, usually be 1
    )




# ------------------------------------------------------------------------------
# PART III: DP Algorithms 求解API
# NOTE: in this section, we provide the standard API of a linear-budget DP problem defined by ::DPProblem().
#       meanwhile, users should input a utility function which have ONLY two positional parameters: u(c,l)
#       if there are extra parameters, please use annonymous function to decorate the original utility function.
    # """
    #
    #
    #
    #
    # """
    # function DPSolve( Problem::DPProblem, ufunc::Function ; SearchDensity::Int = 50 )




















end  # module ends
#
