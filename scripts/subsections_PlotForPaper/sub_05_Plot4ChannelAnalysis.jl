# this section includes:

# 1. methods to do simulation
# 2.




using Dierckx  # use 1D B-spline (linear) interpolations to approximate gradients, Dierckx is the julia wrapper of Fortran library Dierckx
using PyPlot


# ----------------------------------
# SECTION: quick methods
# ----------------------------------
# 1. expr to refresh env & workspace data
macro macro_RefreshEnvData( PopulationCSVFile::String )
   # usage: @macro_RefreshEnvData( "./data/Demography_base.csv" )
   return :(
   env = (
      T = 400, S = 80, Sr = 40, START_AGE = 20, START_YEAR = 1945,
      PATH_DEMOGCSV = $PopulationCSVFile,
      PATH_WAGEPROFILE = "./data/WageProfileCoef.csv", PATH_MA2MB = "./data/MA2MBCoef.csv",
      PATH_M2C = "./data/M2C.csv", PATH_TFPGROW = "./data/tfpGrowthProfile.csv",
   );
   include("$(pwd())\\src\\proc_VarsDeclare.jl"); # use pwd() to avoid possible ambiguity of working directory
   include("$(pwd())\\src\\proc_InitPars.jl");
   )
end # macro_RefreshEnvData


# 2. expr to solve a model
expr_RunModel = :(begin;
   include("$(pwd())\\src\\proc_VarsDeclare.jl"); # use pwd() to avoid possible ambiguity of working directory
   include("$(pwd())\\src\\proc_InitPars.jl");
   println("solving......")
   Guess = ( r = 0.08, L = 0.2 );EasySearch.SteadyState!( 1, Guess, Dt, Dst, Pt, Ps, Pc, env, atol = 1E-8, MaxIter = 1000, PrintMode = "silent", MagicNum = 2.0, StepLen = 0.5 ); Guess = ( r = 0.12, L = 0.75 );
   EasySearch.SteadyState!( env.T, Guess, Dt, Dst, Pt, Ps, Pc, env, atol = 1E-6, MaxIter = 1000, PrintMode = "silent", MagicNum = 2.0, StepLen = 0.5 );
   PerfLog = EasySearch.Transition!( Dt, Dst, Pt, Ps, Pc, env, atol = 1E-3, MaxIter = 500, PrintMode = "silent", MagicNum = 2.0, StepLen = 0.7, ReturnLog = true );
   EasySearch.ProcAfterTransition!( Dt, Dst, Pt, Ps, Pc, env );
   end;
)


# 3. small function to generate a two-stage-flat cross-sectional demography whose population size is 1
"""
   afunc_FlatDemog( Nretire2Nrate::Float64 ,S::Int, Sr::Int )

生成一个given max age S, given retirement age Sr, given working population/total population rate Nwork2Nrate,
的cross-sectional demography (a vector with length S);
# NOTE: 固定总人口为1，工作期flat，退休期flat，调整两期总人口比例

returns a vector with length S.
"""
afunc_FlatDemog( Nretire2Nrate::Float64 ,S::Int, Sr::Int ) = begin
   @assert( Nretire2Nrate <= 0.501, "non stable demography!" ) # allows a small ex to compute gradient (well, strictly we should use left-side gradient but ... to save time)
   return cat( fill( (1.0 - Nretire2Nrate) / Sr, Sr), fill( Nretire2Nrate / (S - Sr) , S - Sr)  , dims = 1 )::Vector{Float64}
end # afunc_FlatDemog


# 4. method to get the collection which saves required results
# NOTE: also returns c̄, w̄, l̄, Ã, B̃, LI/PoolExp, LI/PoolIn, LI/Y, LI/TaxRev in the same tuple;
#       used to compute contributions, GE effects etc.
# NOTE: EasySearch.ProcAfterTransition! is not essential
function afunc_getRes( t, Dt, Dst, Pt, Ps, Pc, env )
   # compute temp vars
   local AggMB = sum( Ps[:N][t,1:env.S] .* Dst[:MB][t,1:env.S] )
   local AggPoolExp = AggMB * ( 1.0 - Pt[:cpB][t] )
   local AggPoolIn = AggPoolExp - Dt[:LI][t]
   local NinSS = sum(Ps[:N][t,:])
   # mean q (well ... in fact, they are equal among ages)
   local qmean = sum(Ps[:q][t,:]) / env.S

   # collect
   tmpRes = (
      LIpercapita = Dt[:LI][t] / NinSS,  # gap per capita
      N = NinSS,  # total population
      ρ = sum(Ps[:N][t,1:env.Sr]) / sum(Ps[:N][t,:])  , # the retired population ratio
      c̄ = Dt[:C][t] / NinSS ,
      w̄ = Dt[:w̄][t],
      l̄ = Dt[:L][t] / NinSS,
      Ã = qmean * (1.0 - Pt[:cpB][t]) / ( 1.0 + sum(Ps[:p]) / env.S ) ,  # multiplier of benefit policy
      B̃ = (1.0 - Pt[:𝕒][t] - Pt[:𝕓][t]) * Pt[:ζ][t] / (1.0 + Pt[:z][t] * Pt[:η][t] + Pt[:ζ][t] ) ,  # multiplier of contribution policy
      gap2exp = Dt[:LI][t] / AggPoolExp,
      gap2in = Dt[:LI][t] / AggPoolIn,
      gap2gdp = Dt[:LI][t] / Dt[:Y][t],
      gap2taxrev = Dt[:LI][t] / (Dt[:TRw][t] + Dt[:TRc][t]),
   )
   return tmpRes::NamedTuple
