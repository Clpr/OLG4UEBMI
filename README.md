# OLG4UEBMI

*Re-factor of the basic 80-generation OLG model for UE-BMI in China*

## Paper

*Population aging and public health insurance reform in China*, (with Y. Jiang and H. Zheng)

## What's new? (cp. with *180912-BaseModel*)
1. Re-factored in Julia 1.0.1
2. Improved performance and security
3. Deleted deprecated DP methods
4. Corrected minor mistakes in programs
5. More detailed documentations and comments (both academic & coding); most documentations are provided in two languages: English & Chinese




## Dependency

Readers need Julia 1.0+ environment and all the packages listed in `main.jl` and `/scripts/PlotForPaper.jl` to reproduce our results.




## Directory


1. `main.jl`: a demo calling to solve the model
2. `/data`: all exgogenous data to read in
3. `/output`: all output files will be saved here
4. `/docs`: academic documentations
5. `/deprecated`: all deprecated files, sources or datasets
6. `/sandbox`: some temporary scripts of trails
7. `/src`: source files
  1. `/deprecated`: deprecated source files
  2. `EasyEcon.jl`: some useful pure functions of economics
  3. `EasyIO.jl`: API to do convenient I/O
  4. `EasyMath.jl`: some mathematical functions
  5. `EasyPlot.jl`: masked plotting API; used to do visualization
  6. `EasySearch.jl`: main algorithms of searching steady states and transition path; including data slicer
  7. `House.jl`: a general API to solve the household life-cycle models with linear inter-temporal budget constraints (please refer to the academic documentations)
  8. `proc_InitPars.jl`: script to initialize parameters
  9. `proc_VarsDeclare.jl`: script to initialize data structure which define an economy
8. `/scripts`: scripts important but not directly related to model solving
  1. `/subsections_PlotForPaper`: sub-programs to do plotting for our paper
  1. `PlotForPaper.jl`: all programs to do plotting for our paper; introducing the scripts under /subsections_PlotForPaper
  2. `SensitivityAnalysis.jl`: perform sensitivity analysis on the baseline model
  3. `test.jl`: a temporary script to test the life-cycle model solving














## Links to older version

* [Project: 180912-BaseModel](https://github.com/Clpr/180912-BaseModel)
