# this script does plotting for our paper
# ------------------------
# Including (in order):
# 1. MODEL EVALUATION: fertility experiments
#    1. UE-BMI under baseline scenario
#    2. Baseline compared with accounting results
#    3. Fertility experiments and UE-BMI
#    4. Summary table for benchmark
#    5. correlations (during plotting years) between econ vars & aging population ratio
# 2. MODEL EVALUATION: contribution rate increases
#    1. Rising of firm’s contribution rate to UE-BMI
#    2. ζ elasticity of four economic variables
# 3. MODEL EVALUATION: contract reforms on individual accounts
#    1. Reforms of individual accounts of UE-BMI
#  -----------------------
# NOTE: all figures are output to "pwd()/output/"




include("$(pwd())/main.jl") # if not run main.jl yet, run it first




# -----------------------------------
# SECTION introduction
# -----------------------------------
# NOTE: set pwd() as the root directory of the project to correctly cite paths!
   # --------- for plotting
   import EasyPlot
   using PyPlot
   # --------- for analysis & I/O
   import Statistics
   import DataFrames, CSV




# -----------------------------------
# SECTION: baseline & fertility experiments plotting
# -----------------------------------
# 0. define expr, collection; then run Fertiltiy Experiments
include("$(pwd())/scripts/subsections_PlotFotPaper/sub_01_Def&RunFertilityExperiments.jl")

# 1. baseline plotting (no channel analysis)
   # Figure: Baseline compared with accounting results (BenchmarkCpAccount.pdf)
   # Figure: UE-BMI under baseline scenario (BenchProfile.pdf)
include("$(pwd())/scripts/subsections_PlotFotPaper/sub_02_Plot4Baseline.jl")

# 2. fertility experiments plotting (no channel analysis)
   # Figure: Fertility shocks and UE-BMI (FertilityShockProfile.pdf)
   # Table: Summary of baseline simulation (SummaryBench.csv)
include("$(pwd())/scripts/subsections_PlotFotPaper/sub_03_Plot4Baseline&FertilityExperiments.jl")

# 3. compute cor( econ var, aging population ratio )
   # No output file
include("$(pwd())/scripts/subsections_PlotForPaper/sub_04_Plot4BaselineCor.jl")

# 4. channel analysis in steady states
   # NOTE: based on the decomposition of gap
   # Figure:
   # Figure:
include("$(pwd())/scripts/subsections_PlotForPaper/sub_05_Plot4ChannelAnalysis.jl")






# -----------------------------------
# SECTION: contribution rates increase
# -----------------------------------
# 0. define expr, collection; then get the econ vars under lattice of zeta values
include("$(pwd())/scripts/subsections_PlotFotPaper/sub_06_Def&RunContributionRateRise.jl")

# 1. the four economic vars under different zeta values, plotting
   # Figure: Rising of firm’s contribution rate to UE-BMI (ContributionRateRise.pdf)
include("$(pwd())/scripts/subsections_PlotFotPaper/sub_07_Plot4ContributionRateRise.jl")

# 2. define expr, collection; then compute the zeta elasticities of diff econ vars
   # NOTE: requires "sub_06_Def&RunContributionRateRise.jl" run
include("$(pwd())/scripts/subsections_PlotFotPaper/sub_08_Def&RunElasticityOfZeta.jl")

# 3. elasticity analysis on zeta, plotting
   # Figure: ζ elasticity of four economic variables (ContributionRateRise_Elasticity.pdf)
include("$(pwd())/scripts/subsections_PlotFotPaper/sub_08_Plot4ZetaElasticity.jl")




# -----------------------------------
# SECTION: UE-BMI contract reforms on individual accounts
# -----------------------------------
# 0. define expr, collection; then get the econ vars under diff scenarios
include("$(pwd())/scripts/subsections_PlotFotPaper/sub_10_Def&RunIndiAcctReform.jl")

# 1. the four economic vars under different scenarios, plotting
   # Figure: Reforms of individual accounts of UE-BMI (IndiAcctReform.pdf)
include("$(pwd())/scripts/subsections_PlotFotPaper/sub_11_Plot4IndiAcctReform.jl")

# 2. crowding out caused by cancelling individual accounts, plotting
   # Figure: Crowding out effects (CrowdingOutEffect.pdf)
include("$(pwd())/scripts/subsections_PlotFotPaper/sub_12_Plot4CrowdingOutEffect.jl")





#