end # afunc_getRes



# 6. funtions from ρ to: 𝕃, c̄, w̄, l̄; and their gradient at specific ρ level
# NOTE: ρ is defined as the retired population share
# NOTE: the following functions are defined IN ORDER, they refer defined functions
# NOTE: recommend to select the whole 6. then execute
# NOTE: we use Interpolations.gradients to compute gradient which avoids (visible) floating errors
# --------------------
   function solveSSwithRho( ρ::Real; t::Int = 2010 - 1945 + 1 , Dt = Dt, Dst = Dst, Pt = Pt, Ps = Ps, Pc = Pc, env = env )
      # create two-stage flat demography
      Ps[:N][t,:] = afunc_FlatDemog( ρ, env.S, env.Sr )
      # use p̄ to replace p_s
      Ps[:p][:] .= sum(Ps[:p]) / env.S
      # search SS at that year
      EasySearch.SteadyState!( t, ( r = 0.08, L = 0.2 ), Dt, Dst, Pt, Ps, Pc, env, atol = 1E-8, MaxIter = 1000, PrintMode = "silent", MagicNum = 2.0, StepLen = 0.5 ); Guess = ( r = 0.12, L = 0.75 );
      # collect data and return
      return afunc_getRes( t, Dt, Dst, Pt, Ps, Pc, env )
   end
   f_𝕃percapita(ρ::Float64 ; Year::Int = 2010 ) = solveSSwithRho(ρ, t = Year - 1945 + 1 ).LIpercapita
   f_c̄(ρ::Float64 ; Year::Int = 2010 ) = solveSSwithRho(ρ, t = Year - 1945 + 1 ).c̄
   f_w̄(ρ::Float64 ; Year::Int = 2010 ) = solveSSwithRho(ρ, t = Year - 1945 + 1 ).w̄
   f_l̄(ρ::Float64 ; Year::Int = 2010 ) = solveSSwithRho(ρ, t = Year - 1945 + 1 ).l̄

# solve dense-enough curves(e.g. ρ -> 𝕃) and do interpolations; they are used to evaluate gradients
# NOTE: use the linear B-spline of Dierckx package
# NOTE: itp_ vars are used to plot 0-order; grad_ means 1st-order
grid_ρ = Array(LinRange( 0.08, 0.5, 300 ) ) # ρ lattice
grid_Res = [ solveSSwithRho(ρ) for ρ in grid_ρ ]

# interpolations & gradient
   # 1) gap per capita (𝕃)
   itp_𝕃percapita = Spline1D(grid_ρ,[ grid_Res[x].LIpercapita for x in 1:length(grid_Res) ])
   # 2) the 1st-order derivatives of 𝕃 (i.e. d𝕃/dρ = 𝔾 + 𝔻)
   grad_𝕃percapita = derivative(itp_𝕃percapita, grid_ρ)
   # 3) consumption per capita (c̄)
   itp_c̄ = Spline1D(grid_ρ, [ grid_Res[x].c̄ for x in 1:length(grid_Res) ])
   # 4) dc̄/dρ
   grad_c̄ = derivative(itp_c̄, grid_ρ)
   # 5) average wage (w̄)
   itp_w̄ = Spline1D(grid_ρ, [ grid_Res[x].w̄ for x in 1:length(grid_Res) ])
   # 6) dw̄/dρ
   grad_w̄ = derivative(itp_w̄, grid_ρ)
   # 7) labor supply per capita (l̄)
   itp_l̄ = Spline1D(grid_ρ, [ grid_Res[x].l̄ for x in 1:length(grid_Res) ])
   # 8) dl̄/dρ
   grad_l̄ = derivative(itp_l̄, grid_ρ)

