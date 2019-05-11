# 1.1 UE-BMI under benchmark scenario
# NOTE: it is a 4-subfigure figure
   # 1.1.1 second, define a temp expr to save code lines
   tmpexpr = :(
      xlabel("Year"); ylabel("Percentage (%)"); grid(true);
      xlim([ idx_year2plot[1] - 1, idx_year2plot[end] + 1 ]);
      plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* dict_Demog_base["AgingPopuRatio"][idx_plot], "--b" );
      plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* (1.0 .- dict_Demog_base["WorkPopuRatio"] )[idx_plot], "-.r" );
   )
   # 1.1.2 then, do plotting
   figure( figsize = (13,8) )
      subplot(2,2,1)  # gap / pooling account's expenditure
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* (DatPkg_base.Dt[:LI]./DatPkg_base.Dt[:AggPoolExp])[idx_plot] )
         eval(tmpexpr)
         legend( ("Pool Gap/Pool Benefits","Aging Population Share (65+)",L"\rho"), loc = "best")
      subplot(2,2,2)  # gap / pooling account's income
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* (DatPkg_base.Dt[:LI]./DatPkg_base.Dt[:AggPoolIn])[idx_plot] )
         eval(tmpexpr)
         legend( ("Pool Gap/Pool Incomes","Aging Population Share (65+)",L"\rho"), loc = "best")
      subplot(2,2,3)  # gap / GDP
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* (DatPkg_base.Dt[:LI]./DatPkg_base.Dt[:Y])[idx_plot] )
         eval(tmpexpr)
         legend( ("Pool Gap/GDP","Aging Population Share (65+)",L"\rho"), loc = "best")
      subplot(2,2,4)  # gap / fiscal incomes
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* (DatPkg_base.Dt[:LI]./(DatPkg_base.Dt[:TRw] .+ DatPkg_base.Dt[:TRc]))[idx_plot] )
         eval(tmpexpr)
         legend( ("Pool Gap/Tax Revenues","Aging Population Share (65+)",L"\rho"), loc = "best")
      tight_layout()  # tight layout of the figure
   # 1.1.3 finally, save the figure as a pdf file
   savefig( "./output/BenchProfile.pdf", format = "pdf" )
# -----------------------------------------
# 1.2 simulation v.s. accounting
   # 1.2.1 do underlying plotting & read in accounting data
   EasyPlot.Plot_Calibrate( DatPkg_base.Dt, DatPkg_base.Dst, DatPkg_base.Pt, DatPkg_base.Ps, DatPkg_base.Pc, env,
      YearRange = ( 2010, 2050 ), LineWidth = 1.0,   outpdf = nothing, picsize = (12,9),
      tmpLayout = (2,1)
   )
   tmpDat = EasyIO.readcsv("./data/Calib_统筹账户收支核算结果v3_190403.csv")
   tmpEndTime = 40 + 2
   # 1.2.2 decoration (NOTE: do not new a figure GUI, just decorate the current one)
   subplot(2,1,1)
      plot( tmpDat[2:tmpEndTime,1] , 100.0 .* tmpDat[2:tmpEndTime,4] ./ tmpDat[2:tmpEndTime,2] , "-.r" )
      legend(["Baseline simulation","Pooling gap / Pooling account expenditure"],
         fontsize = 14)
   subplot(2,1,2)
      plot( tmpDat[2:tmpEndTime,1] , 100.0 .* tmpDat[2:tmpEndTime,4] ./ tmpDat[2:tmpEndTime,3] , "-.r" )
      legend(["Baseline simulation","Pooling gap / Pooling account revenues"],
         fontsize = 14)
   tight_layout()
   # 1.2.3 save figure
   savefig( "./output/BenchmarkCpAccount.pdf", format = "pdf" )


#