# extract vectors used later
   itp_Ã = Spline1D(grid_ρ, [ grid_Res[x].Ã for x in 1:length(grid_Res) ])
   itp_B̃ = Spline1D(grid_ρ, [ grid_Res[x].B̃ for x in 1:length(grid_Res) ])
   itp_gap2exp = Spline1D(grid_ρ, [ grid_Res[x].gap2exp for x in 1:length(grid_Res) ])
   itp_gap2in = Spline1D(grid_ρ, [ grid_Res[x].gap2in for x in 1:length(grid_Res) ])
   itp_gap2gdp = Spline1D(grid_ρ, [ grid_Res[x].gap2gdp for x in 1:length(grid_Res) ])
   itp_gap2taxrev = Spline1D(grid_ρ, [ grid_Res[x].gap2taxrev for x in 1:length(grid_Res) ])


# compute lattice vectors of GE effect 𝔾, and cross effect 𝔻
   # 1) GE effect 𝔾
   itp_𝔾 = itp_Ã(grid_ρ) .* grad_c̄ .-
           itp_B̃(grid_ρ) .* ( grad_w̄ .* itp_l̄(grid_ρ) + grad_l̄ .* itp_w̄(grid_ρ) ) .+
           itp_B̃(grid_ρ) .* itp_w̄(grid_ρ) .* itp_l̄(grid_ρ)
   itp_𝔾 = Spline1D(grid_ρ,itp_𝔾) # to unify denotations
   # 2) cross effect 𝔻
   itp_𝔻 = grid_ρ .* itp_B̃(grid_ρ) .* ( grad_w̄ .* itp_l̄(grid_ρ) + grad_l̄ .* itp_w̄(grid_ρ) )
   itp_𝔻 = Spline1D(grid_ρ,itp_𝔻)




# 7. reset datasets under benchmark fertility/demography projection
#    then tell & record the real(projected) ρ in 2010
@macro_RefreshEnvData( "./data/Demography_base.csv" ) # refresh it!
tmp = Ps[:N][2010 - 1945 + 1, :]
realρ2010 = 1.0 - sum(tmp[1:env.Sr]) / sum(tmp)
println("The real/projected 2010's rho is: ", realρ2010 )



















# ----------------------------------
# SECTION: relation: ρ -> LI/N (ρ is retired population ratio)
# NOTE: collects gap per capita, N, ρ, c̄, w̄, l̄, Ã, B̃, LI/PoolExp, LI/PoolIn, LI/Y, LI/TaxRev in the same tuple
# NOTE: using two-stage flat cross-sectional demography
# NOTE: ρ <= 0.5 to ensure it is a stable demography
# ----------------------------------
tmpexpr = :(
   grid(true); xlabel(L"$\rho$");
)
figure(figsize=(18,6))
   subplot(1,2,1)  # lines: d𝕃/dρ, 𝔾, 𝔻
      plot(grid_ρ,grad_𝕃percapita,"-")
      plot(grid_ρ,itp_𝔾(grid_ρ),"-.r")
      plot(grid_ρ,itp_𝔻(grid_ρ),"--b")
      axvline(realρ2010, linestyle = ":" )  # add a vertical line indicating real ρ in 2010
      text( realρ2010, 0.0, L"Real 2010 ρ = " * string(realρ2010) )
      eval(tmpexpr)
      legend([L"d$\mathbb{L}$/dρ",
              L"GE effect ($\mathbb{G}$)",
              L"Corss effect ($\mathbb{D}$)"],
              loc="best")
   subplot(1,2,2)  # lines: 𝔻 = GE part * ρ
      plot(grid_ρ,itp_𝔻(grid_ρ),"-")
      plot(grid_ρ,grid_ρ,"-.r")
      plot(grid_ρ,itp_𝔻(grid_ρ) ./ grid_ρ,"--g")
      axvline(realρ2010, linestyle = ":" )  # add a vertical line indicating real ρ in 2010
      eval(tmpexpr)
      legend([L"Corss effect ($\mathbb{D}$) = GE part $\times \rho$ ",
              L"$\rho$",
              L"GE part of $\mathbb{D}$"],
              loc="best")
   tight_layout()
   # save figure
   savefig("$(pwd())/output/Channel_DecomposeInSState.pdf", format = "pdf")



















# plot(grid_ρ,itp_gap2exp(grid_ρ))
# plot(grid_ρ,itp_gap2in(grid_ρ))
# plot(grid_ρ,itp_gap2gdp(grid_ρ))
# plot(grid_ρ,itp_gap2taxrev(grid_ρ))
































#
